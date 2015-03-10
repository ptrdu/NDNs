/**
 * the interface to get the basic structure in a node
 * @author ptrdu
 * @date 2014-12-18
 */
#include "sensor.h"
interface nodeInfo {
	/**
	 * get the position of the node
	 * @return point : the position of the node
	 */
	command point getPosition();
	/**
	 * get the cs table in the node
	 * @return cs_it* : the address of the cs table
	 */
	command cs_it * getCs();
	/**
	 *get the pit table in the node
	 * @return pit_it* : the address of the pit table
	 */
	command pit_it * getPit();
	/**
	 * get the fib table in the node
	 * @return fib_it* : the address of the fib table
	 */
	command fib_it * getFib();
	/**
	 * get the light repository table in the node
	 * @return repo_it* : the address of the repository table
	 */
	command repo_it * getLightRepo();
	/**
	 * get the humidity repository table in the node
	 * @return repo_it* : the address of the repository table
	 */
	command repo_it * getHumRepo();
	/**
	 * get the temperature repository table in the node
	 * @return repo_it* : the address of the repository table
	 */
	command repo_it * getTempRepo();
}