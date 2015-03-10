#define MSGLINE 0x11
configuration testAppC{
}
implementation{
	components testC;
	components MainC;
	components netStart;
	components ActiveMessageC;
	components new AMSenderC(MSGLINE) as testSender;
	components new TimerMilliC() as ReadTimer;
	
	testC.start -> netStart.start;
	testC.AMControl -> ActiveMessageC;
	
	testC.Boot -> MainC;
	testC.AMSend -> testSender;
	testC.Packet -> testSender;
	testC.testTimer -> ReadTimer;
	
}