/**
 * the module implements the interface nodeInfo 
 * @author ptrdu
 * @date 2015-1-13
 */
module nodeC{
	provides interface nodeInfo;
	uses{
		interface csInfo;
		interface pitInfo;
		interface gpsInfo;
		interface fibInfo;
		interface repoInfo;
	}
}
implementation{

	command fib_it * nodeInfo.getFib(){
		// TODO Auto-generated method stub
		return call fibInfo.getAll();
	}

	command cs_it * nodeInfo.getCs(){
		// TODO Auto-generated method stub
		return call csInfo.getAll();
	}

	command point nodeInfo.getPosition(){
		// TODO Auto-generated method stub
		return call gpsInfo.position();
	}

	command pit_it * nodeInfo.getPit(){
		// TODO Auto-generated method stub
		return call pitInfo.getAll();
	}

	event void csInfo.Dacollect(message_t *msg, error_t error){
		// TODO Auto-generated method stub
	}

	event void pitInfo.Dacollect(message_t *msg, error_t error){
		// TODO Auto-generated method stub
	}

	event void fibInfo.Incollect(message_t *msg, error_t error){
		// TODO Auto-generated method stub
	}

	event void pitInfo.Incollect(message_t *msg, error_t error){
		// TODO Auto-generated method stub
	}

	command repo_it * nodeInfo.getLightRepo(){
		// TODO Auto-generated method stub
		return call repoInfo.getLight();
	}

	command repo_it * nodeInfo.getTempRepo(){
		// TODO Auto-generated method stub
		return call repoInfo.getTemp();
	}

	command repo_it * nodeInfo.getHumRepo(){
		// TODO Auto-generated method stub
		return call repoInfo.getHum();
	}

	event void csInfo.DaDone(error_t error){
		// TODO Auto-generated method stub
	}

	event void pitInfo.InDone(error_t error){
		// TODO Auto-generated method stub
	}

	event void csInfo.InDone(error_t error){
		// TODO Auto-generated method stub
	}

	event void pitInfo.DaDone(error_t error){
		// TODO Auto-generated method stub
	}

	event void fibInfo.InDone(error_t error){
		// TODO Auto-generated method stub
	}
}