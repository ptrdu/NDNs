#ifndef MESSAGE_H
#define MESSAGE_H

/**
 * define the struct in the message
 * @author ptrdu
 * @date 2014-12-18
 */

/**
 * the type of the data sensors collect
 */
enum dataType {
	Light = 0x11,
	Temp = 0x12,
	Humidity = 0x13,
};
/**
 * the type of the message in the radio
 */
enum msgType{
	BRO = 0x00,
	IN = 0x01,
	DATA = 0x02
};
/**
 * this structure describe a point in the map
 */
typedef struct {
	uint32_t Lon;//longitude
	uint32_t Lat;//latitude
} point;
/**
 * this structure use to point to describe a rectangle area
 */
typedef struct {
	point downLeft;//the upper left point in the area
	point upRight;//the lower right point in the area
} area;
/**
 * the structure of Interest packet,it contains the area field,the start time 
 * and end time describe a period.user can set the area field to get the
 * data in this area,set the period field to get the data in this period.
 */
typedef struct Interest {
	area range;//the range 
	uint32_t start;//the start time
	uint32_t end;//the end time
	uint8_t type;//the type of Interest packet
	uint8_t dataType;
} In;
/**
 * the structure of Data packet.The location is the node's position which collect 
 * the data.The time field is the time when the node get the data. The dataType 
 * is the type of the data collected.And the data is the raw data.
 */
typedef struct Data {
	point location;//node's position
	uint32_t time;
	uint8_t type;//the type of Data Packet
	uint8_t dataType;
	uint16_t data;
} Da;
/**
 * the structure of the broadcast packet in the radio.it contains the range
 * of the node.This packet be sent to the parent node to calculate the range of 
 * the parent's range
 */
typedef struct Broadcast{
	area range;//node's position
	uint8_t type;//the type of BRO Packet
}Bro;
#endif /* MESSAGE_H */
