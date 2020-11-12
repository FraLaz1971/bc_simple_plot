#!/usr/bin/env bash
#plots ascii csv data downloaded from bepicolombo quicklook
RM=rm
# put RMTMP=1 if you want to remove the temporary csv file
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
setup_gplot(){
    gplotcmd="set title '"$title"';set xlabel '"$xl"'; set ylabel '"$yl"'; set format x '%.6e'; set xtics 12000; plot '"$2"' "
    echo "$gplotcmd" > "$namenoext".gp
}

gplot(){
	gnuplot -p  "$namenoext".gp
}

read_file(){
    {
    read title
    read xy
    while read -r line
    do
        echo $line >> "$tempfile"
    done
    }<"$1"
}

create_gpplot(){
awk 'BEGIN{FS=","}{print $1 $2}' "$1"  | \
                sed -e "s/-/ /g"       \
                    -e "s/:/ /g"       \
                    -e "s/T/ /g"       \
                    -e "s/\./ /g"      \
                    -e "s/Z/ Z /g"   | \
                awk '{
                        mtime=$1" "$2" "$3" "$4" "$5" "$6
                        print mktime(mtime), $9
                    }' | tee "$2"
}

### main program

#main $@
if [[ $# == 2 ]]
then
    read_file "$1"
    setup_gplot "$1" "$2"
    create_gpplot "$tempfile" "$2"
    gplot
    if [ "$RMTMP" -eq 1 ]; then $RM "$tempfile"; fi
else
    echo "usage: ./creategpplot.sh infile.csv outfile.ssv"
fi
