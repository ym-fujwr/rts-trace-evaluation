#!/bin/bash

HOME_DIR=".."
REVISIONS_DIR="$HOME_DIR/original_source"

function extractTests() {
	dir=${1}
	fileName=${2}

	#extract tests only if build success
	success=$( grep -F "BUILD SUCCESS" $dir/$fileName )
	if [ -n "$success" ]; then
		info=$( cat $dir/$fileName | sed -n '/T E S T/,$p' | grep -E '(\[INFO\]) Running ' )
		if [ -n "$info" ]; then
			if echo "$dir" | grep -q -E 'NuProcess|jacksonXML';
			then
				sed -n '/T E S T/,$p' $dir/$fileName | grep -E 'Running com' | awk '{print $3}' > $dir/testList.txt
				sed -n '/T E S T/,$p' $dir/$fileName | grep -E 'Tests run' | awk '{print $4}' | sed -e "s/,//g" > $dir/testNum.txt
				
			else
				sed -n '/T E S T/,$p' $dir/$fileName | grep -E 'Running org' | awk '{print $3}' > $dir/testList.txt
				# sed -n '/T E S T/,$p' $dir/$fileName | grep -E 'Tests run' | awk '{print $3}' | sed -e "s/,//g" > $dir/testNum.txt
				sed -n '/T E S T/,$p' $dir/$fileName | grep -E 'Tests run' | awk '{print $4}' | sed -e "s/,//g" > $dir/testNum.txt

			fi
		else
			if echo "$dir" | grep -q -E 'NuProcess|jacksonXML';
			then
				sed -n '/T E S T/,$p' $dir/$fileName | grep -E 'Running com' | awk '{print $2}' > $dir/testList.txt
            	sed -n '/T E S T/,$p' $dir/$fileName | grep -E 'Tests run' | awk '{print $4}' | sed -e "s/,//g" > $dir/testNum.txt
			else
				sed -n '/T E S T/,$p' $dir/$fileName | grep -E 'Running org' | awk '{print $2}' > $dir/testList.txt
				# sed -n '/T E S T/,$p' $dir/$fileName | grep -E 'Tests run' | awk '{print $3}' | sed -e "s/,//g" > $dir/testNum.txt
				sed -n '/T E S T/,$p' $dir/$fileName | grep -E 'Tests run' | awk '{print $4}' | sed -e "s/,//g" > $dir/testNum.txt
			fi
		fi
		echo 1
	else
		echo 0
	fi
}

tools=(
	All
	Ekstazi
    rts-trace2
)

outFiles=(
	mvnRunOutput.txt
	EkstaziRTSOutput.txt
    RTS_TRACE_OUTPUT.txt
)

mkdir $HOME_DIR/result2
mkdir $HOME_DIR/result2/buildResult

cat $HOME_DIR/repositories.txt |
while IFS=" " read -r subN noUse noUse2; do
	brFile=$HOME_DIR/result2/buildResult/$subN.csv
	echo "rev, All, Ekstazi,rts-trace" > $brFile
	for revIdx in {1..50}; do
		revN="rev_$revIdx"
		for i in ${!tools[*]}; do
			tool=${tools[$i]}
			file=${outFiles[$i]}
            if [[ $revN == rev* ]] && [ -d $HOME_DIR/$tool/$subN/$revN ]; then
                returnVal=$(extractTests $HOME_DIR/$tool/$subN/$revN $file)
                if [[ $returnVal == 1 ]]; then
                                            resultStr+="Success, "
                                    else
                                            resultStr+="Fail, "
                                    fi
            fi
		done
		if [[ ${#resultStr} == 0 ]]; then
			echo "$revN: Not Avaiable!"
		else
			echo "$revN, ${resultStr::-2}" >> $brFile
		fi
		resultStr=""
	done
done
