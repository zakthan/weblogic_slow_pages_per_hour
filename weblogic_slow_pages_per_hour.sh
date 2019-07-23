#!/bin/bash
##Author Thanassis Zakopoulos
##Usage This script calculates slow connections per hour and sends data once per day to zabbix server via crontab.Weblogic http logs are extended format and for the script to work correct the need to be rotated once per day only.Slow page is a page that takes more than $SLOW_PAGE_SECONDS_THRESHOLD seconds to respond

##script parameters###
ZABBIX=*****
HOST=`hostname`
KEY=weblogic_slow_pages_per_hour
##script parameters###

##script parameters###
SLOW_PAGE_SECONDS_THRESHOLD=8
#LOG_FILE_WITH_CONNECTIONS_PER_HOUR is used to save values per hour in format $HOST $KEY $TIMESTAMP $VALUE
LOG_FILE_WITH_CONNECTIONS_PER_HOUR=/tmp/log_weblogic_slow_pages_per_hour
#empty old values in order to save new ones
cat /dev/null > $LOG_FILE_WITH_CONNECTIONS_PER_HOUR
#this is the file to be used as access log
ACCESS_LOG=/appl_atgsf/sf_user_projects/domains/COS_PRD_SFDomain/servers/COSPRD_SF01/logs/access.log
##script parameters###

for i in $(seq -w 0 23);do echo $HOST $KEY $(date "+%s" -d "`echo $(date -d yesterday "+%m/%d/%Y $i:00:00")`") $(cat $ACCESS_LOG|tr ' \t' " "|grep "$(date -d yesterday "+%Y-%m-%d $i:")"|awk -v var="$SLOW_PAGE_SECONDS_THRESHOLD" '{if ( $NF > var ) print $NF}'|wc -l);done >> $LOG_FILE_WITH_CONNECTIONS_PER_HOUR

##send values to zabbix
/usr/bin/zabbix_sender -vv -z $ZABBIX -s $HOST --with-timestamps --input-file $LOG_FILE_WITH_CONNECTIONS_PER_HOUR
