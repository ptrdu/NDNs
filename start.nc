#include "sensor.h"
interface start{
	/**
	 * the command start the whole network
	 * @param root : the id of the node as the root of the tree network 
	 * @return SUCCESS : start success
	 * 		   FAIL: start failed 
	 */
	command error_t start(uint16_t root);
}