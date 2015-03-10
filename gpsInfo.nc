/**
 * the gps interface,we can get the information form it,such as
 * the position and the time
 * @author ptrdu
 * @date 2014-12-22
 */
 #include "sensor.h"
interface gpsInfo{
	/**
	 * the the current time
	 * @return uint32_t : the current time
	 */
	command uint32_t getTime();
	/**
	 * the position of the node
	 * @return point : the position of the node
	 */
	command point position();
}