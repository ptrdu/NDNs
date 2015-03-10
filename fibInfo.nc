/**
 * the interface gets the basic information about the fib and 
 * completes the operation of the fib table.
 * @author ptrdu
 * @date 2014-12-25
 */
#include "sensor.h"
#include <message.h>
#include <TinyError.h>
interface fibInfo{
	/**
	 * initialize the fib table
	 */
	command void init();
	
	/**
	 * the all the fib item in the fib Table
	 * @return fib_it * : the fib table's address
	 */
	command fib_it * getAll();
	
	/**
	 * get the fib number in the fib table
	 * @return uint8_t : the number of fib item in the fib table
	 */
	 
	command uint8_t getNum();
	
	/**
	 * query the fib table when get an interest packet
	 * @param msg : the received interest packet
	 * @return bool : FALSE(for the reason that we need search for a range of data not
	 * 						just one)
	 */
	 
	command bool In_queryfib(message_t* msg);
	
	/**
	 * return the size of the fib table
	 * @return uint8_t : the size of the fib table
	 */
	 
	command uint8_t fibSize();
	
	/**
	 * refresh the fib table
	 */
	 
	command void fresh();
	
	/**
	 * collect the message_t buffer after send the packet
	 * @param msg :the pointer of the received interest message;
	 * @param error : 
	 */
	 
	event void Incollect(message_t* msg, error_t error);
	/**
	 * the event signaled when the module complete the operation in the fib module
	 * @param error :
	 */
	event void InDone(error_t error);
}