/**
 * this module implements the operations when deal
 * with a interest packet or a data packet. 
 * @author ptrdu
 * @date 2014-12-22
 */
#define CSMAX 50
#define CSTIME 10000000

module csC {
	provides{
		interface csInfo;
		}
	uses{
		interface repoInfo;
		interface AMPacket;
		interface Packet;
		interface AMSend as DataSend;
		interface Timer<TMilli> as csFreshTimer;
		}
}
implementation{
    // the cs table 
	cs_it csTable[CSMAX];
	
	uint8_t csNum = 0;
	message_t * in;
	message_t * da;
	uint8_t sendFlag = 0;
	message_t packet;
	bool sendBusy = FALSE;
	
	//the content in a interest packet
	In * rec;
	area area_in;
	uint32_t start_in;
	uint32_t end_in;
	uint8_t dataType;
	uint16_t addr;
	//the content in a data packet
	Da * Drec;
	
	//uint8_t i,j;
	/**
	 * the task to deal with the interest message
	 * when the node receive a interest message, it will post this task to find
	 * if there exists the matched item.
	 * All the process are based on the NDN rules.
	 */	
	task void CsdealIn();
	/**
	 * the task to send the data message,use task in case of the data corruption
	 */
	task void sendData();
	/**
	 * the task to refresh the cs table
	 */
	task void fresh();
	/**
	 * the task signal event after deal with interest packet
	 */
	task void INDone();
	/**
	 * the task signal the event when deal with a data packet,set
	 * the error value as FAIL in the event csInfo.DaDone.
	 */
	task void DA_FAIL();
	/**
	 * the task signal the event when deal with a data packet,set
	 * the error value as SUCCESS in the event csInfo.DaDone.
	 */
	task void DA_SUCCESS();
	/**
	 *the function judge whether the pos located in the area temp
	 * @param temp : the area
	 * @param pos : the point
	 * @return TRUE : if the pos located in the area
	 *         FALSE : not located in
	 * 
	 * I should declare the functions like this in the head file ........
	 */
	bool locateIn(area temp,point pos);
	/**
	 * the function query the repository table when get a interest packet. In the past version,
	 * i store the data in the cs table,in this version i collect the data in the repository.
	 * the node will first query the repository,and get the matched item in the repository to the cs table.
	 * @param type : the type of the wanted data(e.g. Light or humidity)
	 * 
	 */
	void queryRepo(uint8_t type);
	/**
	 * judge whether the two points are the same
	 * @param a : point a;
	 * @param b : point b;
	 * @return TRUE : if same else return FALSE
	 */
	bool samePoint(point a,point b);
	
	command void csInfo.init(){
		memset(csTable,0,sizeof(cs_it)*CSMAX);
		csNum = 0;
		call csFreshTimer.startPeriodic(CSTIME);
	}
	
	command cs_it * csInfo.getAll(){
		// TODO Auto-generated method stub
		return csTable;
	}

	command uint8_t csInfo.getNum(){
		// TODO Auto-generated method stub
		return csNum;
	}
	
	command uint8_t csInfo.csSize(){
		// TODO Auto-generated method stub
		return CSMAX;
	}
	
	command bool csInfo.In_queryCS(message_t *msg){
		// TODO Auto-generated method stub
		in = msg;
		rec = (In*)(call Packet.getPayload(msg, sizeof(IN)));
		addr = call AMPacket.source(msg);
		area_in = rec->range;
		start_in = rec->start;
		end_in = rec->end;	
		dataType = rec->dataType;
		//query the repository and add the matched item to the cs table
		queryRepo(dataType);
		sendFlag = 0; 	
		dbg("CS","CS module deal with the Interest message!\n");
		post CsdealIn();
		return FALSE;
	}
	
	command bool csInfo.Da_queryCS(message_t *msg){
		// TODO Auto-generated method stub
		uint8_t i;
		dbg("CS","The cs module reveive a Data message!\n");
		da = msg;
		Drec =(Da*)(call Packet.getPayload(msg, sizeof(Da)));
		for(i=0;i<csNum;i++){
			if(samePoint(csTable[i].location,Drec->location)){
				if(csTable[i].dataType==Drec->dataType && csTable[i].data==Drec->data){
					if(csTable[i].time == Drec->time){
						//do nothing
						dbg("CS","Find the mateched item,discard the data packet!\n");
						post DA_SUCCESS();			
						return TRUE;
						}
					}
				}
		}
		memcpy(&(csTable[csNum].location),&(Drec->location),sizeof(point));
		csTable[csNum].time = Drec->time;
		csTable[csNum].dataType = Drec->dataType;
		csTable[csNum].data = Drec->data;
		csTable[csNum].touched = TRUE;
		dbg("CS","\n\nStore the data packet in the cs table:\n");
		dbg("CS","****************************************\n");
		dbg("CS","Point's position: %d,%d\n",csTable[csNum].location.Lon,csTable[csNum].location.Lat);
		dbg("CS","Data's collected time: %d\n",csTable[csNum].time);
		dbg("CS","Data's type: %d\n",csTable[csNum].dataType);
		dbg("CS","Data's value: %d\n",csTable[csNum].data);
		dbg("CS","****************************************\n\n");
		csNum++;
		post DA_FAIL();
		return FALSE;
	}
	
	command void csInfo.fresh(){
		// TODO Auto-generated method stub
		post fresh();
	}
	
	event void DataSend.sendDone(message_t *msg, error_t error){
		// TODO Auto-generated method stub
		if(error == SUCCESS){
			sendBusy = FALSE;
			sendFlag++;
			post CsdealIn();
			}
	}
	
	event void csFreshTimer.fired(){
		// TODO Auto-generated method stub
		post fresh();
	}
	
	task void DA_FAIL(){
		signal csInfo.DaDone(FAIL);
	}
	
	task void DA_SUCCESS(){
		signal csInfo.DaDone(SUCCESS);
	}
	
	task void CsdealIn(){		
		while(sendFlag < csNum){
			if(locateIn(area_in,csTable[sendFlag].location)){
				if(csTable[sendFlag].time>=start_in && csTable[sendFlag].time<=end_in){
					if(dataType == csTable[sendFlag].dataType){
						csTable[sendFlag].touched = TRUE;
						post sendData();
						return;
						}
					}
				}
				sendFlag++;
			}
		post INDone();
		return;		
		}
		
	task void INDone(){
		signal csInfo.InDone(FAIL);
	}	
	
	task void sendData(){
		Da* Send = (Da *)(call Packet.getPayload(&packet, sizeof(Da)));
		Send->type = DATA;
		Send->dataType = csTable[sendFlag].dataType;
		memcpy(&(Send->location),&(csTable[sendFlag].location),sizeof(point));
		Send->time = csTable[sendFlag].time;
		Send->data = csTable[sendFlag].data;
		if(!sendBusy){
			if(call DataSend.send(addr, &packet, sizeof(Da)) == SUCCESS){
				sendBusy = TRUE;
				dbg("CS","\n\nCS module send the data packet to %d:\n",addr);
				dbg("CS","****************************************\n");
				dbg("CS","Point's position: %d,%d\n",Send->location.Lon,Send->location.Lat);
				dbg("CS","Data's collected time: %d\n",Send->time);
				dbg("CS","Data's type: %d\n",Send->dataType);
				dbg("CS","Data's value: %d\n",Send->data);
				dbg("CS","****************************************\n\n");
				}
			}
		}
			
	task void fresh(){
		uint8_t i;
		uint8_t j;
		//dbg("CS","Refresh the cs table!\n");
		for(i=0;i<csNum;i++){
			if(!csTable[i].touched){
				for(j=i;j<csNum-1;j++){
					memcpy(&csTable[j],&csTable[j+1],sizeof(cs_it));
					}
				memset(&csTable[j+1],0,sizeof(cs_it));
				csNum--;
				}
			}			
		for(i=0;i<csNum;i++) csTable[i].touched = FALSE;
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
	//search the repository table,add the matched item to the cs table	
	void repo_search(repo_it* table,uint8_t num,uint8_t type){
		uint8_t j;
		for(j=0;j<num;j++){
			if(locateIn(area_in,table[j].location)){
				if(table[j].time>=start_in && table[j].time<=end_in){
					memset(&csTable[csNum],0,sizeof(cs_it));
					csTable[csNum].location = table[j].location;
					csTable[csNum].time = table[j].time;
					csTable[csNum].dataType = type;
					csTable[csNum].data = table[j].data;
					csTable[csNum].touched = TRUE;
					csNum++;
					}
				}
			}
		}
		
	//query the repository table	
	void queryRepo(uint8_t type){
		switch(type){
			case(Light):
			repo_search(call repoInfo.getLight(),call repoInfo.lightNum(),type);
			break;
			case(Temp):
			repo_search(call repoInfo.getTemp(),call repoInfo.tempNum(),type);
			break;
			case(Humidity):
			repo_search(call repoInfo.getHum(),call repoInfo.humNum(),type);
			break;
			}
		}		
}