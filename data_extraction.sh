#! /bin/sh
# Calculates average of CPU and RAM of all logfiles

# Deletes spaces in folder name to avoid errors
find $1 -depth -name "* *" -execdir rename 's/ /_/g' "{}" \;

#Empty files for temp results
#echo "" > BW_DATA.dat
echo "" > BW_DATA_2.dat
echo "" > BW_DATA_1.dat
echo "" > CPU_MEM_DATA.dat
echo "" > RTT.dat
echo "" > SETUP_TIME.dat

MACHINE_COUNTER=0
COUNTER_TOTAL=0
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
echo "Doing CPU/Memory..."
echo "CPU AND MEMORY\n--------------" >> $FILENAME".log"
#$1 contains the directory of all files used for performance
for FOLDER in $(find $1 -maxdepth 1 -mindepth 1 -name "*ubuntu*")
do 
  MACHINE_COUNTER=$((MACHINE_COUNTER+1))
  echo "* MACHINE $MACHINE_COUNTER *" | column -t >> $FILENAME".log"
  echo "Iteration | CPU Avg | Deviation CPU | Memory | Deviation Memory (%)  " | column -t >> $FILENAME".log"
  #echo $FOLDER
  for FILE in $(find $FOLDER -name "log_performance_*")
  do

    NEWMEMAVG=$(cat $FILE|awk '{sum+=$3} END { print "",sum/NR}')
    NEWCPUAVG=$(cat $FILE|awk '{sum+=$2} END { print "",sum/NR}')
    STRD_DEV_CPU=$(cat $FILE|awk '{sum+=$2; sumsq+=$2*$2} END {print (sqrt(sumsq/NR - (sum/NR)**2)/2)}')
    STRD_DEV_MEM=$(cat $FILE|awk '{sum+=$3; sumsq+=$3*$3} END {print (sqrt(sumsq/NR - (sum/NR)**2)/2)}')


    NEWCPUAVG=`echo $NEWCPUAVG | tr ',' '.'`
    NEWMEMAVG=`echo $NEWMEMAVG | tr ',' '.'`
    STRD_DEV_MEM=`echo $STRD_DEV_MEM | tr ',' '.'`
    STRD_DEV_CPU=`echo $STRD_DEV_CPU | tr ',' '.'`
    COUNTER=$((COUNTER+1))
    COUNTER_TOTAL=$((COUNTER_TOTAL+1))


    CPUSUM=$(echo 'scale=3;'$CPUSUM + $NEWCPUAVG|bc)
    MEMSUM=$(echo 'scale=3;'$MEMSUM + $NEWMEMAVG|bc)
    TOTALSTRD_DEV_CPU=$(echo 'scale=3;'$TOTALSTRD_DEV_CPU + $STRD_DEV_CPU|bc)
    TOTALSTRD_DEV_MEM=$(echo 'scale=3;'$TOTALSTRD_DEV_MEM + $STRD_DEV_MEM|bc)
    echo $COUNTER"\t"$NEWCPUAVG"\t"$STRD_DEV_CPU"\t"$NEWMEMAVG"\t"$STRD_DEV_MEM >> "CPU_MEM_DATA.dat"
    echo $COUNTER" | "$NEWCPUAVG" | "$STRD_DEV_CPU" | "$NEWMEMAVG" | "$STRD_DEV_MEM | column -t >> $FILENAME".log"
  done
  COUNTER=0
  echo "\n" >> $FILENAME".log"
done

echo "Overall | "$(echo 'scale=3;'$CPUSUM/$COUNTER_TOTAL|bc)" | "$(echo 'scale=3;'$TOTALSTRD_DEV_CPU/$COUNTER_TOTAL|bc)" | "$(echo 'scale=3;'$MEMSUM/$COUNTER_TOTAL|bc)" | "$(echo 'scale=3;'$TOTALSTRD_DEV_MEM/$COUNTER_TOTAL|bc) | column -t >> $FILENAME".log"


