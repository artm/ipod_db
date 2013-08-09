#!/bin/bash

SRC=/home/artm/gPodder/Downloads
DEV=/media/artm/IPOD
DST=$DEV/books
LIST=./upload-files.txt
RSYNC_OPTS='-ruvh --remove-source-files'

SPACE=$(df -k $DEV | tail -1 | sed -e 's/ \+/\t/g' | cut -f 4)

# no more than ...
TOTAL=1000
find $SRC -name '*.mp3' -printf '%TY-%Tm-%Td\t%k\t%P\n' | sort | cut -f 2,3 | while read SIZE FILE ; do
  TOTAL=$(($TOTAL+$SIZE))
  if [ $TOTAL -gt $SPACE ] ; then
    break
  fi
  echo $FILE
done > $LIST

rsync $RSYNC_OPTS $SRC/ $DST/ --files-from=$LIST
ipod sync
