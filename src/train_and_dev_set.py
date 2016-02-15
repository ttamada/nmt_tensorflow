
import argparse
import os


parser = argparse.ArgumentParser(description='Create a train and development set out of the given file')
parser.add_argument('file', metavar='FILE', type=str,
                   help='Text file (sentences line by line) to split')
parser.add_argument('--dev_percent', type=int, default=10,
                   help='Percentage of the development set')
# parser.add_argument('--dir', type=str, default=".",
#                    help='Target directory')
args = parser.parse_args()



with open(args.file, "r") as f:
    lines = f.readlines()

b = int(len(lines)*(100 - args.dev_percent)/100)
train_set = lines[0:b]
dev_set = lines[b:]

with open(os.path.splitext(args.file)[0]+"_train"+os.path.splitext(args.file)[1], "w") as f:
    for line in train_set:
        f.write(line)
with open(os.path.splitext(args.file)[0]+"_dev"+os.path.splitext(args.file)[1], "w") as f:
    for line in dev_set:
        f.write(line)



