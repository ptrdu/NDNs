/**
 * the interface provides the commands get the information in
 * the NDN topology based on the lower ctp layer
 * @author ptrdu
 * @date 2014-12-19
 */
#include "sensor.h"
interface upperNDN {
	/**
	 * get the range of the area the node,the range is a attribute of the
	 * node.every node has its' range,it is a rectangle area present the node's
	 * manage scope.we use the range to judge where a interest packet should be 
	 * sent.
	 * @return area : the range of the node.  
	 */
	command area getRange();
	/**
	 * get the sons of the node.
	 * @return uint16_t *: the array of the son-node's id
	 */
	command uint16_t * getSons();
	/**
	 * refresh the ndn network
	 */
	command void netFresh();
	/**
	 * get the number of the node's sons
	 * @return uint8_t : the number of this node's sons
	 */
	command uint8_t sonNum();
	/**
	 * initialize the ndn network
	 */
	command void init();
}