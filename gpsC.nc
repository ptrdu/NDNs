/**
 * this is just a test module,we now don't have the node which contains the gps module,
 * in order to test our program, i use this module to create some data about the gps,
 * i use a timer to produce the time and find some points in the google map as the positions
 * of the nodes
 * @author ptrdu
 * @date 2015-1-12
 */
module gpsC{
	provides interface gpsInfo;
	uses{
		interface Boot;
		interface Timer<TMilli> as testTimer; 
	}
}
implementation{
	
	point position;
	uint32_t time = 0;
	
	command point gpsInfo.position(){
		// TODO Auto-generated method stub
		return position;
	}

	command uint32_t gpsInfo.getTime(){
		// TODO Auto-generated method stub
		return time;
	}

	event void Boot.booted(){
		// TODO Auto-generated method stub
		dbg("GPS","The GPS module start!\n");
		switch(TOS_NODE_ID){
			case(1):
			position.Lon = 4369;
			position.Lat = 9767;
			break;
			case(2):
			position.Lon = 4629;
			position.Lat = 9346;
			break;
			case(3):
			position.Lon = 5582;
			position.Lat = 9926;
			break;
			case(4):
			position.Lon = 4683;
			position.Lat = 8840;
			break;
			case(5):
			position.Lon = 8492;
			position.Lat = 2150;
			break;
			case(6):
			position.Lon = 4018;
			position.Lat = 7825;
			break;
			case(7):
			position.Lon = 4998;
			position.Lat = 7666;
			break;
			case(8):
			position.Lon = 3129;
			position.Lat = 6194;
			break;
			case(9):
			position.Lon = 1961;
			position.Lat = 6836;
			break;
			case(10):
			position.Lon = 6588;
			position.Lat = 7880;
			break;
			case(11):
			position.Lon = 6776;
			position.Lat = 6304;
			break;
			case(12):
			position.Lon = 4926;
			position.Lat = 4044;
			break;
			case(13):
			position.Lon = 7998;
			position.Lat = 4306;
			break;
			case(14):
			position.Lon = 7881;
			position.Lat = 8502;
			break;
			case(15):
			position.Lon = 9004;
			position.Lat = 9090;
			break;
			case(16):
			position.Lon = 9714;
			position.Lat = 7037;
			break;
			case(17):
			position.Lon = 8609;
			position.Lat = 4645;
			break;
			case(18):
			position.Lon = 8321;
			position.Lat = 2723;
			break;
			case(19):
			position.Lon = 2896;
			position.Lat = 1216;
			break;
			case(20):
			position.Lon = 1063;
			position.Lat = 5419;
			break;
			}
			dbg("GPS","The location is:%d,%d\n",position.Lat,position.Lon);
			call testTimer.startPeriodic(360000);
	}

	event void testTimer.fired(){
		// TODO Auto-generated method stub
		time = (time+1)%24;
		dbg("GPS","The current time:%d!\n",time);
	}
}