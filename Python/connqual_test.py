# Script: ConnQuality-Test.Py

import time, os, sys, requests
from datetime import datetime

test_url = "https://codeload.github.com/Significant-Gravitas/AutoGPT/zip/refs/tags/v0.4.7"

def check_download_link(url):
    r = requests.get(url)
    if r.status_code != 200:
        print("Download link not available")
        sys.exit()

def download_file_part(download_path, file_size, start=0):
    with open(download_path, 'ab') as f:
        while True:
            chunk = os.stat('test.txt').st_size - (start * 1024) if os.path.exists("test.txt") else 0
            if not chunk:
                break
            chunk = min(chunk, file_size-start)
            f.write(requests.get(test_url).content)
            start += chunk
            print('Downloaded {} MB'.format((start // (1024 * 1024)) / 10), end='\r')
            if os.path.exists("test.txt"):
                print("\nSuccessfully downloaded the file!")
            else:
                print("\nWaiting for confirmation...", end='', flush=True)

def main():
    print("Script Initiation Complete!")
    now = datetime.now()
    time_interval = int(60 * 5) # 5 minutes in seconds
    while True:
        download_file_part('test.txt', 1, start=time.time())
        sleep_time = time_interval - (time.time() % time_interval)
        print("Sleeping for {} seconds".format(sleep_time))
        time.sleep(sleep_time)

if __name__ == "__main__":
    main()