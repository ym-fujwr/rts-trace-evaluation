import json
import sys

def main(json_file_path):
    try:
        with open(json_file_path, 'r') as json_file:
            json_data = json.load(json_file)
        
        events = json_data.get('events')
        num = [0, 0, 0, 0]
        
        for event in events:
            event_type = event.get('event')
            freq = event.get('freq')
            
            if event_type == "CALL":
                num[1] += freq
                num[3] +=1
            num[0] += freq
            num[2] += 1
        
        with open('metrics.csv', 'w') as csv_file:
            csv_file.write("ALL,CALL,UniqueALL,UniqueCALL\n")
            metrics_num = ','.join(map(str, num))
            csv_file.write(metrics_num)
        
    except Exception as e:
        print(e)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <json_file_path>")
    else:
        json_file_path = sys.argv[1]
        main(json_file_path)
