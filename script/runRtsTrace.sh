#!/bin/bash

HOME_DIR=".."
REVISIONS_DIR="$HOME_DIR/original_source"
ALL_DIR="$HOME_DIR/ALL"
RTS_TRACE_DIR="$HOME_DIR/rts-trace3"


jit_insert="<build>\n<plugins>\n<plugin>\n<groupId>org.apache.maven.plugins</groupId>\n<artifactId>maven-surefire-plugin</artifactId>\n<configuration>\n<argLine>-javaagent:../../../../selogger-0.5.1-x.jar=output=./data/selogger,,weaverlog=data/selogger/log.txt,format=freq,weave=EXEC+FIELD+LINE,e=org/apache,e=org/junit,e=junit/framework,e=org/hamcrest,e=com/chrisnewland,e=FooClassInDefaultPackage,e=IsUsedForTestingDefaultPackage,logsave=partial,lognested=true,logstart=###METHOD_ENTRY,logend=###METHOD_EXIT</argLine>\n</configuration>\n</plugin>\n</plugins>\n</build>"

#!/bin/bash

# NuProcess用．
remove_line() {
    local file_path=$1

    # ファイルが存在するか確認
    if [ ! -e "$file_path" ]; then
        echo "指定されたファイルが存在しません。"
        return 1
    fi

    # 一時ファイルの作成
    local temp_file=$(mktemp)

    # 指定された行を削除して一時ファイルに書き込む
    grep -v '<reuseForks>false</reuseForks>' "$file_path" > "$temp_file"
    # 一時ファイルを元ファイルに移す
    mv "$temp_file" "$file_path"
    echo "指定された行を削除しました。"
}

# 使用例
# file_path="your_file_path.txt"
# remove_line "$file_path"



