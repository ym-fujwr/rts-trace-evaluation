import sys
import json
import re


diff_file_path = sys.argv[1]
json_file_path = sys.argv[2]
output_file_path = sys.argv[3]

with open(diff_file_path,'r') as file:
    lines = file.readlines()

diff_info = []
file_name = None 
line_number = None
## git diff　を読み込んで， [([クラス名，line[1,2,..])(クラス名,line[6,7...])]の形で抽出
if lines:
    for line in lines:
        if line.startswith('+++ b/'):
            if file_name is None:
                file_name = line.strip()[6:-5]
                line_number=[]
            else:
                diff_info.append((file_name,line_number))
                file_name = line.strip()[6:-5]
                line_number=[]
        else:
            if "@@" in line:
                token = re.findall(r'@@|[+-]?\d+', line)
                if "-" in token[1]:
                    if "+" in token[2]:
                        start_line = token[2].lstrip("+")
                        if "@@" in token[3]:
                            number = 1
                        else:
                            number = token[3]
                    else:
                        start_line = token[3].lstrip("+")
                        if "@@" in token[4]:
                            number = 1
                        else:
                            number = token[4]                       
                    
            # start_line , number = line.split(',')
                line_number = line_number + list(range(int(start_line),int(start_line) + int(number)))

    diff_info.append((file_name,line_number))

## json読み込み
with open(json_file_path,'r') as json_file:
    dependency = json.load(json_file)

selected_test = []

##テストクラスに追加があった場合
for diff in diff_info:
    diff_file_name ,diff_line_list = diff
    if diff_file_name.startswith('src/test/') :

        selected_test.append(diff_file_name.strip()[14:].replace("/","."))

##実行経路みてる
for d in dependency:
    testName = d["testName"]
    classInfoList = d["classInfoList"]
    for c in classInfoList:
        class_Name = c["className"]
        line_list = c["line"]
        for diff in diff_info:
            diff_file_name ,diff_line_list = diff
            if diff_file_name.endswith(class_Name):
                common = list(set(line_list) & set(diff_line_list))
                if common :
                    selected_test.append(testName.replace("/","."))
                    break


with open(output_file_path,'w') as output_file:
    output_file.write(",".join(selected_test))
