#!/bin/bash

##variable go here 

read_pmtr()
{
	set -x
	echo $0
	#	get the real path of the script run
	script_name=`realpath $0`
	pth=`dirname $script_name`
	export base_pth=$pth/..
	#	read the values from the config file into environment
	#	the following line is equivalent to 'source config_file.cfg' 
	. $base_pth/cfg/env.cfg
	export logfile=$base_pth/log/boot-load-`date +"%s"`.log
}


echof()
{
	echo ---------------------------------------------------- >> $logfile
	echo $@ >> $logfile
	echo ---------------------------------------------------- >> $logfile
}


call_chrome()
{
	#	kill process for displaying images
	sudo pkill fbi
	#	kill process for playing videos
	sudo pkill omx
	#	check if chrome is running already
	rn_cnt=`ps -ef | grep chromium | wc -l`
	if [ $rn_cnt -gt 1 ]
	then
		echof chrome running successfully `date`
	else	
		#starting chrome in kiosk mode
		export DISPLAY=:0 && /usr/bin/chromium-browser --kiosk --incognito $url &
		echof chrome started code $? Time `date`
	fi
}


#main()
#reading and exporting environment variables
read_pmtr
pkill chromium

#calling chrome - this is always run in background - i.e. if any of the audio/vedio/image fails to load 
#dashboard will always be displayed
call_chrome



##for playing adds according to a event file
echof starting the schedule for images and videos `date` 
sh -vx $base_pth/scripts/rds-play-schdule.sh 

