#!/bin/bash

HOME_DIR=".."
REVISIONS_DIR="$HOME_DIR/original_source"
ALL_DIR="$HOME_DIR/ALL"
RTS_TRACE_DIR="$HOME_DIR/rts-trace2"
ACC_DIR="$HOME_DIR/accuracy2"
ACC_SUB_DIR="$HOME_DIR/accuracy_sub"



#!/bin/bash


#for subN in $(ls $REVISIONS_DIR/); do
    subN=NuProcess

    if [ -d $REVISIONS_DIR/$subN ]; then
		echo "*** RUN RTS-TRACE on project: $subN"
        mkdir -p $ACC_DIR/$subN/workingDir
        mkdir -p $ACC_DIR/$subN/workingDir/data
        mkdir -p $ACC_DIR/$subN/workingDir/data/json
        mkdir -p $ACC_DIR/$subN/workingDir/data/token
       
		for i in {31..50}; do
            revN="rev_$i"
            p=$((i - 1))
            ## commonsCLI　ALL時にfailしたリビジョンを除く
            # if [ "$i" -eq 45 ]; then
            #     continue
            # fi
            # if [ $i -eq 46 ];then
            #     p=44
            # fi            
            ##

            ## jacksonXML ALL時にfailしたリビジョンを除く
			# if [ $i -ge 10 ] && [ $i -le 16 ]; then
            #     continue
            # fi
			# if [ $i -ge 29 ] && [ $i -le 44 ]; then
			# 	continue
			# fi
            # if [ $i -eq 17 ];then
            #     p=9
            # fi
            # if [ $i -eq 45 ];then
            #     p=28
            # fi
			##

            # NuProcess
			if [ $i -eq 32 ]; then
				continue
			fi
			if [ $i -eq 39 ]; then
				continue
			fi
            if [ $i -eq 33 ];then
                p=31
            fi           
            if [ $i -eq 40 ];then
                p=38
            fi
            #

			# hilbertCurve
			# if [ $i -eq 14 ]; then
			# 	continue
			# fi
			# if [ $i -eq 15 ]; then
			# 	p=13
			# fi           
			##
			mkdir -p $ACC_DIR/$subN/$revN
            preN="rev_$p"
            ## 現在のリビジョンのソースコード，gitdiffの結果，前回の依存関係，字句解析の結果を用意する．
			if [ -d $REVISIONS_DIR/$subN/$revN ] ; then
				echo "**** RUN $subN with revision: $revN ****"
				cp -r -f $REVISIONS_DIR/$subN/$revN/. $ACC_DIR/$subN/workingDir
                cp -r -f $ACC_SUB_DIR/$subN/$preN/token/. $ACC_DIR/$subN/workingDir/data/token/
                cp -r -f $ACC_SUB_DIR/$subN/$preN/json/.  $ACC_DIR/$subN/workingDir/data/json/
                cp -r -f $RTS_TRACE_DIR/$subN/$revN/gitdiff.txt  $ACC_DIR/$subN/workingDir/data/
                cwd=$(pwd)
                cd $ACC_DIR/$subN/workingDir
                java -jar "$cwd"/$HOME_DIR/rts-trace-1.0-SNAPSHOT-jar-with-dependencies.jar select
				cd "$cwd"
				cp -f $ACC_DIR/$subN/workingDir/data/test.txt $ACC_DIR/$subN/$revN/
                rm -fR $ACC_DIR/$subN/workingDir/data/json/*
                rm -fR $ACC_DIR/$subN/workingDir/data/token/*
                rm -fR $ACC_DIR/$subN/workingDir/data/test.txt
			fi
		done
	fi
    #idx=idx+1
#done