import sys

if len(sys.argv) != 4:
    print("Usage: python script.py fileA_path fileB_path")
    sys.exit(1)

fileA_path = sys.argv[1]
fileB_path = sys.argv[2]
output_path = sys.argv[3]

# ファイルAを読み込みます
with open(fileA_path, 'r') as fileA:
    test_classes = fileA.read().splitlines()

# ファイルBを読み込みます
with open(fileB_path, 'r') as fileB:
    test_counts = fileB.read().splitlines()

test_counts = test_counts[:-1]
selected_tests = [test_classes[i] for i in range(len(test_counts)) if int(test_counts[i]) != 0]

with open(output_path, 'w') as output_file:
    output_file.write(','.join(selected_tests))

