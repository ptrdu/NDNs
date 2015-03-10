module testC{
	uses interface start;
	uses interface Boot;	
	uses interface SplitControl as AMControl; 
	//for test
	uses interface AMSend;
	uses interface Packet;
	uses interface Timer<TMilli> as testTimer; 
}
implementation{
	
    message_t packet;
    
	event void Boot.booted(){
		// TODO Auto-generated method stub
		call AMControl.start();
	}

	event void AMControl.startDone(error_t error){
		// TODO Auto-generated method stub
		if(error != SUCCESS) call AMControl.start();
		call start.start(1);
		if(TOS_NODE_ID ==1 ) call testTimer.startPeriodic(10000000);	
	}

	event void AMControl.stopDone(error_t error){
		// TODO Auto-generated method stub
	}

	event void AMSend.sendDone(message_t *msg, error_t error){
		// TODO Auto-generated method stub
	}

	event void testTimer.fired(){
		// TODO Auto-generated method stub
		if(TOS_NODE_ID == 1){
			In * Atest = (In*)(call Packet.getPayload(&packet, sizeof(In)));
			Atest->range.downLeft.Lon = 6588;
			Atest->range.downLeft.Lat = 7880;
			Atest->range.upRight.Lon = 6588;
			Atest->range.upRight.Lat = 7880;
			Atest->start = 10;
			Atest->end = 15;
			Atest->type = IN;
			Atest->dataType = Light;
			if(call AMSend.send(2, &packet, sizeof(In)) == SUCCESS){
				dbg("TEST","Node 1 send the test interest packet!\n");
				}
		}
	}
}