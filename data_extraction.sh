#! /bin/sh
# Calculates average of CPU and RAM of all logfiles

# Deletes spaces in folder name to avoid errors
find $1 -depth -name "* *" -execdir rename 's/ /_/g' "{}" \;

CPUSUM=0
MEMSUM=0
COUNTER=0
TOTALSTRD_DEV_MEM=0
TOTALSTRD_DEV_CPU=0
##FILENAME to save results
FILENAME=$(echo $1 | sed -e 's/\/.*\///g')
#echo $FILENAME
#Empty the file
echo"" > $FILENAME".log" 
echo "CPU AND MEMORY\n--------------" >> $FILENAME".log"
echo "Iteration | CPU Avg | Deviation CPU | Memory | Deviation Memory   " >> $FILENAME".log"
#$1 contains the directory of all files used for performance
for FILE in $(find $1 -name 'log_performance_*')
do 

  NEWMEMAVG=$(cat $FILE|awk '{sum+=$3} END { print "",sum/NR}')
  NEWCPUAVG=$(cat $FILE|awk '{sum+=$2} END { print "",sum/NR}')
  STRD_DEV_CPU=$(cat $FILE|awk '{sum+=$2; sumsq+=$2*$2} END {print sqrt(sumsq/NR - (sum/NR)**2)}')
  STRD_DEV_MEM=$(cat $FILE|awk '{sum+=$3; sumsq+=$3*$3} END {print sqrt(sumsq/NR - (sum/NR)**2)}')


  NEWCPUAVG=`echo $NEWCPUAVG | tr ',' '.'`
  NEWMEMAVG=`echo $NEWMEMAVG | tr ',' '.'`
  STRD_DEV_MEM=`echo $STRD_DEV_MEM | tr ',' '.'`
  STRD_DEV_CPU=`echo $STRD_DEV_CPU | tr ',' '.'`
  COUNTER=$((COUNTER+1))

  CPUSUM=$(echo 'scale=3;'$CPUSUM + $NEWCPUAVG|bc)
  MEMSUM=$(echo 'scale=3;'$MEMSUM + $NEWMEMAVG|bc)
  TOTALSTRD_DEV_CPU=$(echo 'scale=3;'$TOTALSTRD_DEV_CPU + $STRD_DEV_CPU|bc)
  TOTALSTRD_DEV_MEM=$(echo 'scale=3;'$TOTALSTRD_DEV_MEM + $STRD_DEV_MEM|bc)
  echo $COUNTER" | "$NEWCPUAVG" | "$STRD_DEV_CPU" | "$NEWMEMAVG" | "$STRD_DEV_MEM>> $FILENAME".log"


done

echo "Total | "$(echo 'scale=3;'$CPUSUM/$COUNTER|bc)" | "$(echo 'scale=3;'$TOTALSTRD_DEV_CPU/$COUNTER|bc)" | "$(echo 'scale=3;'$MEMSUM/$COUNTER|bc)" | "$(echo 'scale=3;'$TOTALSTRD_DEV_MEM/$COUNTER|bc) >> $FILENAME".log"



#BANDWIDTH analysis
NEWBWAVG=0
STRD_DEV_BW=0
TOTALSTRD_DEV_BW=0
BWSUM=0
COUNTER=0

