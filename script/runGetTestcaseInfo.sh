#!/bin/bash
project_name="commons-net"
# surefireのレポートのパス
surefire_dir="../../${project_name}/target/surefire-reports/"

# seloggerのデータのパス
selogger_dir="../${project_name}/data/selogger/"

# outputするファイル名を指定.csv形式
sure_output_file="${project_name}/${project_name}-surefire.csv"

for xml_file in "$surefire_dir"/*.xml; do
    if [ -f "$xml_file" ]; then
        echo "Processing $xml_file"
        python3 getTestcaseInfoFromSurefire.py "$xml_file" "$sure_output_file"
        echo "Finished processing $xml_file"
    fi

done
