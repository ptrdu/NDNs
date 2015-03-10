/**
 * the module implements the interface start
 * @author ptrdu
 * @date 2015-1-13
 */
module network{
	provides{
		interface start;
		}
	uses{
		interface lowerCtp;
		interface upperNDN;
		interface repoInfo;
		interface csInfo;
		interface pitInfo;
		interface fibInfo;
	}
}
implementation{

	command error_t start.start(uint16_t root){
		// TODO Auto-generated method stub
		if(call lowerCtp.ctpStart() == SUCCESS){
			call lowerCtp.setRoot(root);
			call upperNDN.init();
			call repoInfo.start();
			call csInfo.init();
			call fibInfo.init();
			call pitInfo.init();
			return SUCCESS;
			}
		return FAIL;
	}

	event void pitInfo.Incollect(message_t *msg, error_t error){
		// TODO Auto-generated method stub
	}

	event void pitInfo.Dacollect(message_t *msg, error_t error){
		// TODO Auto-generated method stub
	}

	event void fibInfo.Incollect(message_t *msg, error_t error){
		// TODO Auto-generated method stub
	}

	event void csInfo.Dacollect(message_t *msg, error_t error){
		// TODO Auto-generated method stub
	}

	event void csInfo.DaDone(error_t error){
		// TODO Auto-generated method stub
	}

	event void csInfo.InDone(error_t error){
		// TODO Auto-generated method stub
	}

	event void pitInfo.DaDone(error_t error){
		// TODO Auto-generated method stub
	}

	event void pitInfo.InDone(error_t error){
		// TODO Auto-generated method stub
	}

	event void fibInfo.InDone(error_t error){
		// TODO Auto-generated method stub
	}
}