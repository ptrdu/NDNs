/**
 * this module implements the operations below.
 * <1>read data using the sensor and store them in the repository table
 * <2>provides the data to the cs table 
 * @author ptrdu
 * @date 2014-12-25
 */
#define READTIME 360000
module repository{
	provides{
		interface repoInfo;
		}
	uses{
		interface gpsInfo;
		interface Timer<TMilli> as readTimer; //the timer used to collect the data periodic 
		//the read to read the sensor data
		interface Read<uint16_t> as LightRead;
		interface Read<uint16_t> as TempRead;
		interface Read<uint16_t> as HumidityRead;
		}
}
implementation{
	// the size of the repository table	
	enum{
		LIGTHSIZE=24,
		TEMPSIZE=24,
		HUMSIZE=24,
	};
	
	uint32_t time;
	point position;
	
	//the repository table 
	repo_it lightTable[LIGTHSIZE];
	repo_it tempTable[TEMPSIZE];
	repo_it humTable[HUMSIZE];
	
	// the number of every table
	uint8_t lightNum = 0;
	uint8_t tempNum = 0;
	uint8_t humNum = 0;
	
	uint8_t lflag = 0;
	uint8_t tflag = 0;
	uint8_t hflag = 0;
	
	//the current type the sensor should read
	uint8_t currentType = Light;
	 
	event void readTimer.fired(){
		// read the data from the sensor
		switch(currentType){
			case(Light):
			call LightRead.read();
			currentType = Temp;
			break;
			case(Temp):
			call TempRead.read();
			currentType = Humidity;
			break;
			case(Humidity):
			call HumidityRead.read();
			currentType = Light;
			break;
			}
	}

	event void LightRead.readDone(error_t result, uint16_t val){
		// TODO Auto-generated method stub
		if(result == SUCCESS){
			if(lightNum >= LIGTHSIZE){
				lflag = (uint8_t)(lflag % LIGTHSIZE);
				lightNum = LIGTHSIZE;
				}
			lightTable[lflag].dataType = Light;
			lightTable[lflag].data = val;
			lightTable[lflag].location = call gpsInfo.position();
			lightTable[lflag].time = call gpsInfo.getTime();
			lflag++;
			lightNum++;
			dbg("REPO","Get a new Light data:%d/%d!\n",lightTable[lflag-1].data,lightTable[lflag-1].time);
			dbg("REPO","The number of item in Light table:%d!\n ",lightNum);
		}
	}

	event void TempRead.readDone(error_t result, uint16_t val){
		// TODO Auto-generated method stub
		if(result == SUCCESS){
			if(tempNum >= TEMPSIZE){
				tflag = (uint8_t)(tflag % TEMPSIZE);
				tempNum = TEMPSIZE;
				}
			tempTable[tflag].dataType = Temp;
			tempTable[tflag].data = val;
			tempTable[tflag].location = call gpsInfo.position();
			tempTable[tflag].time = call gpsInfo.getTime();
			tflag++;
			tempNum++;
			dbg("REPO","Get a new Temperatrue data:%d/%d!\n",tempTable[tflag-1].data,tempTable[tflag-1].time);
			dbg("REPO","The number of item in Temperatrue table:%d!\n ",tempNum);
		}
	}

	event void HumidityRead.readDone(error_t result, uint16_t val){
		// TODO Auto-generated method stub
		if(result == SUCCESS){
			if(humNum >= HUMSIZE){
				hflag = (uint8_t)(hflag % LIGTHSIZE);
				humNum = HUMSIZE;
				}
			humTable[hflag].dataType = Humidity;
			humTable[hflag].data = val;
			humTable[hflag].location = call gpsInfo.position();
			humTable[hflag].time = call gpsInfo.getTime();
			hflag++;
			humNum++;
			dbg("REPO","Get a new Humidity data:%d/%d!\n",humTable[hflag-1].data,humTable[hflag-1].time);
			dbg("REPO","The number of item in Light table:%d!\n ",humNum);
		}
	}

	command repo_it * repoInfo.getTemp(){
		// TODO Auto-generated method stub
		return tempTable;
	}

	command repo_it * repoInfo.getLight(){
		// TODO Auto-generated method stub
		return lightTable;
	}

	command uint8_t repoInfo.humNum(){
		// TODO Auto-generated method stub
		return humNum;
	}

	command uint8_t repoInfo.lightNum(){
		// TODO Auto-generated method stub
		return lightNum;
	}

	command repo_it * repoInfo.getHum(){
		// TODO Auto-generated method stub
		return humTable;
	}

	command uint8_t repoInfo.tempNum(){
		// TODO Auto-generated method stub
		return tempNum;
	}

	command void repoInfo.start(){
		// TODO Auto-generated method stub
		dbg("REPO","repository module start!\n");
		call readTimer.startPeriodic(READTIME);
	}
}