# Call setup time analysis
NEWTIME=0
STRD_DEV_TIME=0
#TOTALSTRD_DEV_BW=0
TIMESUM=0
COUNTER=0
MACHINE_COUNTER=0 
COUNTER_TOTAL=0
echo "Doing call stablishment time..."
echo "\n\nSETUP TIME\n--------------" >> $FILENAME".log"
#$1 contains the directory of all files used for performance
for FOLDER in $(find $1 -maxdepth 1 -mindepth 1 -name "*ubuntu*")
do 
  MACHINE_COUNTER=$((MACHINE_COUNTER+1))
  echo "* MACHINE $MACHINE_COUNTER *" >> $FILENAME".log"
  echo "Iteration | Time (ms)" | column -t >> $FILENAME".log"
  #echo $FOLDER
  for FILE in $(find $FOLDER -name "*StablishmentCall*")
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
    COUNTER_TOTAL=$((COUNTER_TOTAL+1))

    # CPUSUM=$(echo 'scale=3;'$CPUSUM + $NEWCPUAVG|bc)
    TIMESUM=$(echo 'scale=3;'$TIMESUM + $NEWTIME|bc)
    #TOTALSTRD_DEV_BW=$(echo 'scale=3;'$TOTALSTRD_DEV_BW + $STRD_DEV_BW|bc)
    # TOTALSTRD_DEV_MEM=$(echo 'scale=3;'$TOTALSTRD_DEV_MEM + $STRD_DEV_MEM|bc)
    echo $COUNTER"\t"$NEWTIME >> "SETUP_TIME.dat"
    echo $COUNTER" | "$NEWTIME | column -t >> $FILENAME".log"
  done
  echo "\n" >> $FILENAME".log"
  COUNTER=0
done

STRD_DEV_TIME=$(cat time_tmp_log|awk '{sum+=$1; sumsq+=$1*$1} END {print (sqrt(sumsq/NR - (sum/NR)**2)/2)}')
rm time_tmp_log

echo "Overall | "$(echo 'scale=3;'$TIMESUM/$COUNTER_TOTAL|bc)" | "$STRD_DEV_TIME" (deviation ms)" | column -t >> $FILENAME".log"


# RTT stats

RTTSUM=0
COUNTER=0
TOTALSTRD_DEV_RTT=0
COUNTER_TOTAL=0
MACHINE_COUNTER=0
echo "Doing RTT..."
echo "\n\nRTT\n--------------" >> $FILENAME".log"
#$1 contains the directory of all files used for performance

for FOLDER in $(find $1 -maxdepth 1 -mindepth 1 -name "*ubuntu*")
do 
  MACHINE_COUNTER=$((MACHINE_COUNTER+1))
  echo "* MACHINE $MACHINE_COUNTER *" >> $FILENAME".log"
  echo "Iteration | RTT Avg | Deviation RTT (ms)" | column -t >> $FILENAME".log"
  #echo $FOLDER
  for FILE in $(find $FOLDER -name "*RTT*")
  do
    NEWRTTAVG=$(cat $FILE|awk '{sum+=$2} END { print "",sum/NR}')
    STRD_DEV_RTT=$(cat $FILE|awk '{sum+=$2; sumsq+=$2*$2} END {print (sqrt(sumsq/NR - (sum/NR)**2)/2)}')

    NEWRTTAVG=`echo $NEWRTTAVG | tr ',' '.'`
    STRD_DEV_RTT=`echo $STRD_DEV_RTT | tr ',' '.'`
    COUNTER=$((COUNTER+1))
    COUNTER_TOTAL=$((COUNTER_TOTAL+1))

    RTTSUM=$(echo 'scale=3;'$RTTSUM + $NEWRTTAVG|bc)
    TOTALSTRD_DEV_RTT=$(echo 'scale=3;'$TOTALSTRD_DEV_RTT + $STRD_DEV_RTT|bc)
    echo $COUNTER"\t"$NEWRTTAVG"\t"$STRD_DEV_RTT >> "RTT.dat"
    echo $COUNTER" | "$NEWRTTAVG" | "$STRD_DEV_RTT | column -t >> $FILENAME".log"
  done
  echo "\n" >> $FILENAME".log"
  COUNTER=0
