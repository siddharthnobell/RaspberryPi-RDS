#########################################################
## Below script is used as a sync up script between the ftp server and the pi machine
## Logic for sync up is as below
##		S1. open a ftp conn and create list of files for current pi user with the size
##		S2. if the above step fails then the retry 20 times in interval of 5 minutes - after max try - old schedule plays - ftp process exits with failure in log
##		S3. if the above step passes then compare the size of the files in pi folder with the ftp file list
##		S4. above steps created two file files to download and files to delete
##		S5. using file created to delete - delete the files from play directory 
##		S6. using files to download - download the required files one by one using ftp conn
##		S7. once the download process is completed check for file that failed
##		S8. if their are files download fails then repeat step S6,S7 20 times in interval of 5 minutes for all file download success
##		S9. if after 20 retry some file download still failed then log the error for ftp failure - new schedule plays with the files not downloaded as not getting played 
#########################################################


################below steps are pending
##		P1. to put logic in ftp scripts for saperate folders for content and application files 
##			this can be easily done by calling the functions for two directories - i.e. for content and for config
##		P2. after sync diff taking common between the files required for playing in each node i.e. for a DBN and the files availabe in current pay dir 
##		
##



##function definition go below
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
 
ftp_get_schedule()
{
	#function gets the schedule from the ftp server if the schedule is not found ftp server, if found then the file_to_download
	echof Fetching the schedule event file `date`
	>$tmp_file
ftp -n -v $FTPHOST << EOT >>$tmp_file
ascii
user $FTPUSER $FTPPASS
prompt
bin
cd /$group/$dbn
get ${dbn}_evt.conf
bye 
EOT
	cat $tmp_file >> $logfile
	>$base_pth/cfg/${dbn}_evt.conf
	cat ./${dbn}_evt.conf | tr -d "\015" >> $base_pth/cfg/${dbn}_evt.conf   #removing control m chracters
	rm -rf  ./${dbn}_evt.conf 
	#checking ftp success if yes then exit else re-call ftp log creation
    tail_2=`tail -3 $tmp_file  | tr '\n' ' ' | tr -d [0-9]`
    if [ "\'$tail_2\'" = "\' Transfer OK  bytes received in . secs (. kB/s)  Goodbye \'" ]
    then	
    	echof Schedule event file transfer successfull `date`
		#file list to download the files 
		>$file_list
		cat $base_pth/cfg/${dbn}_evt.conf | cut -d"," -f4 | sort  | uniq >> $file_list
	else
		echof Schedule event file transfer un-successfull exiting ftp process `date`
		exit 10
    fi
}

ftp_sync_log()
{
  #function logs the diff in files on the ftp and local machine - creates a sync_list
  set -x
  count=1
  while true 
  do	
    >$tmp_file
	>$sync_log_files
	for var in `cat $file_list`
	do
ftp -n -v $FTPHOST << EOT >>$tmp_file
ascii
user $FTPUSER $FTPPASS
prompt
cd /$group/common
bin
ls $var
bye 
EOT
	done
	cat $tmp_file >> $logfile
    #checking ftp success if yes then exit else re-call ftp log creation
    tail_2=`tail -2 $tmp_file  | tr '\n' ' ' | tr -d [0-9]`
    if [ "\'$tail_2\'" = "\' Transfer OK  Goodbye \'" ]
    then	
    	echof Sync log creation success from ftp `date`
		
		####Below needs to disscussed and agreed upon
		#grep ' ftp ftp ' $tmp_file | awk '{print $5 ","$6 $7 $8 "," $9}'  | sort | uniq >> $sync_log_files      #commented the date part as ftp does not preserve the date 
		grep ' ftp ftp ' $tmp_file | awk '{print $5 "," $9}'  | sort | uniq >> $sync_log_files
    	return 0
	else
		echof Sync failed will retry after 5 minutes `date` - sync count= $count
    fi
    sleep 300
	#exiting with the sync failure error
	if [ $count -eq 20 ]
	then	
		echof Sync process failed max retry reached sync count= $count
		echof yesterday schedule is used for sync 
		exit
	fi
  done

}

ftp_check_sync_log()
{
  #this function check if there are any file to download from ftp server using the sync log
  if [ `wc -l $sync_log_files | cut -d' ' -f1` -eq 0 ]
  then
    echof Nothing to download `date`
	echof No files downloaded...
	exit 
  else
    #ls -lrt $curr_dir | tail -n +2 | awk '{print $5 ","$6 $7 $8 "," $9}' | sort > $tmp_file1  #commented the date part as ftp does not preserve the date 
    ls -lrt $curr_dir | tail -n +2 | awk '{print $5 "," $9}' | sort > $tmp_file1
	comm -23 $tmp_file1 $sync_log_files  > $tmp_file3  #to delete
	comm -23 $sync_log_files $tmp_file1 > $tmp_file2 #to download
	cat $sync_log_files | cut -d"," -f2 | sort | uniq >$file_list1
	echof List of missing files on ftp server please check the file name `date`
	comm -23 $file_list $file_list1 >> $logfile # missing on ftp server
  fi
}

ftp_to_delete()
{
	#deleting files
	for var in `cat $tmp_file3`
	do
		filename=`echo $var | cut -d"," -f2`
		echo deleting file $filename
		rm -rf $curr_dir/$filename
	done
}

ftp_to_download()
{
	#downlloading files
	set -x
	>$tmp_file
	for var in `cat $tmp_file2 | cut -d"," -f2`
	do
	cd $curr_dir
	echof downloading $var
ftp -n -v $FTPHOST << EOT >>$tmp_file
ascii
user $FTPUSER $FTPPASS
prompt
cd /${group}/common
bin
get $var
bye 
EOT
		
	done
cd -	
}


ftp_check_redownload()
{
	count=1
	while true
	do
		sleep 300
		ftp_check_sync_log
		if [ `wc -l $tmp_file2 | cut -d' ' -f1` -ne 0 ]
		then
			echof redowloading file/s failed during ftp `date`
			ftp_to_download
		else
			echof ftp download for the day success `date`
			exit
		fi
		
		if [ $count -eq 20 ]
		then
			echof FPT process failed max retry reached ftp count= $count
			echof whatever is downloaded will be played 
			exit
		fi
		count=`expr $count + 1`
	done
}


#main()
read_pmtr


##variable declaration goes here
curr_dir=$base_pth/content/
log_dir=$base_pth/log
temp_dir=$base_pth/temp
date=$(date +%s)
echo $date
tmp_file=$temp_dir/ftp_list_output_$FTPUSER_$date
sync_log_files=$temp_dir/ftp_sync_list_$FTPUSER_$date
tmp_file1=$temp_dir/pi_list_output_$FTPUSER_$date
tmp_file2=$temp_dir/to_download_$FTPUSER_$date
tmp_file3=$temp_dir/to_delete_$FTPUSER_$date
file_list=$temp_dir/file_list$FTPUSER_$date
file_list1=$temp_dir/file_list1$FTPUSER_$date


#to download config file - this is already handled - if video images are moved to a saperate folder then 
#below function needs to be written
ftp_get_schedule

#to create sync list
ftp_sync_log

#to create list of files to download and to delete
ftp_check_sync_log

#to delete files
ftp_to_delete

#to_download_file
ftp_to_download

#to_redownload failed files
ftp_check_redownload
