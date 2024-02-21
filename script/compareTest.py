import sys
import csv

def read_file(file_path):
    try:
        with open(file_path, 'r') as file:
            content = file.read().split(',')
            non_empty_content = {element for element in content if element.strip()}
            return non_empty_content
    except FileNotFoundError:
        print(f"Error: File not found at {file_path}")
        sys.exit(1)

def main():
    if len(sys.argv) != 6:
        print("Usage: python script.py <rts_test_path> <acc_test_path>")
        sys.exit(1)

    rts_test_path = sys.argv[1]
    acc_test_path = sys.argv[2]
    output_pathA = sys.argv[3]
    output_pathB = sys.argv[4]
    revN = sys.argv[5]

    rts_set = read_file(rts_test_path)
    acc_set = read_file(acc_test_path)
    list_rts = set()
    list_acc = set()
    ##テストクラスを抽出して，テストクラス#で始まるメソッドは除外
    rts_TestClass = set(element for element in rts_set if '#' not in element)
    acc_TestClass = set(element for element in acc_set if '#' not in element)
    for a in rts_set:
        if not any(a.startswith(element+"#")  for element in rts_TestClass):
            list_rts.add(a)
    for b in acc_set:
        if not any(b.startswith(element+"#") or b == element for element in acc_TestClass):
            list_acc.add(b)

    common_elements = list_rts.intersection(list_acc)
    only_in_rts = list_rts - list_acc
    only_in_acc = list_acc - list_rts
    count_in_rts = len(list_rts)
    count_in_acc = len(list_acc)
    count_in_testclass_acc = len(acc_TestClass)
    count_common = len(common_elements)
    count_only_in_rts = len(only_in_rts)
    count_only_in_acc = len(only_in_acc)
    with open(output_pathA, 'a', newline='') as output_file:
        csv_writer = csv.writer(output_file)
        csv_writer.writerow([count_in_acc, count_in_testclass_acc, count_only_in_acc])
        
    with open(output_pathB, 'a') as output_file:
        output_file.write(f"リビジョン：{revN}\n")
        output_file.write(f"選択すべきテストメソッド：{list_acc},{count_in_acc}\n")
        output_file.write(f"選択すべきテストクラス：{acc_TestClass}\n")
        output_file.write(f"提案手法で漏れていたテスト：{only_in_acc},{count_only_in_acc}\n")
        
if __name__ == "__main__":
    main()
