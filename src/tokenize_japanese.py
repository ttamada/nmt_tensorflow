# -*- coding: utf-8 -*-

import xml.etree.ElementTree as ET
from janome.tokenizer import Tokenizer


tree_ja = ET.parse('../ted_parallel_corpus/ted_ja-20150530.xml')
root = tree_ja.getroot()

t = Tokenizer()

for file in root.iter("file"):
    if file.get("id"):
        for head in file.iter("head"):
            for trans in head.iter("transcription"):
                print trans.tag
                for seekvideo in trans.iter("seekvideo"):
                    if seekvideo.text != None:
                        try:
                            print seekvideo.text
                            tokens = t.tokenize(seekvideo.text)
                        except:
                            try:
                                text = seekvideo.text.replace(u"　", u"、")
                                print text
                                tokens = t.tokenize(text)
                            except:
                                text = seekvideo.text.replace(u"　", u"")
                                print text
                                tokens = t.tokenize(text)
                        for tok in tokens:
                            print tok
