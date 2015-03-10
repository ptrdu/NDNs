/**
 * @author ptrdu
 * @date 2015-1-12
 */
configuration repositoryP{
	provides{
		interface repoInfo;
		}
}
implementation{
	components repository;
	components new DemoSensorC(); //for debug
	components new TimerMilliC() as ReadTimer;
	components LowerC;
	
	
	//components new SensirionSht11C(); //for telosb
	//components new HamamatsuS1087ParC(); // for telosb
	
	repoInfo = repository.repoInfo;
	
	repository.LightRead -> DemoSensorC.Read;
	repository.HumidityRead -> DemoSensorC.Read;
	repository.TempRead -> DemoSensorC.Read;
	repository.readTimer -> ReadTimer;
	
	repository.gpsInfo -> LowerC.gpsInfo;
	
}