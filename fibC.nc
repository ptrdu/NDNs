/**
 * this module implements the interface fibInfo,and deal with the 
 * received interest packet.
 * @author ptrdu
 * @date 2014-12-25
 */
#define FIBSIZE 20
#define FIBREFRESH 60000000

module fibC{
	provides{
		interface fibInfo;
		}
	uses{
		interface AMPacket;
		interface Packet;
		interface AMSend as Transmit;//send the matched interest packet to the other node
		interface Receive as FibRec;
		interface Timer<TMilli> as fibRefresh;
	}
}
implementation{
	uint8_t fibNum = 0;
	fib_it fibTable[FIBSIZE];
	In* recIn;
	message_t * in;
	uint8_t flag;
	bool sendBusy = FALSE;
	
	message_t recpacket;
	message_t sendPacket;
	In* send;
	/**
	 * post the task when get the broadcast message from the lower layer protocol.
	 * the node get the range data from the message,store in the fib table if the table has
	 * not exist the same item,else discard the message. 
	 */
	task void modify();
	/**
	 * the task refresh the fib table when the timer fired,it will delete the fib item that not
	 * used in the periodic. 
	 */
	task void refresh();
	/**
	 * the task deal with the interest packet,it query the fib table and transmit the interest packet 
	 * if find the matched item
	 */
	task void FibdealIn();
	/**
	 * the task to send the message
	 */
	task void sendMsg();
	/**
	 * the task signal the event fibInfo.InDone after all the operations when get
	 * an interest packet
	 */
	task void INdone();
	/**
	 * the function judge whether the point pos located in the area temp
	 * @param temp : the area
	 * @param pos : the point
	 * @return TRUE : if located else FALSE
	 */
	bool locateIn(area temp,area pos);
	
	command fib_it * fibInfo.getAll(){
		// TODO Auto-generated method stub
		return fibTable;
	}

	command uint8_t fibInfo.fibSize(){
		// TODO Auto-generated method stub
		return FIBSIZE;
	}

	command uint8_t fibInfo.getNum(){
		// TODO Auto-generated method stub
		return fibNum;
	}

	command void fibInfo.init(){
		// TODO Auto-generated method stub
		memset(fibTable,0,sizeof(fib_it)*FIBSIZE);
		fibNum = 0;
		call fibRefresh.startPeriodic(FIBREFRESH);
	}

	command bool fibInfo.In_queryfib(message_t* msg){
		// receive a interest message
		in = msg;
		recIn = (In*)(call Packet.getPayload(msg, sizeof(In)));
		flag = 0;
		dbg("FIB","The fib module deal with the received interest packet!\n");
		post FibdealIn();
		return FALSE;
	}

	command void fibInfo.fresh(){
		// TODO Auto-generated method stub
		post refresh();
	}

	event message_t * FibRec.receive(message_t *msg, void *payload, uint8_t len){
		// receive the message from the lower layer
		memset(&recpacket,0,sizeof(message_t));
		memcpy(&recpacket,msg,sizeof(message_t));
		post modify();
		return msg;
	}

	event void fibRefresh.fired(){
		// the periodic to refresh the fib table
		post refresh();
	}
	
	event void Transmit.sendDone(message_t *msg, error_t error){
		// TODO Auto-generated method stub
		if(error == SUCCESS){
			sendBusy = FALSE;
			flag++;
			post FibdealIn();
			}
	}

	task void modify(){
		Bro* rec = (Bro *)(call Packet.getPayload(&recpacket,sizeof(Bro)));
		uint16_t source = call AMPacket.source(&recpacket);
		area range = rec->range;
		uint8_t i;
		//dbg("FIB","Receive the fib message from %d!\n",source);
		for(i=0;i<fibNum;i++){
			if(fibTable[i].go_id == source){
				fibTable[i].range = range;
				//dbg("FIB","The fib item has already exist!\n");
				return;
				}
			}
		if(fibNum == FIBSIZE) return;
		memcpy(&(fibTable[fibNum].range),&range,sizeof(area));
		fibTable[fibNum].go_id = source;
		fibTable[fibNum].touched = TRUE;
		dbg("FIB","\n\nAdd a new fib item from %d:\n",source);		
		dbg("FIB","****************************************\n");
		dbg("FIB","The fib item's manage range: %d,%d/%d,%d\n",
		fibTable[fibNum].range.downLeft.Lon,fibTable[fibNum].range.downLeft.Lat,
		fibTable[fibNum].range.upRight.Lon,fibTable[fibNum].range.upRight.Lat);
		dbg("FIB","The export node of this fib item:%d\n",fibTable[fibNum].go_id);
		dbg("FIB","****************************************\n\n");
		fibNum++;
		dbg("FIB","The fib number is:%d\n",fibNum);
		return;
		}

	task void refresh(){
		uint8_t i;
		uint8_t j;
		dbg("FIB","Refresh the fib table!\n");
		for(i=0;i<fibNum;i++){
			if(!fibTable[i].touched){
				for(j=i;j<fibNum-1;j++) memcpy(&fibTable[j],&fibTable[j+1],sizeof(fib_it));
				}
			memset(&fibTable[j+1],0,sizeof(fib_it));
			fibNum--;
			}
		for(i=0;i<fibNum;i++) fibTable[i].touched = FALSE;
		}

	task void FibdealIn(){
		while(flag<fibNum){
			if(locateIn(fibTable[flag].range,recIn->range)){
				fibTable[flag].touched = TRUE;
				post sendMsg();
				return;
				}
				flag++;
			}
			post INdone();
			return;
		}
		
	task void INdone(){
		signal fibInfo.InDone(SUCCESS);
		}
		
	task void sendMsg(){
		send = (In*)(call Packet.getPayload(&sendPacket, sizeof(In)));
		memcpy(send,recIn,sizeof(In));
		if(!sendBusy){
			if(call Transmit.send(fibTable[flag].go_id, &sendPacket, sizeof(In)) == SUCCESS){
				dbg("FIB","Transmit the interest packet to %d:\n",fibTable[flag].go_id);
				sendBusy = TRUE;
				}
			}
	}
			
	bool locateIn(area temp, area pos) {
		if(temp.downLeft.Lon <= pos.downLeft.Lon && temp.downLeft.Lat <= pos.downLeft.Lat) {
			if(temp.upRight.Lon >= pos.upRight.Lon && temp.upRight.Lat >= pos.upRight.Lat) {
				return TRUE;
			}
		}
		return FALSE;
	}
}