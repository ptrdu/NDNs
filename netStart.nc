/**
 * the configuration provides two interface -- start and nodeInfo
 * @author ptrdu
 * @date 2015-1-13
 */
configuration netStart{
	provides{
		interface start;
		interface nodeInfo;
		}
}
implementation{
	components routeC;
	components network;
	
	components LowerC;
	components repositoryP;
	components nodeC;
	
	start = network.start;
	nodeInfo = nodeC.nodeInfo;
	
	network.csInfo -> routeC.csInfo;
	network.fibInfo -> routeC.fibInfo;
	network.pitInfo -> routeC.pitInfo;
	network.lowerCtp -> LowerC.lowerCtp;
	network.upperNDN -> LowerC.upperNDN;
	network.repoInfo -> repositoryP.repoInfo;
	
	nodeC.csInfo -> routeC.csInfo;
	nodeC.fibInfo -> routeC.fibInfo;
	nodeC.pitInfo -> routeC.pitInfo;
	nodeC.repoInfo -> repositoryP.repoInfo;
	nodeC.gpsInfo -> LowerC.gpsInfo;
	
}