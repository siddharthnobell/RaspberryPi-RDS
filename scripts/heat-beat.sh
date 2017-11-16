#########################################################
## Below script is used to touch empty files in heart folder on ftp server
## Logic for sync up is as below
##		S1. open a ftp conn 
##		S2. touch a empty file with the node name in heart folder 
##		S3. repeat the process every 5 minutes
#########################################################

##function definition go below
read_pmtr()
{
	set -x
	script_name=`realpath $0`
	pth=`dirname $script_name`
	export base_pth=$pth/..
	. $base_pth/cfg/env.cfg
	export logfile=$base_pth/log/heart-beat-`date +"%s"`.log
}


echof()
{
	echo ---------------------------------------------------- >> $logfile
	echo $@ >> $logfile
	echo ---------------------------------------------------- >> $logfile
}

gen_heatbeat()
{
	set -x
	#this script generates/updates a touch file in heart folder on ftp server
	>$tmp_file
	echof sending heart beat to the ftp /heart folder `date` >> $logfile 
	touch ${dbn}_beat
ftp -n -v $FTPHOST << EOT >>$tmp_file
ascii
user $FTPUSER $FTPPASS
prompt
bin
cd /heart
put ${dbn}_beat
bye 
EOT
	rm -rf ${dbn}_beat
	cat $tmp_file >> $logfile
	echof sending heart beat to the ftp /heart folder finished `date` >> $logfile
}


#main()
set -x
read_pmtr

##variable declaration goes here
date=$(date +%s)
temp_dir=$base_pth/temp
export tmp_file=$temp_dir/ftp_output_$FTPUSER_$date


#below code runs for entire duration of pi day schedule calling the gen_heatbeat every 5 minutes
while true 
do
	gen_heatbeat
	sleep 300
done
