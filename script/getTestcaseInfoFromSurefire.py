import xml.etree.ElementTree as ET
import sys
import csv

#sys.argv[1]にxmlファイル名

#xmlデータを読み込み
tree = ET.parse(sys.argv[1])
#一番上の階層の要素を取り出します
root = tree.getroot()
output_file = "testMethodList.txt"
testsuite_name = root.get('name')
testcases = root.findall('.//testcase')
names = [testcase.get('name')for testcase in testcases]
def convert(name):
        if '(' in name:
            idx = name.find('(')
            return name[0:idx]
        elif '[' in name:
            idx = name.find('[')
            return name[0:idx]
        else:
            return name

result = map(convert,names)

##正規表現で出力 これ使う．
with open(output_file,mode='a',newline='') as file:
    file.write("|")
    file.write("|".join(result))
    