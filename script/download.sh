#!/bin/bash

HOME_DIR=".."

#実験対象のプロジェクトのパス置く
REVISIONS_DIR="$HOME_DIR/original_source"
EKSTAZI_DIR="$HOME_DIR/Ekstazi"
RTS_TRACE_DIR="$HOME_DIR/rts-trace"
ALL_DIR="$HOME_DIR/ALL"

#実験結果を置くフォルダ作成
# mkdir $REVISIONS_DIR
# mkdir $EKSTAZI_DIR
# mkdir $RTS_TRACE_DIR
# mkdir $ALL_DIR


cat ../repositories.txt |
while IFS=" " read -r pName pURL pRevSNum; do
	if [[ -z "$pName" ]]; then
		break
	fi

	# echo "### Clone project " $pName

	# mkdir -p "$REVISIONS_DIR/$pName"
	# echo "***" git clone $pURL "$REVISIONS_DIR/$pName/$pName"
	# git clone $pURL "$REVISIONS_DIR/$pName/$pName"

	idx=1
	max_idx=50

	cat $REVISIONS_DIR/$pName/revisions.txt |
	while IFS= read -r hashID; do
		if [[ -z "$hashID" ]]; then
			echo "skip hashID because the value is $hashID"
			continue
		fi

		git clone $pURL "$REVISIONS_DIR/$pName/rev_$idx"
		cwd=$(pwd)
		cd $REVISIONS_DIR/$pName/rev_$idx
		git checkout -f $hashID
		cd "$cwd"

		if ((idx >= max_idx)); then
			break
		fi

		idx=$((idx + 1))
	done
done

