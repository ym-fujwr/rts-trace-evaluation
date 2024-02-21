#!/bin/bash
HOME_DIR=".."
REVISIONS_DIR="$HOME_DIR/original_source"
EKSTAZI_DIR="$HOME_DIR/Ekstazi"


#各プロジェクト順番に実行
#for subN in $(ls $REVISIONS_DIR/); do
	subN=jitwatch
    cwd=$(pwd)
	if [ -d $REVISIONS_DIR/$subN ]; then
		echo "*** RUN Test Selected By Ekstazi: $subN"
		for i in {38..50}; do
            echo " run : $i "
			revN="rev_$i"
            test=$(cat "$cwd"/$EKSTAZI_DIR/$subN/$revN/selectedTest.txt)
            cd "$cwd"/$REVISIONS_DIR/$subN/$revN/core
            if [ -z "$test" ]; then
                mvn -Drat.skip=true compile > "$cwd"/$EKSTAZI_DIR/$subN/$revN/runTestSelectedByEkstaziOutput.txt
            else
                mvn -Drat.skip=true -Dtest=$test test > "$cwd"/$EKSTAZI_DIR/$subN/$revN/runTestSelectedByEkstaziOutput.txt
            fi
		done
	fi
#done 