echo "\n\nBANDWIDTH\n--------------" >> $FILENAME".log"
echo "Iteration | BW Avg | Deviation BW" >> $FILENAME".log"
#$1 contains the directory of all files used for performance
for FILE in $(find $1 -name 'rtp_*')
do 
  ./perinst.awk $FILE > $FILE_bitrate.txt

  # removing first line from bitrate.txt
  mv $FILE_bitrate.txt $FILE_bitrate.tmp
  sed 1d $FILE_bitrate.tmp > $FILE_bitrate.txt
  rm $FILE_bitrate.tmp

  NEWBWAVG=$(cat $FILE_bitrate.txt|awk '{sum+=$2} END { print "",sum/NR}')
  STRD_DEV_BW=$(cat $FILE_bitrate.txt|awk '{sum+=$2; sumsq+=$2*$2} END {print sqrt(sumsq/NR - (sum/NR)**2)}')

  #echo $NEWBWAVG
  #echo $STRD_DEV_BW
  NEWBWAVG=`echo $NEWBWAVG | tr ',' '.'`
  STRD_DEV_BW=`echo $STRD_DEV_BW | tr ',' '.'`
  # NEWCPUAVG=`echo $NEWCPUAVG | tr ',' '.'`
  # NEWMEMAVG=`echo $NEWMEMAVG | tr ',' '.'`
  # STRD_DEV_MEM=`echo $STRD_DEV_MEM | tr ',' '.'`
  # STRD_DEV_CPU=`echo $STRD_DEV_CPU | tr ',' '.'`
  COUNTER=$((COUNTER+1))

  # CPUSUM=$(echo 'scale=3;'$CPUSUM + $NEWCPUAVG|bc)
  BWSUM=$(echo 'scale=3;'$BWSUM + $NEWBWAVG|bc)
  TOTALSTRD_DEV_BW=$(echo 'scale=3;'$TOTALSTRD_DEV_BW + $STRD_DEV_BW|bc)
  # TOTALSTRD_DEV_MEM=$(echo 'scale=3;'$TOTALSTRD_DEV_MEM + $STRD_DEV_MEM|bc)
  echo $COUNTER" | "$NEWBWAVG" | "$STRD_DEV_BW>> $FILENAME".log"
  rm $FILE_bitrate.txt

done

echo "Total | "$(echo 'scale=3;'$BWSUM/$COUNTER|bc)" | "$(echo 'scale=3;'$TOTALSTRD_DEV_BW/$COUNTER|bc) >> $FILENAME".log"


# Call setup time analysis
NEWTIME=0
STRD_DEV_TIME=0
#TOTALSTRD_DEV_BW=0
TIMESUM=0
COUNTER=0

echo "\n\nSETUP TIME\n--------------" >> $FILENAME".log"
echo "Iteration | Time (ms)" >> $FILENAME".log"
#$1 contains the directory of all files used for performance
for FILE in $(find $1 -name '*StablishmentCall*')
do 

  NEWTIME=$(cat $FILE|awk '{sum+=$1} END { print "",sum/NR}')
  #STRD_DEV_BW=$(cat $FILE.txt|awk '{sum+=$2; sumsq+=$2*$2} END {print sqrt(sumsq/NR - (sum/NR)**2)}')

  #echo $NEWBWAVG
  #echo $STRD_DEV_BW
  NEWTIME=`echo $NEWTIME | tr ',' '.'`
  echo $NEWTIME >> time_tmp_log
  #STRD_DEV_BW=`echo $STRD_DEV_BW | tr ',' '.'`
  # NEWCPUAVG=`echo $NEWCPUAVG | tr ',' '.'`
  # NEWMEMAVG=`echo $NEWMEMAVG | tr ',' '.'`
  # STRD_DEV_MEM=`echo $STRD_DEV_MEM | tr ',' '.'`
  # STRD_DEV_CPU=`echo $STRD_DEV_CPU | tr ',' '.'`
  COUNTER=$((COUNTER+1))

  # CPUSUM=$(echo 'scale=3;'$CPUSUM + $NEWCPUAVG|bc)
  TIMESUM=$(echo 'scale=3;'$TIMESUM + $NEWTIME|bc)
  #TOTALSTRD_DEV_BW=$(echo 'scale=3;'$TOTALSTRD_DEV_BW + $STRD_DEV_BW|bc)
  # TOTALSTRD_DEV_MEM=$(echo 'scale=3;'$TOTALSTRD_DEV_MEM + $STRD_DEV_MEM|bc)
  echo $COUNTER" | "$NEWTIME>> $FILENAME".log"

done

STRD_DEV_TIME=$(cat time_tmp_log|awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt(sumsq/NR - (sum/NR)**2)}')
rm time_tmp_log
echo "Total | "$(echo 'scale=3;'$TIMESUM/$COUNTER|bc)" | "$STRD_DEV_TIME" (deviation ms)"  >> $FILENAME".log"