done

echo "Overall | "$(echo 'scale=3;'$RTTSUM/$COUNTER_TOTAL|bc)" | "$(echo 'scale=3;'$TOTALSTRD_DEV_RTT/$COUNTER_TOTAL|bc) | column -t >> $FILENAME".log"


#BANDWIDTH analysis
NEWBWAVG=0
STRD_DEV_BW=0
TOTALSTRD_DEV_BW=0
BWSUM=0
COUNTER=0
MACHINE_COUNTER=0
COUNTER_TOTAL=0
echo "Doing Bandwidth..."
echo "\n\nBANDWIDTH\n----------------------------\n" >> $FILENAME".log"
#$1 contains the directory of all files used for performance
for FOLDER in $(find $1 -maxdepth 1 -mindepth 1 -name "*ubuntu*")
do 
  MACHINE_COUNTER=$((MACHINE_COUNTER+1))
  echo "* MACHINE $MACHINE_COUNTER *" | column -t >> $FILENAME".log"
  echo "Iteration | SSRC | BW Avg | Deviation BW (Kbit/s)" | column -t >> $FILENAME".log"
  #echo $FOLDER
  for FILE_SSRC in $(find $FOLDER -name "*_RV*")
  do
    SSRC=$(echo $FILE_SSRC | awk -F_ '{print $(NF-1)}' | awk -F. '{print $1F}')
    #echo $SSRC
    for FILE_SSRC_CONMON in $(find $FOLDER -name "rtp_*$SSRC*")
    do
      #echo $FILE_SSRC_CONMON
      ./perinst.awk $FILE_SSRC_CONMON > $FILE_SSRC_CONMON_bitrate.txt
       # # removing first line from bitrate.txt
      mv $FILE_SSRC_CONMON_bitrate.txt $FILE_SSRC_CONMON_bitrate.tmp
      sed 1d $FILE_SSRC_CONMON_bitrate.tmp > $FILE_SSRC_CONMON_bitrate.txt
      rm $FILE_SSRC_CONMON_bitrate.tmp
      
      NEWBWAVG=$(cat $FILE_SSRC_CONMON_bitrate.txt|awk '{sum+=$2} END { print "",sum/NR}')
      STRD_DEV_BW=$(cat $FILE_SSRC_CONMON_bitrate.txt|awk '{sum+=$2; sumsq+=$2*$2} END {print (sqrt(sumsq/NR - (sum/NR)**2)/2)}')
      NEWBWAVG=`echo $NEWBWAVG | tr ',' '.'`
      STRD_DEV_BW=`echo $STRD_DEV_BW | tr ',' '.'`
      COUNTER=$((COUNTER+1))
      COUNTER_TOTAL=$((COUNTER_TOTAL+1))
      BWSUM=$(echo 'scale=3;'$BWSUM + $NEWBWAVG|bc)
      TOTALSTRD_DEV_BW=$(echo 'scale=3;'$TOTALSTRD_DEV_BW + $STRD_DEV_BW|bc)
      echo $COUNTER"\t"$NEWBWAVG"\t"$STRD_DEV_BW >> "BW_DATA_$MACHINE_COUNTER.dat"
      echo $COUNTER" | " $SSRC" | "$NEWBWAVG" | "$STRD_DEV_BW | column -t >> $FILENAME".log"
      rm $FILE_SSRC_CONMON_bitrate.txt
    done
  done
  echo "\n" >> $FILENAME".log"
  COUNTER=0
done

echo "Overall | "$(echo 'scale=3;'$BWSUM/$COUNTER_TOTAL|bc)" | "$(echo 'scale=3;'$TOTALSTRD_DEV_BW/$COUNTER_TOTAL|bc) | column -t >> $FILENAME".log"


#Tyding datafile

