#!/bin/bash

HOME_DIR=".."
REVISIONS_DIR="$HOME_DIR/original_source"
ALL_DIR="$HOME_DIR/ALL"
RTS_TRACE_DIR="$HOME_DIR/rts-trace2"


jit_insert="<build>\n<plugins>\n<plugin>\n<groupId>org.apache.maven.plugins</groupId>\n<artifactId>maven-surefire-plugin</artifactId>\n<configuration>\n<argLine>-javaagent:../../../../selogger-0.5.1-x.jar=output=./data/selogger,,weaverlog=data/selogger/log.txt,format=freq,weave=EXEC+FIELD+LINE,e=org/apache,e=org/junit,e=junit/framework,e=org/hamcrest,e=com/chrisnewland,e=FooClassInDefaultPackage,e=IsUsedForTestingDefaultPackage,logsave=partial,lognested=true,logstart=###METHOD_ENTRY,logend=###METHOD_EXIT</argLine>\n</configuration>\n</plugin>\n</plugins>\n</build>"

#!/bin/bash


#for subN in $(ls $REVISIONS_DIR/); do
    subN=jitwatch
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
        # jitwatch用
		mkdir -p $RTS_TRACE_DIR/$subN/workingDir/core/data/selogger
        mkdir -p $RTS_TRACE_DIR/$subN/workingDir/core/data/json
        mkdir -p $RTS_TRACE_DIR/$subN/workingDir/core/data/token

        # #1回目は特別処理．
        echo "**** RUN $subN with revision: rev_38****"
        mkdir $RTS_TRACE_DIR/$subN/rev_38
		cp -r -f $REVISIONS_DIR/$subN/rev_38/. $RTS_TRACE_DIR/$subN/workingDir

        # jitwatch用
        cp -f $HOME_DIR/rts-trace-1.0-SNAPSHOT-jar-with-dependencies.jar $RTS_TRACE_DIR/$subN/workingDir/core
        cp -f $ALL_DIR/$subN/rev_38/testMethodList.txt $RTS_TRACE_DIR/$subN/workingDir/core

        cwd=$(pwd)
        cd $RTS_TRACE_DIR/$subN/workingDir

        ##
        ## selogger integrate
        ##


        ## jitWatch
        cd core 
        escaped_insert=$(echo $jit_insert | sed 's/\//\\\//g')
        sed -i "0,/<\/project>/s/<\/project>/$escaped_insert\n<\/project>/" pom.xml 

        echo "**** run test ****"
        mvn -Drat.skip=true test > "$cwd"/$RTS_TRACE_DIR/$subN/rev_38/RTS_TRACE_OUTPUT.txt
        touch gitdiff.txt
        _started_at=$(date +'%s.%3N')
        java -jar "$cwd"/$HOME_DIR/rts-trace-1.0-SNAPSHOT-jar-with-dependencies.jar create
        _ended_at=$(date +'%s.%3N')
        _elapsed=$(echo "scale=3; $_ended_at - $_started_at" | bc)
        echo $_elapsed > ./data/update_time.txt

        cd "$cwd"
        cp -r $RTS_TRACE_DIR/$subN/workingDir/core/data $RTS_TRACE_DIR/$subN/rev_38

		for i in {39..50}; do
			revN="rev_$i"
			if [ -d $REVISIONS_DIR/$subN/$revN ] ; then
				echo "**** RUN $subN with revision: $revN ****"
				mkdir $RTS_TRACE_DIR/$subN/$revN
                cp -r -f $REVISIONS_DIR/$subN/$revN/. $RTS_TRACE_DIR/$subN/workingDir
                cp -f $ALL_DIR/$subN/$revN/testMethodList.txt $RTS_TRACE_DIR/$subN/workingDir/core
                #git-diffを取る
                cwd=$(pwd)
                cd $RTS_TRACE_DIR/$subN/workingDir
                
                echo "**** get diff ****"
                git diff -U0 ${lines[$((i-2))]} ${lines[$((i-1))]}  'core/**/*.java' > ./core/data/gitdiff.txt
                git diff -U0 ${lines[$((i-2))]} ${lines[$((i-1))]} > ./core/data/all_git_diff.txt
                ## core nuku
                sed -i 's/a\/core\/src/a\/src/' ./core/data/gitdiff.txt
                sed -i 's/b\/core\/src/b\/src/' ./core/data/gitdiff.txt            
                cd core 

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

                escaped_insert=$(echo $jit_insert | sed 's/\//\\\//g')
                sed -i "0,/<\/project>/s/<\/project>/$escaped_insert\n<\/project>/" pom.xml 
                
                if [ ! -z "$test" ] ; then
                    echo "**** run test ****"
                    if [ "$test" = "ALL" ]; then
                        mvn -Drat.skip=true test > "$cwd"/$RTS_TRACE_DIR/$subN/$revN/RTS_TRACE_OUTPUT.txt
                    else
                        mvn -Drat.skip=true -Dtest=$test test > "$cwd"/$RTS_TRACE_DIR/$subN/$revN/RTS_TRACE_OUTPUT.txt
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
                cp -r $RTS_TRACE_DIR/$subN/workingDir/core/data/. $RTS_TRACE_DIR/$subN/$revN          
			fi
		done
	fi
    #idx=idx+1
#done