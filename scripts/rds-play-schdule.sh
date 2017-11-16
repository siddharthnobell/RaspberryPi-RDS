#########################################################
## 	This script reads the config file for the day and play the envents using the main boot-load script
##	Logic for playing the events goes as below
##		S1. check if the event file exists and is readable 
##		S2. if not exit and pathodish dasboard play for the day
##		S3. if yes find the even to be played in current minute
##		S4. if there is event for the minute then pay it using V or I flag accordingly for n minutes slot decided by start and end time
##		S5. if while playing the video or image file is not found then error is logged - pathodisha dashboard is displayed
##		S6. If end time is less that the start time then nothing is played error is logged - pathodisha dashboard is displayed


##function definition go below
#checking if the config file exist
read_pmtr()
{
	set -x
	script_name=`realpath $0`
	pth=`dirname $script_name`
	export base_pth=$pth/..
	. $base_pth/cfg/env.cfg
	export logfile=$base_pth/log/check-ftp-`date +"%s"`.log
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



check_cfg()
{
	#	check if schedule config file is readable
	if [ ! -r $sch_cfg_file ]
	then
		echof error reading $base_pth/script/$sch_cfg_file - pathodisha dashboard will be displayed only
		exit
	fi
}




play_sch()
{
	yr=`date +"%y"`
	mnth=`date +"%m"`
	day=`date +"%d"`
	while true 
	do
	    #defining mins and hours
		hr=`date +"%H"`
		mins=`date +"%M"`
		secs='date +"%S"'
		evt_ply_f=`grep ^"$hr:$mins" $sch_cfg_file | wc -l`
		if  [ $evt_ply_f -gt 0 ]
		then
			#defining event variables from cfg file
			evt=`grep ^"$hr:$mins" $sch_cfg_file`
			sch_hr_strt=`echo $evt | cut -d"," -f1 | cut -d":" -f1`
			sch_hr_end=`echo $evt | cut -d"," -f2 | cut -d":" -f1`
			sch_mins_strt=`echo $evt | cut -d"," -f1 | cut -d":" -f2`
			sch_mins_end=`echo $evt | cut -d"," -f2 | cut -d":" -f2`
			type=`echo $evt | cut -d"," -f3`
			file_nm=`echo $evt | cut -d"," -f4` 
			#converting the times in second for time calulations 
			e_evt_str=$(date -d "20$yr-$mnth-$day $sch_hr_strt:$sch_mins_strt:00" +"%s")
			e_evt_end=$(date -d "20$yr-$mnth-$day $sch_hr_end:$sch_mins_end:00" +"%s")
			slp_slt=`expr $e_evt_end - $e_evt_str` #sleep secns 
			
			if [ $slp_slt -lt 0 ]
			then
				echof incorrect start end time  `date` pathodisha dashboard will be played for next one minute
				sleep 60
			else
			    #starting the play functions
				if [ `echo -n $type | tr [a-z] [A-Z]` = "V" ]
				then
					sudo pkill omx
					call_omx $file_nm
					sleep $slp_slt
					sudo pkill omx
				elif [ `echo -n $type | tr [a-z] [A-Z]` = "I" ]
				then
					sudo pkill fbi
					call_fbi $file_nm
					sleep $slp_slt
					sudo pkill fbi
				else	
					echof incorrect play type `date` pathodisha dashboard will be played 
					sleep 60
				fi
			fi
		else
			echof nothing to play now `date` - pathodisha dashboard will be displayed for next one minute
			sleep 60
		fi
	
	#cross-check if chrome accidentaly crashes 
	echof cross-checking chrome by re calling call chrome function `date`
	call_chrome
	done
	
}

#Play Videos 
call_omx()
{
	if [ ! -r $vdo_pth/$1 ]
	then
		echof video file not found $vdo_pth/$1 `date` pathodisha dashboard will be displayed
		return
	else
	/usr/bin/omxplayer -o hdmi $vdo_pth/$1 &
	fi
}


#Display Images
call_fbi()
{
	if [ ! -r $img_pth/$1 ]
	then
		echof image file not found $img_pth/$1 `date` pathodisha dashboard will be displayed
		return
	else
		sudo /usr/bin/fbi -T 2 -a -t 10 $img_pth/$1 >> $logfile &
	fi	
}

#main()
read_pmtr



##variable declaration goes here
vdo_pth=$base_pth/content
img_pth=$base_pth/content
sch_cfg_file=$base_pth/cfg/${kiosk_id}_evt.conf
export logfile=$base_pth/log/rds-play-schdule.log
#checking config 
heck_cfg

#play the files
play_sch

