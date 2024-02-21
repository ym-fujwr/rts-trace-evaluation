import json
import sys

json_file_path = sys.argv[1]
testName = sys.argv[2]

with open(json_file_path, 'r') as json_file:
    json_data = json.load(json_file)

for test in json_data:
    if testName in test['testName']:
        with open('output2.txt',mode='a') as file:
            json.dump(test, file, indent=2)

