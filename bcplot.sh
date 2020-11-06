#!/usr/bin/env bash
#plots ascii csv data downloaded from bepicolombo quicklook
RM=rm
RMTMP=1
plotcmd="graph -T X"
gplotcmd="gnuplot -p -e \"plot '-' \" "
### define variables
title="DefaultTitle"
xl="time [s]"
yl="counts [#]"
filename=$(basename "$1")
extension="${filename##*.}"
namenoext="${filename%.*}"
tempfile=$namenoext'_'$(date +'%s')'.csv'
### functions
get_labels(){
    {
    read title
    read xy
    while read -r line
    do
        echo $line >> "$tempfile"
    done
    }<"$1"
    gplotcmd="gnuplot -p -e \"set title '"$title"';set xlabel '"$xl"'; set ylabel '"$yl"'; set format x '%.6e'; set xtics 12000; plot '-' \" "
}
main(){
awk 'BEGIN{FS=","}{print $1 $2}' $1  | \
                sed -e "s/-/ /g"       \
                    -e "s/:/ /g"       \
                    -e "s/T/ /g"       \
                    -e "s/\./ /g"      \
                    -e "s/Z/ Z /g"   | \
                awk '{
                        mtime=$1" "$2" "$3" "$4" "$5" "$6
                        print mktime(mtime), $9
                    }'| eval $gplotcmd
}

### main program

#main $@
if [[ $# == 1 ]]
then
    get_labels $1
    main "$tempfile"
    if [ "$RMTMP" -eq 1 ]; then $RM "$tempfile"; fi
else
    echo "usage: $0 filename.csv"
fi
