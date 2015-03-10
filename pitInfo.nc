/**
 * the interface get the information about the pit table
 * @author ptrdu
 * @date 2014-12-23
 */
#include "sensor.h"
#include <message.h>
#include <TinyError.h>
interface pitInfo{
	/**
	 * initialize the pit table
	 */
	command void init();
	/**
	 * the all the pit item in the pit Table
	 * @return pit_it * : the pit table's address
	 */
	command pit_it * getAll();
	/**
	 * get the pit number in the pit table
	 * @return uint8_t : the number of pit item in the pit table
	 */
	command uint8_t getNum();
	/**
	 * query the pit table when get an interest packet
	 * @param msg : the received interest packet
	 * @return bool : TRUE:find the matched item
	 * 				  FALSE:cannot find the matched item
	 */
	command bool In_queryPit(message_t* msg);
	/**
	 * return the size of the pit table
	 * @return uint8_t : the size of the pit table
	 */
	command uint8_t pitSize();
	/**
	 * query the pit table when get an data packet
	 * @param msg : the received Data packet
	 * @return false : always return false because we want to get a range of data
	 */
	command bool Da_queryPit(message_t* msg);
	/**
	 * refresh the pit table
	 */
	command void fresh();
	/**
	 * collect the message_t buffer after the msg discarded.
	 * @param msg :the pointer of the received interest message;
	 * @param error : 
	 */
	event void Incollect(message_t* msg, error_t error);
	/**
	 * collect the message_t buffer after the msg discarded.
	 * @param msg :the pointer of the received data message;
	 * @param error :
	 */
	event void Dacollect(message_t* msg, error_t error);
	/**
	 * the event signaled when the node complete the operations in the pit module  when get a
	 * Interest packet 
	 * @param error :
	 */
	event void InDone(error_t error);
	/**
	 * The event signaled when when the node complete the operations in the pit module  when get a
	 * Data packet 
	 * @param error :
	 */
	event void DaDone(error_t error);
}