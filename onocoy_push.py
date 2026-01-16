#!/usr/bin/env python3
import time
import sys

def main():
    print("ONOCOY NTRIP uploader starting...")
    while True:
        print("Uploader alive")
        time.sleep(10)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(0)
