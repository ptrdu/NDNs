NDNs
===================


This project is a attempt of NDN architecture in Wireless Sensor Network,The NDNs means NDN for Sensor Network.In this project,we design a NDN based architecture and implements the main protocols in Tinyos operation system.
The hardware we test the project is Telosb,the program language is NesC.

----------


Contains
-------------
In this project we implements the basic rules in the NDN architecture.In order to let the NDN suit for the Wireless Sensor network,we change some fundamental strategy and add some new features.
One of the key feature of the project in this project is its naming scheme.In this project we use latitude and longitude and time information  naming the data .
The network topology will also change automatically because in the sensor network the node are not stable,this is a another advantage in our project.
  
  

More details please refer to the <a herf="http://www.ptrdu.com/?p=225">the NDNs project</a>.

----------


How to test this project
-------------------

In this project,we program a simulate test,the test and others files.In this simulation we set a node as the message sender,it will send the message for a range(the data in a area and collected at a periodic time) of data and receive the data packet.

> **how to Compile:**

> - Download the project,enter the folder and make the project in the bash:
> >-make micaz sim 
> 
> - run the simulation program:
> > -python test.py
> 
Then the bash will print the test data.