join -2 1 -2 1 BW_DATA_1.dat BW_DATA_2.dat > BW_DATA_t.dat
sed 1d BW_DATA_t.dat > BW_DATA.dat
rm BW_DATA_t.dat
#cat BW_DATA.dat

echo "Plotting bandwidth..."
# We are using bitrate.txt for the data
gnuplot << EOF
reset
set terminal pdf color enhanced rounded size 12,4 fsize 10
set output 'mean_deviation_bw.pdf'
#unset key 
set ylabel "Observed rate [kbps]"

set xrange [ 0.00000 : 10.5000 ]
set yrange [ 0 : 2500 ]

set grid

set title "Mean and deviation for bandwidth" font ",14"
set xlabel "Iterations"
plot "BW_DATA_1.dat" u (column(1)-0.1):2:3 with yerrorbars lt -1 pi -6 pt 7 lc 7 lw 5 ps 1.5 title "Machine A", \
"BW_DATA_2.dat" u (column(1)+0.1):2:3 with yerrorbars lt -1 pi -6 pt 7 lc 8 lw 5 ps 1.5 title "Machine B"

EOF

# Delay calculation
echo "Calculating delay..."
COUNTER_TOTAL=0
for FOLDER in $(find $1 -maxdepth 1 -mindepth 1 -name "*ubuntu3*")
do
  for FILE_RTP in $(find $FOLDER  -type d -name "rtp*")
  do
    COUNTER_TOTAL=$((COUNTER_TOTAL+1))
    dir2=${FILE_RTP/lubuntu3/lubuntu4}"/"
    dir1=$(echo $FILE_RTP)"/"
    #echo $dir1
    #echo $dir2
    python diff.py $dir1 $dir2 $COUNTER_TOTAL
    echo "Plotting delay for iteration $COUNTER_TOTAL"
    ./delay_increase.sh $COUNTER_TOTAL
  done
done


echo "Plotting all delay distribution iterations..."
mkdir -p output_delay
#plotting bitrate.txt using gnuplot
gnuplot << EOF
set terminal pdf color enhanced rounded size 12,4 fsize 10
set output "output_delay/total_delay_distribution.pdf"
set origin 0,0
set size ratio 0.29
set key right top inside
set pointsize 2.5
unset key

set xlabel "Delay [ms]"
set ylabel "Packets"
set yrange [0:1]
set xrange [0:1000]
set grid
set style fill pattern 5
set xtics border out scale 0,0 mirror offset character 0, 0, 0

plot "output_delay/delay_inc_1.txt" using 1:2 with linespoints lw 3 lt -1 pt 6 ps 1.5 lc -1, \
"output_delay/delay_inc_2.txt" using 1:2 with linespoints lw 3 lt -1 pt 6 ps 1.5 lc 1, \
"output_delay/delay_inc_3.txt" using 1:2 with linespoints lw 3 lt -1 pt 6 ps 1.5 lc 2, \
"output_delay/delay_inc_4.txt" using 1:2 with linespoints lw 3 lt -1 pt 6 ps 1.5 lc 3, \
"output_delay/delay_inc_5.txt" using 1:2 with linespoints lw 3 lt -1 pt 6 ps 1.5 lc 4, \
"output_delay/delay_inc_6.txt" using 1:2 with linespoints lw 3 lt -1 pt 6 ps 1.5 lc 5, \
"output_delay/delay_inc_7.txt" using 1:2 with linespoints lw 3 lt -1 pt 6 ps 1.5 lc 6, \
"output_delay/delay_inc_8.txt" using 1:2 with linespoints lw 3 lt -1 pt 6 ps 1.5 lc 7, \
"output_delay/delay_inc_9.txt" using 1:2 with linespoints lw 3 lt -1 pt 6 ps 1.5 lc 8, \
"output_delay/delay_inc_10.txt" using 1:2 with linespoints lw 3 lt -1 pt 6 ps 1.5 lc 9
EOF
  
rm BW_DATA_2.dat
rm BW_DATA_1.dat
rm BW_DATA.dat
rm CPU_MEM_DATA.dat
rm RTT.dat
rm SETUP_TIME.dat