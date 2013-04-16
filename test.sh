#! /bin/sh
#

for FOLDER in $(find $1 -maxdepth 1 -mindepth 1 -name "*ubuntu3")
do 
  for FILE_RTP in $(find $FOLDER  -type d -name "rtp*")
  do
    dir2=${FILE_RTP/lubuntu3/lubuntu4}"/"
    #dir2=$(dirname $FILE_RTP | sed 's/lubuntu3/lubuntu4/g'"/"
    dir1=$(echo $FILE_RTP)"/"
    echo $dir1
    echo $dir2
  done
done