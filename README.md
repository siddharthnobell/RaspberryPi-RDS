# RaspberryPi-RDS
This repository is for a raspberry digital signage solution software 
IOT Based Digital Signage Solution

-------------------------------------------------------
Contents
-------------------------------------------------------
1.	Introduction
2.	Technology Stack
3.	Hardware Stack
4.	Software Components
5.	Server Components
6.	Architecture Diagram
7.	Market Segment 
_______________________________________________________
-------------------------------------------------------
Introduction
-------------------------------------------------------
The digital signage solution project uses raspberry pi b3 model that is a opensource easy to program and reconfigure arm based mini compute device. More at https://www.linkedin.com/pulse/shell-scripting-lightweight-raspberry-pi-solution-siddharth-nobell/ 
_______________________________________________________
-------------------------------------------------------
Technology Stack 
-------------------------------------------------------
Since the solution is based on a mini arm based processor hence the entire solution is built in shell script and python script (native support to Unix) over light weight Raspbian OS (Debian Linux for arm based systems). The solution uses a media server that is hosted in cloud and the Raspberry nodes interact with the cloud server with shell/python scripts. 
The monitoring and scheduling applications are written in node js/java and html 5. 

________________________________________________________
-------------------------------------------------------
Hardware Stack 
-------------------------------------------------------
1.	Raspberry Pi 3 model B
2.	Raspberry Pi 3 Case
3.	16 GB class 10 micro HD card
4.	Generic HDMI TO HDMI CABLE
5.	USB Adapter for Raspberry Pi
6.	Any Monitor/TV up to 1080p Resolution supported
________________________________________________________
-------------------------------------------------------
Software Components 
-------------------------------------------------------
1.	FTP Script – The script is part of the raspberry node and is scheduled as a cron job on raspberry pi nodes. This script as per its configuration download the content and schedule from the media server.  
2.	Heart beat script – The script resides raspberry pi node, this script creates a heart beat in the media server. The heart beat is monitored in the monitoring console and if the heat beat is created in a specific time interval then the monitoring console reports the raspberry node as inactive. This is also a cron job that is scheduled at the startup of each raspberry pi. 
3.	Boot up dashboard script – Boot up dashboard script is a startup cron job and it opens the chromium browser with the specific start url. It also start the event playing script.
4.	Event playing script – Event playing script is part of the raspberry package and is responsible for playing media as per the schedule file. This script also checks and restarts the chrome if it crashes.  
5.	Cron Scheduling setup – This is part of raspberry pi and is standard cron schedule file used in any Linux/Unix. 
6.	VNC setup on Raspberry pi – This service is part of Raspbian OS and is part of the raspberry package. This service provides remote access to raspberry pi nodes.
7.	VNC viewer – Remote access viewer for raspberry pi device. This software provides free access up to five devices.
8.	Monitoring Dashboard – Dashboard is a web application hosted over the cloud media server and is used to monitor the raspberry pi nodes over a single web dashboard. This check if the device is active.
9.	Event File Creation Dashboard – dashboard is used to create schedule file and is hosted over the cloud media server. This application provides easy to schedule interface for the users and does not require any specific training. 
 
________________________________________________________
-------------------------------------------------------
Server Components
-------------------------------------------------------
1.	FTP server – Over cloud and is used for storing media and schedule file. 
2.	VNC server – Over cloud and is used for remote access to the raspberry pi nodes.
3.	SSH server – required for VNC server remote installed in raspberry pi nodes 
4.	Web Server – Over cloud and is used for dashboard of schedule creation and the monitoring console.
________________________________________________________

-------------------------------------------------------
Market Segment
-------------------------------------------------------
The product can be used to replace any costly Digital Signage Solution as current proposed solution is built over a cost effective mini pc and can play any type of content (web pages, images, videos).
RDS can be used in Public Information Display as well and is currently being used in Kolkata for displaying Bus information at bus stops.
________________________________________________________

-------------------------------------------------------
References
-------------------------------------------------------
https://www.thingbits.net/products/raspberry-pi-3?gclid=EAIaIQobChMIy--LoPHm2QIVTyQrCh0b-wbCEAQYASABEgKrC_D_BwE  (Official partner of raspberry pi organisation in India)
raspberrypi.org
________________________________________________________
