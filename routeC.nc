/**
 * the configuration wire the modules and provides the interface fibInfo,csInfo,pitInfo  
 * @author ptrdu
 * @date 2015-1-12
 */
#define MSGLINE 0x11
#define FIBLINE 0x13

configuration routeC{
	provides{
		interface fibInfo;
		interface csInfo;
		interface pitInfo;
		}
}
implementation{
	components fibC,csC,pitC;
	components router;
	components repositoryP;
	
	//components new AMSenderC(MSGLINE) as MsgSender;
	components new AMReceiverC(MSGLINE) as MsgReceiver;
	/*************************************************************/
	/*
	 * Here i use the different AMSenderC components and AMReceiveC components,
	 * At the beginning,i use just one component--AMSenderC,and wire all the AMSend interface 
	 * in the cs fib pit module to it.
	 * But it encounter some problems in the TOSSIM simulation.For example the node 1's task 
	 * will be linked to the node 2.I waste much time to fix this bug,then i realize in the TOSSIM,the same 
	 * components may instantiate just one object,but in the truly network the component in
	 * different nodes,they are independent.So i add the other components such as PITSender, 
	 * CSSender for simulation.
	 */
	components new AMSenderC(MSGLINE) as CSSender;
	components new AMReceiverC(MSGLINE) as CSReceiver;
	
	components new AMSenderC(MSGLINE) as PITSender;
	components new AMReceiverC(MSGLINE) as PITReceiver;
	
	components new AMSenderC(MSGLINE) as FIBSender;
	components new AMReceiverC(MSGLINE) as FIBReceiver;
	/*************************************************************/
	components new AMReceiverC(FIBLINE) as FibReceiver;
	
	components new TimerMilliC() as csTimer;
	components new TimerMilliC() as fibTimer;
	components new TimerMilliC() as pitTimer;
	
	components new PoolC(message_t,30);
	components new QueueC(message_t*,30);
	
	fibInfo = fibC;
	csInfo = csC;
	pitInfo = pitC;
	
	router.msgRec -> MsgReceiver.Receive;
	router.AMPacket -> MsgReceiver.AMPacket;
	router.Packet -> MsgReceiver.Packet;
	
	router.csInfo -> csC.csInfo;
	router.fibInfo -> fibC.fibInfo;
	router.pitInfo -> pitC.pitInfo;
	
	router.Pool -> PoolC;
	router.Queue -> QueueC;
	
	csC.DataSend -> CSSender.AMSend;
	csC.Packet -> CSReceiver.Packet;
	csC.AMPacket -> CSReceiver.AMPacket;
	csC.csFreshTimer -> csTimer;
	csC.repoInfo -> repositoryP.repoInfo;
	
	fibC.Transmit -> FIBSender.AMSend;
	fibC.Packet -> FIBReceiver.Packet;
	fibC.AMPacket -> FIBReceiver.AMPacket;
	fibC.fibRefresh -> fibTimer;
	
	fibC.FibRec -> FibReceiver.Receive;
	
	pitC.pitSend -> PITSender.AMSend;
	pitC.Packet -> PITReceiver.Packet;
	pitC.AMPacket -> PITReceiver.AMPacket;
	pitC.pitFreshTimer -> pitTimer;
	
}