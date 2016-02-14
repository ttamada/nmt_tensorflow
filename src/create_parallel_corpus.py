# -*- coding: utf-8 -*-

# import xml.etree.ElementTree as ET
from bs4 import BeautifulSoup
import argparse
import re




parser = argparse.ArgumentParser(description='Create a parallel corpus (two text files with sentences line by line) for the given two TED xml files')
parser.add_argument('file_en', metavar='FILE1', type=str,
                   help='TED xml file (English)')
parser.add_argument('file_other', metavar='FILE2', type=str,
                   help='TED xml file (Non English)')
# parser.add_argument('dir', type=str, help='Target directory')
args = parser.parse_args()



output_en = open(args.file_en.replace(".xml","")+"_sents.txt", "w")
output_other = open(args.file_other.replace(".xml","")+"_sents.txt", "w")

with open(args.file_en) as f:
    content_en = f.read()
soup_en = BeautifulSoup(content_en)
with open(args.file_other) as f:
    content_other = f.read()
soup_other = BeautifulSoup(content_other)

comps_en = []
comps_other = []
num_sents = 0
for seekvideo_other in soup_other.find_all("seekvideo"):
    id = seekvideo_other["id"]
    tag = seekvideo_other.name
    seekvideo_en = soup_en.find(tag, {"id":id})
    if seekvideo_en != None and seekvideo_other != None:
        comps_en.append(seekvideo_en.text)
        comps_other.append(seekvideo_other.text)

        if re.search(r"\.$", seekvideo_en.text):
            num_sents += 1
            if num_sents % 10 == 0:
                print str(num_sents)+" written in the output file"

            sent_en = " ".join(comps_en)
            sent_other = " ".join(comps_other)
            output_en.write(sent_en.encode("utf-8")+"\n")
            output_other.write(sent_other.encode("utf-8")+"\n")
            print sent_en, sent_other
            comps_en = []
            comps_other = []

output_en.close()
output_other.close()





