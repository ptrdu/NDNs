/**
 * the module receive the messages and deal with them,the module has two queue,the first is pool 
 * that regard as the receive buffer and another is queue which collect the received message.
 * When the node receive a message,it will get a buffer out of the pool as the next received message buffer
 * and store the current received message's buffer pointer in the queue.
 * The module will also recollect the discard buffer such as the unmatched and be discarded message.
 * @author ptrdu
 * @date 2015-1-12
 */
module router{
	uses{
		interface csInfo;
		interface pitInfo;
		interface fibInfo;
		interface Pool<message_t>;
		interface Queue<message_t*>;
		interface Receive as msgRec;
		interface Packet;
		interface AMPacket;
		};
}
implementation{
	message_t * ret;
	uint8_t len;
	
	/**
	 * the task deal with the received message
	 */
	task void route();
	
	event void csInfo.Dacollect(message_t* msg, error_t error){
		// TODO Auto-generated method stub
		if(error == SUCCESS){
			call Pool.put(msg);
			dbg("ROUTE","The node collect the data message :%p!\n",msg);
			if(!call Queue.empty()) post route();
		}
	}

	event void pitInfo.Dacollect(message_t* msg, error_t error){
		// TODO Auto-generated method stub
		if(error == SUCCESS){
			call Pool.put(msg);
			dbg("ROUTE","The node collect the data message %p!\n",msg);
			if(!call Queue.empty()) post route();
		}
	}

	event void fibInfo.Incollect(message_t* msg, error_t error){
		// TODO Auto-generated method stub
		if(error == SUCCESS){
			call Pool.put(msg);
			dbg("ROUTE","The node collect the interest message:%p!\n",msg);
			if(!call Queue.empty()) post route();
		}
	}

	event void pitInfo.Incollect(message_t* msg, error_t error){
		// TODO Auto-generated method stub
		if(error == SUCCESS){
			dbg("ROUTE","The node collect the interest message :%p!\n",msg);
			call Pool.put(msg);
			if(!call Queue.empty()) post route();
		}
	}

	event message_t * msgRec.receive(message_t* msg, void *payload, uint8_t length){
		// TODO Auto-generated method stub
		dbg("ROUTE","The node received a message!\n");
		if(call Pool.empty()) return msg;
		if(call Queue.enqueue(msg) == SUCCESS){
			//message_t * rec = call Pool.get();
			post route();
			return call Pool.get();
			}
		return msg;
	}
	
	
	
	event void csInfo.InDone(error_t error){
		// TODO Auto-generated method stub
		call pitInfo.In_queryPit(ret);
	}

	event void csInfo.DaDone(error_t error){
		// TODO Auto-generated method stub
		//if(error == SUCCESS) post CsDaCollect();
		if(error == SUCCESS) signal csInfo.Dacollect(ret, SUCCESS);
		else call pitInfo.Da_queryPit(ret);
	}

	event void pitInfo.DaDone(error_t error){
		// TODO Auto-generated method stub
		//post PitDaCollect();
		signal pitInfo.Dacollect(ret, SUCCESS);
	}

	event void pitInfo.InDone(error_t error){
		// TODO Auto-generated method stub
		if(error == SUCCESS){
			//post PitInCollect();
			signal pitInfo.Incollect(ret, SUCCESS);
		}else{
			call fibInfo.In_queryfib(ret);
		}
	}

	event void fibInfo.InDone(error_t error){
		// TODO Auto-generated method stub
		//post FibInCollect();
		signal fibInfo.Incollect(ret, SUCCESS);
	}
	
	task void CsDaCollect(){
		signal csInfo.Dacollect(ret, SUCCESS);
		}
		
	task void PitDaCollect(){
		signal pitInfo.Dacollect(ret, SUCCESS);
		}
		
	task void PitInCollect(){
		signal pitInfo.Incollect(ret, SUCCESS);
		}
		
	task void FibInCollect(){
		signal fibInfo.Incollect(ret, SUCCESS);
		}
		
	task void route(){
		if(call Queue.empty()) return;
	    ret = call Queue.dequeue();
		len = call Packet.payloadLength(ret);
		if(len == sizeof(In)){
			dbg("ROUTE","The node deal with a interest packet!\n");
			call csInfo.In_queryCS(ret);		
			return;
			}
		if(len == sizeof(Da)){
			dbg("ROUTE","The node deal with a Data packet!\n");
			call csInfo.Da_queryCS(ret);
			return ;
			}
		post route();
		return;
		}
}