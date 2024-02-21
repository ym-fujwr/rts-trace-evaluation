#!/bin/bash
HOME_DIR=".."
REVISIONS_DIR="$HOME_DIR/original_source"
EKSTAZI_DIR="$HOME_DIR/Ekstazi"


function Ekstazi_integrate {
		echo "**** Ekstazi INTEGRATE FUNCTION ***"
		local pom="$1/pom.xml"
		if [ -f ${pom} ]; then
			echo "***** FOUND pom.xml at: ${pom}"
      		#ekstaziの情報を記述．
      		sed -i '0,/<\/plugins>/s/<\/plugins>/<plugin>\n<groupId>org.apache.maven.plugins<\/groupId>\n<artifactId>maven-surefire-plugin<\/artifactId>\n<configuration>\n<argLine>-javaagent:..\/..\/..\/org.ekstazi.core-5.3.0.jar=mode=junit<\/argLine>\n<\/configuration>\n<\/plugin>\n<\/plugins>/' ${pom}
			# jitwatch
			# sed -i '0,/<\/project>/s/<\/project>/<build>\n<plugins>\n<plugin>\n<groupId>org.apache.maven.plugins<\/groupId>\n<artifactId>maven-surefire-plugin<\/artifactId>\n<configuration>\n<argLine>-javaagent:..\/..\/..\/..\/org.ekstazi.core-5.3.0.jar=mode=junit<\/argLine>\n<\/configuration>\n<\/plugin>\n<\/plugins>\n<\/build>\n<\/project>/' ${pom}
		
		fi
}

#各プロジェクト順番に実行
#for subN in $(ls $REVISIONS_DIR/); do
	subN=hilbertCurve
	if [ -d $REVISIONS_DIR/$subN ]; then
		echo "*** RUN Ekstazi on project: $subN"
		mkdir $EKSTAZI_DIR/$subN
		mkdir $EKSTAZI_DIR/$subN/workingDir

		for i in {1..25}; do
			## jacksonXML ALL時にfailしたリビジョンを除く
			# if [ $i -ge 10 ] && [ $i -le 16 ]; then
            #     continue
            # fi
			# if [ $i -ge 29 ] && [ $i -le 44 ]; then
			# 	continue
			# fi
			##

			## NuProcess
			# if [ $i -eq 32 ]; then
			# 	continue
			# fi
			# if [ $i -eq 39 ]; then
			# 	continue
			# fi
			
			## hilbertCurve
			if [ $i -eq 14 ]; then
				continue
			fi
			##
			revN="rev_$i"
			if [ -d $REVISIONS_DIR/$subN/$revN ] ; then
				echo "**** RUN $subN with revision: $revN"
				mkdir $EKSTAZI_DIR/$subN/$revN
				cp -r -f $REVISIONS_DIR/$subN/$revN/* $EKSTAZI_DIR/$subN/workingDir
				Ekstazi_integrate "$EKSTAZI_DIR/$subN/workingDir"
				# Ekstazi_integrate "$EKSTAZI_DIR/$subN/workingDir/core"
				echo "**** maven run Ekstazi ****"
				cwd=$(pwd)
				cd $EKSTAZI_DIR/$subN/workingDir
				# cd $EKSTAZI_DIR/$subN/workingDir/core
				# mvn -Drat.skip=true -DargLine="-javaagent:../../../org.ekstazi.core-5.3.0.jar=mode=junit" test > "$cwd"/$EKSTAZI_DIR/$subN/$revN/EkstaziRTSOutput.txt
				mvn -Drat.skip=true test > "$cwd"/$EKSTAZI_DIR/$subN/$revN/EkstaziRTSOutput.txt
				cd "$cwd"
				cp -r $EKSTAZI_DIR/$subN/workingDir/.ekstazi $EKSTAZI_DIR/$subN/$revN
				# cp -r $EKSTAZI_DIR/$subN/workingDir/core/.ekstazi $EKSTAZI_DIR/$subN/$revN
			fi
		done
	fi
#done 
