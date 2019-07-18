#!/bin/bash


mail_log_file=/var/log/docker_log/maillog

ipset create white-list hash:net
ipset create black-list hash:net



##########make white list##########

curl -OL http://ftp.apnic.net/stats/apnic/delegated-apnic-latest

cat delegated-apnic-latest | grep JP |grep ipv4 >tmp
sed -i -e "s*|256*/24*" -e "s*|512*/23*" -e "s*|1024*/22*" -e "s*|2048*/21*" -e "s*|4096*/20*" -e "s*|8192*/19*" -e "s*|16384*/18*" -e "s*|32768*/17*" -e "s*|65536*/16*"  -e "s*|131072*/15*" -e "s*|262144*/14*" -e "s*|524288*/13*" -e "s*|1048576*/12*" -e "s*|2097152*/11*" -e "s*|4194304*/10*" -e "s*|8388608*/9*" -e "s*|16777216*/8*" tmp
cut -f 4 -d "|" tmp > japan-list
echo 192.168.0.0/16 >> japan-list

rm tmp delegated-apnic-latest

ipset flush white-list
cat japan-list | xargs -I {} ipset add white-list "{}"



##########make black list##########

###from docker###

#from $mail_log_file
`:`>>black_list_log
chmod 777 black_list_log
cat $mail_log_file | grep  SASL|sed  -e 's/.*\[//g' -e 's/\].*'//g >>black_list_log
cat black_list_log | awk  'a[$0]++ == 10'>enemy_list
`:`> $mail_log_file

ipset flush black-list
cat enemy_list | xargs -I {} ipset add black_list "{}"