#for subN in $(ls $REVISIONS_DIR/); do
    subN=commonsNet
    #リビジョンの番号を取得
    declare -a lines
    while IFS= read -r line; do
    lines+=("$line")
    done < $REVISIONS_DIR/$subN/revisions.txt
    idx=0

    #除くプラグイン情報を取得
    declare -a plugins

    while IFS= read -r line; do
    plugins+=("$line")
    done < $HOME_DIR/plugins.txt    

    if [ -d $REVISIONS_DIR/$subN ]; then
		echo "*** RUN RTS-TRACE on project: $subN"
		mkdir -p $RTS_TRACE_DIR/$subN/workingDir/data/selogger
        mkdir -p $RTS_TRACE_DIR/$subN/workingDir/data/json
        mkdir -p $RTS_TRACE_DIR/$subN/workingDir/data/token

        # #1回目は特別処理．
        echo "**** RUN $subN with revision: rev_1****"
        mkdir $RTS_TRACE_DIR/$subN/rev_1
		cp -r -f $REVISIONS_DIR/$subN/rev_1/. $RTS_TRACE_DIR/$subN/workingDir

        cp -f $HOME_DIR/rts-trace-1.0-SNAPSHOT-jar-with-dependencies.jar $RTS_TRACE_DIR/$subN/workingDir
        cp -f $ALL_DIR/$subN/rev_1/testMethodList.txt $RTS_TRACE_DIR/$subN/workingDir

        cwd=$(pwd)
        cd $RTS_TRACE_DIR/$subN/workingDir

        ##
        ## selogger integrate
        ##



        # NuProcess用
        # file_path="pom.xml"
        # remove_line "$file_path"

        echo "**** run test ****"
        mvn -Drat.skip=true -DargLine="-javaagent:../../../selogger-0.5.1-x.jar=output=./data/selogger,format=freq,weaverlog=data/selogger/log.txt,${plugins[$idx]},weave=EXEC+FIELD+LINE,logsave=partial,lognested=true,logstart=###METHOD_ENTRY,logend=###METHOD_EXIT" test > "$cwd"/$RTS_TRACE_DIR/$subN/rev_1/RTS_TRACE_OUTPUT.txt
        # mvn -Drat.skip=true test > "$cwd"/$RTS_TRACE_DIR/$subN2/rev_1/RTS_TRACE_OUTPUT.txt
        touch gitdiff.txt
        _started_at=$(date +'%s.%3N')
        java -jar "$cwd"/$HOME_DIR/rts-trace-1.0-SNAPSHOT-jar-with-dependencies.jar create
        _ended_at=$(date +'%s.%3N')
        _elapsed=$(echo "scale=3; $_ended_at - $_started_at" | bc)
        echo $_elapsed > ./data/update_time.txt

        cd "$cwd"
        cp -r $RTS_TRACE_DIR/$subN/workingDir/data $RTS_TRACE_DIR/$subN/rev_1
        # cp -r $RTS_TRACE_DIR/$subN2/workingDir/core/data $RTS_TRACE_DIR/$subN2/rev_1

		for i in {2..50}; do
			revN="rev_$i"
            now=$((i - 1))
            pre=$((i - 2))            
            #commonsCLI　ALL時にfailしたリビジョンを除く
            # if [ "$i" -eq 45 ]; then
            #     continue
            # fi
            # if [ $i -eq 46 ];then
            #     pre=43
            # fi         

            ## jacksonXML ALL時にfailしたリビジョンを除く
			# if [ $i -ge 10 ] && [ $i -le 16 ]; then
            #     continue
            # fi
			# if [ $i -ge 29 ] && [ $i -le 44 ]; then
			# 	continue
			# fi
            # if [ $i -eq 17 ];then
            #     pre=8
            # fi
            # if [ $i -eq 45 ];then
            #     pre=27
            # fi
			##

            # NuProcess
			# if [ $i -eq 32 ]; then
			# 	continue
			# fi
			# if [ $i -eq 39 ]; then
			# 	continue
			# fi
            # if [ $i -eq 33 ];then
            #     pre=30
            # fi           
            # if [ $i -eq 40 ];then
            #     pre=37
            # fi
            #

			# hilbertCurve
			# if [ $i -eq 14 ]; then
			# 	continue
			# fi
            # if [ $i -eq 15 ];then
            #     pre=12
            # fi
			#


			if [ -d $REVISIONS_DIR/$subN/$revN ] ; then
				echo "**** RUN $subN with revision: $revN ****"
				mkdir $RTS_TRACE_DIR/$subN/$revN
				cp -r -f $REVISIONS_DIR/$subN/$revN/. $RTS_TRACE_DIR/$subN/workingDir
                cp -f $ALL_DIR/$subN/$revN/testMethodList.txt $RTS_TRACE_DIR/$subN/workingDir

                #git-diffを取る
                cwd=$(pwd)
                cd $RTS_TRACE_DIR/$subN/workingDir
                
                echo "**** get diff ****"
                _started_at=$(date +'%s.%3N')
                # git diff -U0 ${lines[$((i-1))]} ${lines[$((i-2))]}  'core/**/*.java' > ./core/data/gitdiff.txt
                git diff -U0  ${lines[$pre]} ${lines[$now]}  '**/*.java' > ./data/gitdiff.txt
                _ended_at=$(date +'%s.%3N')
                _elapsed=$(echo "scale=3; $_ended_at - $_started_at" | bc)
                echo $_elapsed > ./data/diff_time.txt

                # git diff -U0 ${lines[$((i-1))]} ${lines[$((i-2))]} > ./core/data/all_git_diff.txt
                git diff -U0 ${lines[$pre]} ${lines[$now]} > ./data/all_git_diff.txt
                

                ## select
                echo "**** test select ****"
                _started_at=$(date +'%s.%3N')
                java -jar "$cwd"/$HOME_DIR/rts-trace-1.0-SNAPSHOT-jar-with-dependencies.jar select
                _ended_at=$(date +'%s.%3N')
                _elapsed=$(echo "scale=3; $_ended_at - $_started_at" | bc)
                echo $_elapsed > ./data/select_time.txt
                test=$(cat ./data/test.txt)


                ##
                ## selogger integrate
                ##
                
                # NuProcess用
                # remove_line "$file_path"

                if [ ! -z "$test" ] ; then
                    echo "**** run test ****"
                    if [ "$test" = "ALL" ]; then
                        mvn -Drat.skip=true -DargLine="-javaagent:../../../selogger-0.5.1-x.jar=output=./data/selogger,format=freq,weaverlog=data/selogger/log.txt,${plugins[$idx]},weave=EXEC+FIELD+LINE,logsave=partial,lognested=true,logstart=###METHOD_ENTRY,logend=###METHOD_EXIT" test > "$cwd"/$RTS_TRACE_DIR/$subN/$revN/RTS_TRACE_OUTPUT.txt
                        # mvn -Drat.skip=true test > "$cwd"/$RTS_TRACE_DIR/$subN2/$revN/RTS_TRACE_OUTPUT.txt
                    else
                        mvn -Drat.skip=true -Dtest=$test -DargLine="-javaagent:../../../selogger-0.5.1-x.jar=output=./data/selogger,format=freq,weaverlog=data/selogger/log.txt,${plugins[$idx]},weave=EXEC+FIELD+LINE,logsave=partial,lognested=true,logstart=###METHOD_ENTRY,logend=###METHOD_EXIT" test > "$cwd"/$RTS_TRACE_DIR/$subN/$revN/RTS_TRACE_OUTPUT.txt
                        # mvn -Drat.skip=true -Dtest=$test test > "$cwd"/$RTS_TRACE_DIR/$subN2/$revN/RTS_TRACE_OUTPUT.txt
                    fi
                else    
                    echo "**** build ****"
                    mvn -q clean
                    mvn -Drat.skip=true -DskipTests=true test  > "$cwd"/$RTS_TRACE_DIR/$subN/$revN/RTS_TRACE_OUTPUT.txt
                fi
                

                echo "**** run rts-trace update****"
                _started_at=$(date +'%s.%3N')
                java -jar "$cwd"/$HOME_DIR/rts-trace-1.0-SNAPSHOT-jar-with-dependencies.jar create
                _ended_at=$(date +'%s.%3N')
                _elapsed=$(echo "scale=3; $_ended_at - $_started_at" | bc)
                echo $_elapsed > ./data/update_time.txt 

				cd "$cwd"
				cp -r $RTS_TRACE_DIR/$subN/workingDir/data/. $RTS_TRACE_DIR/$subN/$revN
			fi
		done
	fi
    #idx=idx+1
#done