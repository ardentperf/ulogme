#!/bin/bash


# logs the key press frequency over 9 second window. Logs are written 
# in logs/keyfreqX.txt every 9 seconds, where X is unix timestamp of 7am of the
# recording day.

LANG=en_US.utf8

helperfile="logs/keyfreqraw" # temporary helper file

mkdir -p logs

while true
do
  # check each possible keyboard
  keyboardIds=$(xinput | grep 'slave  keyboard' | grep -o 'id=[0-9]*' | cut -d= -f2)
  # and grep only the updated ones
  filesToGrep=''
  for id in $keyboardIds; do
      fileName="$helperfile.$id"
      # work in windows of 9 seconds
      timeout 9 xinput test $id > $fileName &
      filesToGrep+="$fileName "
  done
  wait
  
  # count number of key release events
  num=$(grep release $filesToGrep | wc -l)
  
  # append unix time stamp and the number into file
  logfile="logs/keyfreq_$(python rewind7am.py).txt"
  echo "$(date +%s) $num"  >> $logfile
  echo "logged key frequency: $(date) $num release events detected into $logfile"
  
done

