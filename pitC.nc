/**
 * the module implements the pitInfo interface,and completes the operation
 * when the the pit table receive a interest packet or a Data packet
 * @author ptrdu
 * @date 2014-12-23
 */
#define PITSIZE 20
#define PITTIME 5000000
module pitC{
	provides{
		interface pitInfo;
		}
	uses{
		interface AMSend as pitSend;//send the matched packet
		interface Timer<TMilli> as pitFreshTimer;
		interface Packet;
		interface AMPacket;
	}
}
implementation{

	message_t * in;
	message_t * da;
	
	pit_it pitTable[PITSIZE];
	uint8_t pitNum = 0;
	In* Inrec;
	message_t InBuffer;
	uint16_t come_id;
	bool sendBusy = FALSE;
	
	uint8_t flag;
	uint8_t delFlag;
	message_t packet;
	Da* send;
	Da* Darec;
	message_t DaBuffer;
	uint16_t go_id;
	
	point msgPoint;
	uint8_t type;
	uint32_t time;
	uint16_t data;
	/**
	 * the task add a interest message into the pit table if no matched item in the pit table
	 */
	task void addPit();
	/**
	 * the task refresh the pit table,delete the unused item in a periodic
	 */
	task void fresh();
	/**
	 * the task deal with the received data packet, transmit the data packet if find the matched 
	 * item in the table,if no ,discard the data packet.
	 */
	task void dealDa();
	/**
	 * the task has the same function in the other modules,send the message.
	 */
	task void sendMsg();
	/**
	 * the task signal the event pitInfo.InDone after complete the operations when receive
	 * a interest packet,and set the value in the event as SUCCESS
	 */
	task void IN_SUCCESS();
	/**
	 * the task signal the event pitInfo.InDone after complete the operations when receive
	 * a interest packet,and set the value in the event as FAIL
	 */
	task void IN_FAIL();
	/**
	 * the task signal the event pitInfo.DaDone after complete the operations when receive
	 * a DATA packet
	 */
	task void DAdone();
	/**
	 * the function judge whether the received interest packet has already exists in the 
	 * pit item.
	 * @param item : the item in the pit table
	 * @param rec : the received interest packet
	 * @return TRUE: if rec matched the item,else return FALSE
	 */
	bool equal(pit_it item,In* rec);
	/**
	 * the same function in the others modules......
	 * @param temp : the area
	 * @param pos : the point
	 */
	bool locateIn(area temp,point pos);
	
	command uint8_t pitInfo.pitSize(){
		// TODO Auto-generated method stub
		return PITSIZE;
	}

	command bool pitInfo.In_queryPit(message_t *msg){
		// TODO Auto-generated method stub
		uint8_t i;
		in = msg;
		memset(&InBuffer,0,sizeof(message_t));
		memcpy(&InBuffer,msg,sizeof(message_t));
		Inrec = (In*)(call Packet.getPayload(&InBuffer, sizeof(In)));
		come_id = call AMPacket.source(&InBuffer);
		dbg("PIT","The pit module deal with the received Interest packet!\n");
		for(i=0;i<pitNum;i++){
			if(equal(pitTable[i],Inrec)){
				post IN_SUCCESS();
				return TRUE;
				}
		}		
		post addPit();
		post IN_FAIL();
		return FALSE;
	}
	
    task void IN_SUCCESS(){
    	signal pitInfo.InDone(SUCCESS);
    }
    
    task void IN_FAIL(){
    	signal pitInfo.InDone(FAIL);
    }
    
	command void pitInfo.init(){
		pitNum = 0;
		memset(pitTable,0,sizeof(pit_it)*PITSIZE);
		call pitFreshTimer.startPeriodic(PITTIME);
	}

	command bool pitInfo.Da_queryPit(message_t *msg){
		// TODO Auto-generated method stub
		da = msg;
		Darec = (Da*)(call Packet.getPayload(msg, sizeof(Da)));
		flag = 0;
		dbg("PIT","The pit module deal with the recieved data packet!\n");
		post dealDa();
		return FALSE;
	}

	command pit_it * pitInfo.getAll(){
		// TODO Auto-generated method stub
		return pitTable;
	}
	
	command uint8_t pitInfo.getNum(){
		// TODO Auto-generated method stub
		return pitNum;
	}
	
	command void pitInfo.fresh(){
		// TODO Auto-generated method stub
		post fresh();
	}
		
	event void pitSend.sendDone(message_t *msg, error_t error){
		// TODO Auto-generated method stub
		if(error == SUCCESS){
			sendBusy = FALSE;
			flag++;
			post dealDa();
		}
	}
	
	event void pitFreshTimer.fired(){
		// TODO Auto-generated method stub
		post fresh();
	}
	
	task void addPit(){
		if(pitNum == PITSIZE) return;
		pitTable[pitNum].range = Inrec->range;
		pitTable[pitNum].start = Inrec->start;
		pitTable[pitNum].end = Inrec->end;
		pitTable[pitNum].dataType = Inrec->dataType;
		pitTable[pitNum].come_id = come_id;
		pitTable[pitNum].touched = TRUE;
		dbg("PIT","\n\nAdd a new pit item form %d:\n",come_id);
		dbg("PIT","****************************************\n");
		dbg("PIT","Wanted data's range: %d,%d/%d,%d\n",
			pitTable[pitNum].range.downLeft.Lon,pitTable[pitNum].range.downLeft.Lat,
			pitTable[pitNum].range.upRight.Lon,pitTable[pitNum].range.upRight.Lat
			);	
		dbg("PIT","Wanted data's collected time: %d--%d\n",
			pitTable[pitNum].start,pitTable[pitNum].end);
		dbg("PIT","Wanted data's type: %d\n",pitTable[pitNum].dataType);
		dbg("PIT","The export node of this pit item %d:\n",pitTable[pitNum].come_id);
		dbg("CS","****************************************\n\n");
		pitNum++;
		dbg("PIT","The number of item in the pit table:%d!\n",pitNum);
				}
				
	task void fresh(){
		uint8_t i;
		uint8_t j;
		for(i=0;i<pitNum;i++){
			if(!pitTable[i].touched){
				for(j=i;j<pitNum-1;j++){
					memcpy(&pitTable[j],&pitTable[j+1],sizeof(pit_it));
					}
				memset(&pitTable[j+1],0,sizeof(pit_it));
				pitNum--;
				}
			}
		for(i=0;i<pitNum;i++) pitTable[i].touched = FALSE;
		//dbg("PIT","Refresh the pit table!\n");
		}	
		
	task void dealDa(){	
		msgPoint = Darec->location;
		type = Darec->dataType;
		time = Darec->time;
		data = Darec->data;		
		while(flag<pitNum){
			if(locateIn(pitTable[flag].range,msgPoint)){
				if(pitTable[flag].start<=time && pitTable[flag].end>=time){
					if(type == pitTable[flag].dataType){
						pitTable[flag].touched = TRUE;
						go_id = pitTable[flag].come_id;
						post sendMsg();
						return;
						}
					}
				}
				flag++;
			}
			post DAdone();
			return;
		}	
		
	task void DAdone(){	
		signal pitInfo.DaDone(SUCCESS);
	}
	
	task void sendMsg(){
		send = (Da*)(call Packet.getPayload(&packet, sizeof(Da)));
		send->location = msgPoint;
		send->dataType = type;
		send->type = DATA;
		send->data = data;
		send->time = time;
		if(!sendBusy){
			if(call pitSend.send(go_id, &packet, sizeof(Da)) == SUCCESS){
			dbg("PIT","\n\nTransmit the data packet to %d:\n",go_id);
			dbg("PIT","****************************************\n");
			dbg("PIT","point's position: %d,%d\n",
				send->location.Lon,send->location.Lat
				);
			dbg("PIT","The data's type: %d\n",send->dataType);
			dbg("PIT","The data's value: %d\n",send->data);
			dbg("CS","****************************************\n\n");	
			sendBusy = TRUE;
				}
			}
		}
			
	bool locateIn(area temp,point pos){
		if(temp.downLeft.Lon <= pos.Lon && temp.downLeft.Lat<= pos.Lat){
			if(temp.upRight.Lon >= pos.Lon && temp.upRight.Lat >= pos.Lat){
				return TRUE;
				}
			}
		return FALSE;
		}
		
	bool samePoint(point a,point b){
		if(a.Lon==b.Lon && a.Lat==b.Lat) return TRUE;
		return FALSE;
	}
				
	bool sameRange(area A , area B){
		if(samePoint(A.downLeft,B.downLeft) && samePoint(A.upRight,B.upRight)) return TRUE;
		return FALSE;
		}
						
	bool equal(pit_it item,In* rec){
		if(sameRange(item.range,rec->range)){
			if(item.start == rec->start){
				if(item.end == rec->end){
					if(item.dataType == rec->dataType){
						return TRUE;
						}
					}
				}
			}
		return FALSE;
		}
}