#ifndef SENSOR_H
#define SENSOR_H
/**
 * the structure in the sensor node,it contains the information of the node and the 
 * structure in NDN: cs table,the pit table and fib table.
 * @author ptrdu
 * @date 2014-12-18
 */
 
 #include "message.h"
 
 /**
  * the structure of cs item,store the data packet pass through the node
  */
 typedef struct{
 	point location;
 	uint32_t time;
 	uint8_t dataType;
 	uint16_t data;
 	bool touched;
 }cs_it;
 
 /**
  * the structure store the data the node collect
  */
 typedef struct repository{
 	point location;
 	uint32_t time;
 	uint8_t dataType;
 	uint16_t data;
 }repo_it;
 
 /**
  * the pit item structure,store the interest packet pass through the node
  */
  typedef struct{
  	area range;
  	uint32_t start;
  	uint32_t end;
  	uint8_t dataType;//the type of the wanted data
  	//uint32_t liveTime;//the time the pit store in the pit table
  	bool touched;
  	uint16_t come_id;//the address where the packet come from;
  }pit_it;
  /**
   * the structure of the fib item.
   */
   typedef struct{
   	area range;//the range to judge where a interest packet should go. 
   	uint16_t go_id;//the address the packet be sent to
   	bool touched;
   }fib_it;
#endif /* SENSOR_H */
