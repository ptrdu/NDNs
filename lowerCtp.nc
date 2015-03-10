/**
 * this interface provides the commands handle the ctp 
 * protocol in the lower layer,and implemented in the LowerP
 * module
 * @author ptrdu
 * @date 2014-12-19 
 */
interface lowerCtp {
	/**
	 * start the ctp protocol
	 * @return error_t : SUCCESS if start success else FAILED
	 */
	command error_t ctpStart();
	/**
	 * set the root of the tree
	 * @param rootId : the id of the root node
	 * @return void. 
	 */
	command void setRoot(uint16_t rootId);
	/**
	 * get the node's parent node in the tree
	 * @return uint16_t : the node id of the parent node
	 */
	command uint16_t getParent();
}