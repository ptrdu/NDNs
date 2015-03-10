/**
 * this module complete the functions in the ndn network,they contains the 
 * upperNDN interface and the maintenance of the whole ndn network.
 * @author ptrdu
 * @date 2014-12-19
 */
#define MAXSON 10
#define BROTIME 100000
#define FIBTIME 6000000

module upperC {
	provides {
		interface upperNDN;
	}
	uses {
		interface lowerCtp;
		interface AMSend as broSend;//send the range information to calculate the range of parent node
		interface Receive as broRec;
		interface AMSend as createFib;//send the range to the parent to create the fib table 
		interface Packet;
		interface AMPacket;
		interface Timer<TMilli> as broTime;//the broTime
		interface Timer<TMilli> as FibTimer;
		interface nodeInfo;
	}
}
implementation {
	area range;
	uint16_t sons[MAXSON];
	point position;
	uint8_t sonNum = 0;
	message_t sendPacket;
	message_t packet;
	message_t recPacket;
	message_t * rec;
	uint16_t parent;
	Bro * msgSend;
	Bro * msgRec;
	Bro * data;
	area Pos;
	bool sendBusy = FALSE;
	bool Busy = FALSE;

	point newLeft;
	point newRight;

	/**
	 * the task to send the range of this node to its' parent node
	 * i use the task to send the message because the send operation is 
	 * a split-phase process.
	 */
	task void sendRange();//send node's range to the parent node  

	/**
	 * task to calculate the range of this node.use task not function in case the other
	 * operation modify the range's value.
	 */
	task void calRange();//calculate the range of the node; 

	/**
	 * the task send the range to the parent's node.this task is different to the sendRange task.this 
	 * task send the range to modify its' parent node's fib table,the periodic of this task are more long
	 * than the sendRange task,because we need a steady range to add to the fib table.
	 */
	task void fibSend();

	/**
	 * the function merge the range and the received range,to create a new range that contains the old area 
	 * and the received range.And this created range is the node's new range. 
	 * @param temp : the old range
	 * @param pos : the received range
	 * @return area : the new range of this node
	 */
    area merge(area temp, area pos);//merge the range 

	/**
	 * get the message from the son node,and add the son node's id into the son table.
	 * @param id : the id of the son node
	 * @return TRUE : if the id add to the table success.
	 *         FALSE : the table is full or the id has already in the table
	 */
	bool insertSons(uint16_t id);//insert the son node's id into the son table
	/**
	 * the function to judge if the area pos are located in the area temp
	 * @param temp : the area
	 * @param pos : a area
	 * @return TRUE : if pos located in area temp
	 *         FALSE : the pos are not located in the temp 
	 */
	bool locateIn(area temp, area pos);

	command area upperNDN.getRange() {
		// TODO Auto-generated method stub
		return range;
	}

	command void upperNDN.netFresh() {
		// TODO Auto-generated method stub 

	}

	command uint16_t * upperNDN.getSons() {
		// TODO Auto-generated method stub
		return sons;
	}

	command uint8_t upperNDN.sonNum() {
		return sonNum;
	}

	command void upperNDN.init() {
		range.downLeft = call nodeInfo.getPosition();
		range.upRight = call nodeInfo.getPosition();
		sonNum = 0;
		memset(sons, 0, sizeof(uint16_t) * MAXSON);
		call broTime.startPeriodic(BROTIME);
		call FibTimer.startPeriodic(FIBTIME);
		dbg("UPPER", "initialize the upper protocal!\n");
		dbg("UPPER", "The initializing of the node's range:(%d,%d/%d,%d)!\n",
		range.downLeft.Lon,range.downLeft.Lat,
		range.upRight.Lon,range.upRight.Lat
		);
	}

	event void broSend.sendDone(message_t * msg, error_t error) {
		// TODO Auto-generated method stub
		sendBusy = FALSE;
	}

	event message_t * broRec.receive(message_t * msg, void * payload,
			uint8_t len) {
		// TODO Auto-generated method stub
		msgRec = (Bro * ) payload;
		//dbg("UPPER","Receive a new broadcast message,calculate the new range!\n");
		if(len == sizeof(Bro) && msgRec->type == BRO) {
			rec = msg;
			post calRange();
			return &recPacket;
		}
		return msg;
	}

	event void broTime.fired() {
		// TODO Auto-generated method stub
		post sendRange();
	}

	event void FibTimer.fired() {
		// TODO Auto-generated method stub
		post fibSend();
	}

	event void createFib.sendDone(message_t * msg, error_t error) {
		// TODO Auto-generated method stub
		Busy = FALSE;
	}
	//********************implement the task***********************************
	task void sendRange() {
		parent = call lowerCtp.getParent();
		msgSend = (Bro * ) call Packet.getPayload(&sendPacket, sizeof(Bro));
		memset(msgSend, 0, sizeof(Bro));
		memcpy(&(msgSend->range), &range, sizeof(area));
		msgSend->type = BRO;
		if(!sendBusy) {
			if(call broSend.send(parent, &sendPacket, sizeof(Bro)) == SUCCESS) {
				sendBusy = TRUE;
				//dbg("UPPER","Send the range broadcast message!\n");
			}
		}
	}

	task void fibSend() {
		parent = call lowerCtp.getParent();
		msgSend = (Bro * ) call Packet.getPayload(&packet, sizeof(Bro));
		memset(msgSend, 0, sizeof(Bro));
		memcpy(&(msgSend->range), &range, sizeof(area));
		msgSend->type = BRO;
		if(!Busy) {
			if(call createFib.send(parent, &packet, sizeof(Bro)) == SUCCESS) {
				Busy = TRUE;
				dbg("UPPER","Send the range to the father node %d to create the fib table!\n",parent);
			}
		}
	}

	task void calRange() {
		uint16_t addr = call AMPacket.source(rec);
		if(insertSons(addr)){
			sonNum++;
			dbg("UPPER","Add a new son node:%d\n",sons[sonNum-1]);
			dbg("UPPER","son number:%d\n",sonNum);
			}
		data = (Bro * ) call Packet.getPayload(rec, sizeof(Bro));
		Pos = data->range;
		range = merge(range, Pos);
		dbg("UPPER","The new range of this node:(%d,%d/%d,%d)!\n",
		range.downLeft.Lon,range.downLeft.Lat,
		range.upRight.Lon,range.upRight.Lat
		);
	}
	//*************************implement the function************************
	bool insertSons(uint16_t id) {
		uint8_t i;
		for(i = 0; i < sonNum; i++) {
			if(id == sons[i]) 
				return FALSE;
		}
		sons[sonNum] = id;
		return TRUE;
	}
	area merge(area temp, area pos) {	
		if(locateIn(temp, pos)) return temp;
		temp.downLeft.Lon = (pos.downLeft.Lon<=temp.downLeft.Lon)?pos.downLeft.Lon:temp.downLeft.Lon;
		temp.downLeft.Lat = (pos.downLeft.Lat<=temp.downLeft.Lat)?pos.downLeft.Lat:temp.downLeft.Lat;
		temp.upRight.Lon = (pos.upRight.Lon >= temp.upRight.Lon)?pos.upRight.Lon:temp.upRight.Lon;
		temp.upRight.Lat = (pos.upRight.Lat >= temp.upRight.Lat)?pos.upRight.Lat:temp.upRight.Lat;
		return temp;
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