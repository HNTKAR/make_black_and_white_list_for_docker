#!/bin/bash
export PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin

data_folder=/root/cron-bw-list
mail_log_file=/var/log/docker_log/maillog

ipset create white-list hash:net
ipset create black-list hash:net
mkdir -p $data_folder


##########make white list##########

curl -OL http://ftp.apnic.net/stats/apnic/delegated-apnic-latest
mv delegated-apnic-latest $data_folder/delegated-apnic-latest
chmod 700 $data_folder/delegated-apnic-latest

cat $data_folder/delegated-apnic-latest | grep JP |grep ipv4 >$data_folder/tmp
chmod 700 $data_folder/tmp
sed -i -e "s*|256*/24*" -e "s*|512*/23*" -e "s*|1024*/22*" -e "s*|2048*/21*" -e "s*|4096*/20*" -e "s*|8192*/19*" -e "s*|16384*/18*" -e "s*|32768*/17*" -e "s*|65536*/16*"  -e "s*|131072*/15*" -e "s*|262144*/14*" -e "s*|524288*/13*" -e "s*|1048576*/12*" -e "s*|2097152*/11*" -e "s*|4194304*/10*" -e "s*|8388608*/9*" -e "s*|16777216*/8*" $data_folder/tmp
#cat $data_folder/tmp |grep -v 256 |grep -v 512 |grep -v 1024 |grep -v 2048 |grep -v 4096 |grep -v 8192 |grep -v 16384 |grep -v 32768 |grep -v 65536 |grep -v 131072 |grep -v 262144 |grep -v 524288 |grep -v 1048576 |grep -v 2097152 |grep -v 4194304 |grep -v 8388608| grep -v 16777216 |less
cut -f 4 -d "|" $data_folder/tmp > $data_folder/japan-list
chmod 700 $data_folder/japan-list
echo 192.168.0.0/16 >> $data_folder/japan-list
echo 172.16.0.0/12 >> $data_folder/japan-list
echo 10.0.0.0/8 >> $data_folder/japan-list

rm $data_folder/tmp $data_folder/delegated-apnic-latest

ipset flush white-list
cat $data_folder/japan-list | xargs -I {} ipset add white-list "{}"



##########make black list##########

###from docker###

#from $mail_log_file
`:`>>$data_folder/black_list_log
chmod 700 $data_folder/black_list_log
cat $mail_log_file | grep  SASL|sed  -e 's/.*\[//g' -e 's/\].*'//g >>$data_folder/black_list_log
cat $data_folder/black_list_log | awk  'a[$0]++ == 10'>$data_folder/enemy_list
chmod 700 $data_folder/enemy_list

cat $mail_log_file >>$mail_log_file`date +"%y%m%d"`
rm -f $mail_log_file`date +"%y%m%d" -d "30 days ago"`

`:`> $mail_log_file

ipset flush black-list
cat $data_folder/enemy_list | xargs -I {} ipset add black-list "{}"
