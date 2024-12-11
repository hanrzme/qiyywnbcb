#!/bin/sh

Pre="0"
Interval="3600"

Current() {
  epoch=`curl -sSL "https://rpc.qubic.org/v1/latest-stats" |grep -o '"epoch":[0-9]\+' |head -n1 |cut -d':' -f2`
  [ -n "$epoch" ] && [ "$epoch" -gt "0" ] || epoch="0"
  echo -n "$epoch"
}

while true; do
  Now=`Current`;
  [ "$Now" -gt "0" ] && [ "$Pre" -eq "0" ] && Pre="$Now";
  [ "$Now" -gt "0" ] && [ "$Pre" -gt "0" ] && [ "$Pre" -ne "$Now" ] && shutdown -r now;
  sleep "$(($((`od -An -N2 -i /dev/urandom` % Interval)) + Interval))" || sleep "$Interval";
done

exit 0



