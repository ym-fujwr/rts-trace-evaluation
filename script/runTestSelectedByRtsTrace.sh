#!/bin/bash
HOME_DIR=".."
REVISIONS_DIR="$HOME_DIR/original_source"
RTS_TRACE_DIR="$HOME_DIR/rts-trace2"

#各プロジェクト順番に実行
#for subN in $(ls $REVISIONS_DIR/); do
	subN=jitwatch
    cwd=$(pwd)
	if [ -d $REVISIONS_DIR/$subN ]; then
		echo "*** RUN Test Selected By RtsTrace: $subN"
		for i in {39..50}; do
            echo " run : $i "
			revN="rev_$i"
            test=$(cat "$cwd"/$RTS_TRACE_DIR/$subN/$revN/test.txt)
            cd "$cwd"/$REVISIONS_DIR/$subN/$revN/core
            if [ -z "$test" ]; then
                mvn -Drat.skip=true compile > "$cwd"/$RTS_TRACE_DIR/$subN/$revN/runTestSelectedByRtsTraceOutput.txt
            else
                mvn -Drat.skip=true -Dtest=$test test > "$cwd"/$RTS_TRACE_DIR/$subN/$revN/runTestSelectedByRtsTraceOutput.txt
            fi
		done
	fi
#done 
