#!/bin/sh
rsync /home/artm/gPodder/Downloads/ /media/artm/IPOD/books/ -rvu --remove-source-files --include="*.mp3" --include="*/" --exclude="*"
#find /home/artm/gPodder/Downloads/ -name '*.mp3' -printf '%TY-%Tm-%Td\t%k\t%p\n' | sort
