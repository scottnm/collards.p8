import sys

def main():
    for line in sys.stdin:
        text = line.rstrip()
        if 'q' == text:
            break
        print("ECHOD: %s" % text)

if __name__ == "__main__":
    main()
