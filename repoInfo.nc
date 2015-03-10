/**
 * the interface get the item store in the repository table
 * @author ptrdu
 * @date 20114-12-22
 */
#include "sensor.h"
interface repoInfo{
	/**
	 * get the light item in the repository 
	 * @return repo_it * : the pointer of the light table
	 */
	command repo_it * getLight();
	/**
	 * get the number of the items in the light table
	 * @return uint8_t : the number of light items in the table 
	 */
	command uint8_t lightNum();
	/**
	 * get the temperature item in the repository
	 * @return repo_it * : the pointer of the temperature table
	 */
	command repo_it * getTemp();
	/**
	 * get the temperature item in the repository
	 * @return uint8_t : the number of temperature items in the table
	 */
	command uint8_t tempNum();
	/**
	 * get the Humidity item in the repository
	 * @return repo_it * : get the pointer of the humidity table
	 */
	command repo_it * getHum();
	/**
	 * get the number of humidity items in the table
	 * @return uint8_t * : the number of humidity items
	 */
	command uint8_t humNum();
	/**
	 * start collect the sensor's data
	 */
	command void start();
	
}