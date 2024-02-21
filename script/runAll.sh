#!/bin/bash
HOME_DIR=".."
REVISIONS_DIR="$HOME_DIR/original_source"
ALL_DIR="$HOME_DIR/ALL"

jit_insert="<build>\n<plugins>\n<plugin>\n<groupId>org.apache.maven.plugins</groupId>\n<artifactId>maven-compiler-plugin</artifactId>\n<version>3.8.1</version>\n<configuration>\n<source>7</source>\n<target>7</target>\n</configuration>\n</plugin>\n</plugins>\n</build>\n"

#各プロジェクト順番に実行
#for subN in $(ls $REVISIONS_DIR/); do
	subN=commonsNet
	surefire_dir="target/surefire-reports/"

	if [ -d $REVISIONS_DIR/$subN ]; then
		echo "*** RUN ALL: $subN"
		mkdir $ALL_DIR/$subN
		mkdir $ALL_DIR/$subN/workingDir

		for i in {1..50}; do
			revN="rev_$i"
			if [ -d $REVISIONS_DIR/$subN/$revN ] ; then
				echo "**** RUN $subN with revision: $revN"
				mkdir $ALL_DIR/$subN/$revN
				cp -r -f $REVISIONS_DIR/$subN/$revN/* $ALL_DIR/$subN/workingDir
				echo "**** maven run ****"
				cwd=$(pwd)
				cd $ALL_DIR/$subN/workingDir
				## jitwatchのみ
				# cd $ALL_DIR/$subN/workingDir/core
				## 下は多分いらない
				# escaped_insert=$(echo $jit_insert | sed 's/\//\\\//g')
				# sed -i "0,/<\/project>/s/<\/project>/$escaped_insert\n<\/project>/" pom.xml 
				# sed -i 's/${jdk.version}/1.7/g' pom.xml
				mvn -Drat.skip=true test > "$cwd"/$ALL_DIR/$subN/$revN/mvnRunOutput.txt
				## testMethod名をtestMethodList.txtに．
				for xml_file in "$surefire_dir"/*.xml; do
					if [ -f "$xml_file" ]; then
						# echo "Processing $xml_file"
						python3 "$cwd"/getTestcaseInfoFromSurefire.py "$xml_file"
						# echo "Finished processing $xml_file" 
					fi
				done
				cp -r -f testMethodList.txt "$cwd"/$ALL_DIR/$subN/$revN/.
				rm testMethodList.txt
				cd "$cwd"
			fi
		done
	fi
#done 
