#!/bin/bash
HOME_DIR=".."
REVISIONS_DIR="$HOME_DIR/original_source"
ALL_DIR="$HOME_DIR/ALL"

# ファイルの内容を修正する関数
modify_first_line() {
    # 1行目を読み込み，先頭の'|'を削除して変数に格納
    first_line=$(head -n 1 "$1" | sed 's/^|//')

    # 修正した1行目をファイルに上書き
    echo "$first_line" > "$1"
    
    echo "First line in $1 updated successfully."
}

subN=commonsJXPATH

for i in {5..50}; do
    revN="rev_$i"
    filename="$ALL_DIR/$subN/$revN/testMethodList.txt"

    if [ ! -f "$filename" ]; then
        echo "Error: File not found - $filename"
        exit 1
    fi

    if [ ! -r "$filename" ]; then
        echo "Error: Cannot read file - $filename"
        exit 1
    fi

    # ファイルの内容を修正
    modify_first_line "$filename"

done