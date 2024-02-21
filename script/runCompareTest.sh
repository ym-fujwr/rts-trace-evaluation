HOME_DIR=".."
REVISIONS_DIR="$HOME_DIR/original_source"
ALL_DIR="$HOME_DIR/ALL"
ACC_DIR="$HOME_DIR/accuracy"
RTS_TRACE_DIR="$HOME_DIR/rts-trace2"
EKSTAZI_DIR="$HOME_DIR/Ekstazi"
ACC_DIR2="$HOME_DIR/accuracy2"


subN=NuProcess
for i in {33..50}; do
	revN="rev_$i"
        #commonsCLI　ALL時にfailしたリビジョンを除く
        # if [ "$i" -eq 45 ]; then
        #     continue
        # fi

        ## jacksonXML ALL時にfailしたリビジョンを除く
        # if [ $i -ge 10 ] && [ $i -le 16 ]; then
        #     continue
        # fi
        # if [ $i -ge 29 ] && [ $i -le 44 ]; then
        # 	continue
        # fi
        ##

        # NuProcess
        # if [ $i -eq 32 ]; then
        # 	continue
        # fi
        # if [ $i -eq 39 ]; then
        # 	continue
        # fi
        #

        # hilbertCurve
        # if [ $i -eq 14 ]; then
        # 	continue
        # fi
    python3 compareTest.py $ACC_DIR2/$subN/$revN/test.txt $ACC_DIR/$subN/$revN/test.txt $ACC_DIR2/$subN/compare_result.csv $ACC_DIR2/$subN/compare_details.txt $revN
done    