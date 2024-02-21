#!/bin/bash

HOME_DIR=".."

#実験対象のプロジェクトのパス置く
REVISIONS_DIR="$HOME_DIR/original_source"
EKSTAZI_DIR="$HOME_DIR/Ekstazi"
RTS_TRACE_DIR="$HOME_DIR/rts-trace"
ALL_DIR="$HOME_DIR/ALL"

#実験結果を置くフォルダ作成
mkdir $REVISIONS_DIR
mkdir $EKSTAZI_DIR
mkdir $RTS_TRACE_DIR
mkdir $ALL_DIR


cat ../repositories.txt |
while IFS=" " read -r pName pURL pRevSNum; do
	if [[ -z "$pName" ]]; then
		break
	fi

	echo "### Clone project " $pName

	mkdir -p "$REVISIONS_DIR/$pName"
	echo "***" git clone $pURL "$REVISIONS_DIR/$pName/$pName"
	git clone $pURL "$REVISIONS_DIR/$pName/$pName"
	cd $REVISIONS_DIR/$pName/$pName
	git checkout $pRevSNum
	git log -n 50 --pretty=format:"%H" -- **/*.java | tac | while IFS= read -r commit_hash; do #jitwatch -> core/**/*.java
    	echo "$commit_hash" >> ../revisions.txt
	done
done
