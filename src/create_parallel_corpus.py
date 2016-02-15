# -*- coding: utf-8 -*-

# import xml.etree.ElementTree as ET
from bs4 import BeautifulSoup
import argparse
import re
import os




parser = argparse.ArgumentParser(description='Create a parallel corpus (two text files with sentences line by line) for the given two TED xml files')
parser.add_argument('file_en', metavar='FILE1', type=str,
                   help='TED xml file (English)')
parser.add_argument('file_target', metavar='FILE2', type=str,
                   help='TED xml file (Non English)')
# parser.add_argument('dir', type=str, help='Target directory')
args = parser.parse_args()



output_en = open(args.file_en.replace(".xml","")+"_sents.txt", "w")
output_target = open(args.file_target.replace(".xml","")+"_sents.txt", "w")

with open(args.file_en) as f:
    content_en = f.read()
soup_en = BeautifulSoup(content_en)
with open(args.file_target) as f:
    content_target = f.read()
soup_target = BeautifulSoup(content_target)

comps_en = []
comps_target = []

files_target = soup_target.find_all("file")
files_en = soup_en.find_all("file")

def end_of_sent(text):
    if re.search(r"\.$", text) or re.search(r"\?$", text) or re.search(r"\!$", text):
        return True

for file_target in files_target:
    talkid_target = file_target.find("talkid").text
    for file_en in files_en:
        talkid_en = file_en.find("talkid").text
        if talkid_target == talkid_en:
            seekvideos_target = file_target.find_all("seekvideo")
            for i in range(0, len(seekvideos_target)):
                seekvideo_target = seekvideos_target[i]
                seekvideo_en = file_en.find(seekvideo_target.name, {"id":seekvideo_target["id"]})
                if seekvideo_en != None and seekvideo_target != None:
                    comps_en.append(seekvideo_en.text)
                    comps_target.append(seekvideo_target.text)

                    if end_of_sent(seekvideo_en.text) or i==len(seekvideos_target)-1:
                        sent_en = " ".join(comps_en)
                        sent_target = " ".join(comps_target)
                        output_en.write(sent_en.encode("utf-8")+"\n")
                        output_target.write(sent_target.encode("utf-8")+"\n")
                        print sent_en, sent_target
                        comps_en = []
                        comps_target = []
            files_en.remove(file_en)

output_en.close()
output_target.close()


