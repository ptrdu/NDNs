/**
 * the interface get the cs information in the cs table
 * @author ptrdu
 * @date 2014-12-22
 */
#include "sensor.h"
#include <message.h>
#include <TinyError.h>
interface csInfo{
	/**
	 * initialize the cs table
	 */
	 
	command void init();
	
	/**
	 * the all the cs item in the cs Table
	 * @return cs_it * : the cs table's address
	 */
	 
	command cs_it * getAll();
	
	/**
	 * get the cs number in the cs table
	 * @return uint8_t : the number of cs item in the cs table
	 */
	 
	command uint8_t getNum();
	
	/**
	 * query the cs table when get an interest packet
	 * @param msg : the received interest packet
	 * @return bool : FALSE(for the reason that we need search for a range of data not
	 * 						just one)
	 */
	 
	command bool In_queryCS(message_t* msg);
	
	/**
	 * return the size of the cs table
	 * @return uint8_t : the size of the cs table
	 */
	 
	command uint8_t csSize();
	
	/**
	 * query the cs table when get an data packet
	 * @param msg : the received Data packet
	 * @return bool : TRUE:if find the matched item
	 * 				  FALSE:cannot find the matched item
	 */
	 
	command bool Da_queryCS(message_t* msg);
	
	/**
	 * refresh the cs table
	 */
	 
	command void fresh();
	
	/**
	 * collect the message_t buffer after send the packet
	 * @param msg :the pointer of the received data message;
	 * @param error :
	 */
	 
	event void Dacollect(message_t* msg, error_t error);
	/**
	 * The event when the complete the operations in the cs module when get a data packet such as
	 * query the cs table then discard the packet or store the packet
	 * @param error : SUCCESS 
	 */
	event void DaDone(error_t error);
	/**
	 * The event when the complete the operations in the cs module when get a Interest packet such as
	 * query the cs table then send a data packet query the pit table
	 * @param error :
	 */
	event void InDone(error_t error);
}