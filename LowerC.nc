/**
 * this configuration wire the module and interface in a 
 * components, it provides the interface lowerCtp,upperNDN and the gpsInfo.
 * @author ptrdu
 * @date 2014-12-19 
 */
#define BROLINE 0x12
#define FIBLINE 0x13

configuration LowerC{
	provides{
		interface lowerCtp;
		interface upperNDN;
		interface gpsInfo;
		}
}
implementation{
	components LowerP;
	components upperC;
	components CollectionC as Collector;
	components gpsC;
	components nodeC;
	
	components new AMSenderC(BROLINE) as BroSender;
	components new AMReceiverC(BROLINE) as BroReceiver;
	
	components new AMSenderC(FIBLINE) as FibSender;
	
	components new TimerMilliC() as BroTimer;
	components new TimerMilliC() as FibTimer;
	//this components for test
	components new TimerMilliC() as testTimer;
	
	components MainC;
	
	
	
	lowerCtp = LowerP.lowerCtp;
	upperNDN = upperC.upperNDN;
	gpsInfo = gpsC.gpsInfo;
	
	LowerP.RootControl -> Collector;
	LowerP.RoutControl -> Collector;
	LowerP.CtpInfo -> Collector;
	
	upperC.broSend -> BroSender.AMSend;
	upperC.broRec -> BroReceiver.Receive;
	upperC.AMPacket -> BroReceiver.AMPacket;
	upperC.Packet -> BroReceiver.Packet;
	
	upperC.createFib -> FibSender.AMSend;
	upperC.broTime -> BroTimer;
	upperC.FibTimer ->FibTimer;
	upperC.lowerCtp -> LowerP.lowerCtp;
	upperC.nodeInfo -> nodeC.nodeInfo;
	
	//for test
	gpsC.testTimer -> testTimer;
	gpsC.Boot -> MainC.Boot;
	
	
}