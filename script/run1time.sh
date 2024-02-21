#!/bin/bash

HOME_DIR=".."
REVISIONS_DIR="$HOME_DIR/original_source"
ALL_DIR="$HOME_DIR/ALL"
RTS_TRACE_DIR="$HOME_DIR/sample"


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
		mkdir -p $RTS_TRACE_DIR/$subN/workingDir/core/data/selogger
        mkdir -p $RTS_TRACE_DIR/$subN/workingDir/core/data/json
        mkdir -p $RTS_TRACE_DIR/$subN/workingDir/core/data/token
        cp -f $HOME_DIR/rts-trace-1.0-SNAPSHOT-jar-with-dependencies.jar $RTS_TRACE_DIR/$subN/workingDir/


		for i in {50..50}; do
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
			

			revN="rev_$i"
			if [ -d $REVISIONS_DIR/$subN/$revN ] ; then
				echo "**** RUN $subN with revision: $revN ****"
				mkdir $RTS_TRACE_DIR/$subN/$revN
				cp -r -f $REVISIONS_DIR/$subN/$revN/. $RTS_TRACE_DIR/$subN/workingDir/
                cp -f $ALL_DIR/$subN/$revN/testMethodList.txt $RTS_TRACE_DIR/$subN/workingDir/
                cwd=$(pwd)
                cd $RTS_TRACE_DIR/$subN/workingDir/core
                # NuProcess用
                # file_path="pom.xml"
                # remove_line "$file_path"

                ## jitwatch
                escaped_insert=$(echo $jit_insert | sed 's/\//\\\//g')
                sed -i "0,/<\/project>/s/<\/project>/$escaped_insert\n<\/project>/" pom.xml 
                # mvn -Drat.skip=true -DargLine="-javaagent:../../../../selogger-0.5.1-x.jar=output=./data/selogger,format=freq,weaverlog=data/selogger/log.txt,${plugins[$idx]},weave=EXEC+FIELD+LINE,logsave=partial,lognested=true,logstart=###METHOD_ENTRY,logend=###METHOD_EXIT" test
                mvn -Drat.skip=true test
                java -jar "$cwd"/$HOME_DIR/rts-trace-1.0-SNAPSHOT-jar-with-dependencies.jar create

                cd "$cwd"
                cp -r $RTS_TRACE_DIR/$subN/workingDir/core/data/. $RTS_TRACE_DIR/$subN/$revN

                rm -fR $RTS_TRACE_DIR/$subN/workingDir/core/data/selogger/*
                rm -fR $RTS_TRACE_DIR/$subN/workingDir/core/data/json/*
                rm -fR $RTS_TRACE_DIR/$subN/workingDir/core/data/token/*
			fi
		done
	fi
    #idx=idx+1
#done