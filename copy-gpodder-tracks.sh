#!/bin/sh

rsync -avP --include='*.mp3' --include='*.m4a' --include='*.m4b' --include='*/' --exclude='*' /home/artm/gPodder/Downloads/ device/books/

