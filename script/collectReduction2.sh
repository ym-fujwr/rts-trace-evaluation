#!/bin/bash

HOME_DIR=".."
REVISIONS_DIR="$HOME_DIR/original_source"

function extractTime() {
	dir=${1}
	fileName=${2}

	#extract tests only if build success
	success=$( grep -F "BUILD SUCCESS" $dir/$fileName )
	if [ -n "$success" ]; then
		totalTime=$(grep -oP "Total time: \K.*" $dir/$fileName)
		if [[ $totalTime == *"s"* ]]; then
			totalTime=${totalTime::-2}
		else
			mins=${totalTime%:*}
			sec=${totalTime#*:}
			sec=${sec%%min*}
			sec=$((10#$sec))
			totalTime=$(( mins*60+sec ))
		fi

		if [ $fileName == RTS_TRACE_OUTPUT.txt ]; then
			if [[ ! "$dir" == *rev_1* ]]; then
			selectTime=$(cat $dir/select_time.txt)
			updateTime=$(cat $dir/update_time.txt)
			diffTime=$(cat $dir/diff_time.txt)
			totalTime=$(echo "$totalTime + $selectTime + $updateTime + $diffTime" | bc)
			fi
		fi

		echo "$totalTime"
	else
		echo "fail"
	fi
}

function extractTestReduction() {
	dir=${1}
	numTest=$(sed '/^$/d' $dir/testNum.txt | tail -n 1 $dir/testNum.txt)
	if [ -z "$numTest" ]; then
		numTest=0
	fi
	echo "$numTest"
}

tools=(
	Ekstazi
	rts-trace2
)

outFiles=(
	runTestSelectedByEkstaziOutput.txt
	runTestSelectedByRtsTraceOutput.txt
)

mkdir $HOME_DIR/result2
mkdir $HOME_DIR/result2/testTime2

cat $HOME_DIR/repositories.txt |
while IFS=" " read -r subN noUse noUse2; do
	timeFile=$HOME_DIR/result2/testTime2/$subN.csv
	echo "rev, Ekstazi, rts-trace" > $timeFile
	for revIdx in {1..25}; do
			if [ $revIdx -eq 14 ]; then
				continue
			fi
			if [ $revIdx -eq 15 ]; then
				p=13
			fi      
		revN="rev_$revIdx"
		for i in ${!tools[*]}; do
			tool=${tools[$i]}
			file=${outFiles[$i]}
			if [[ $revN == rev* ]] && [ -d $HOME_DIR/$tool/$subN/$revN ]; then
				echo "extract from " $HOME_DIR/$tool/$subN
				returnVal=$(extractTime $HOME_DIR/$tool/$subN/$revN $file)
				timeStr+="$returnVal, "
			fi
		done
		echo "$revN, ${timeStr::-2}" >> $timeFile
		timeStr=""
	done
done