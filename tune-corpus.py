#!/usr/local/bin/python

import os


def tune_corpus(lang_code1,lang_code2):
	lang1_file = open("Mozilla_unclean.hi."+lang_code1,"r")
	lang2_file = open("Mozilla_unclean.hi."+lang_code2,"r")
	lang1_clean = open("Mozilla."+lang_code1,"w")
	lang2_clean = open("Mozilla."+lang_code2,"w")
	data1 = lang1_file.readline()
	data2 = lang2_file.readline()
	while not (data1 == "" and data2 == ""):
		if data1 == data2:
			pass
		else:
			lang1_clean.write(data1)
			lang2_clean.write(data2)
		data1 = lang1_file.readline()
		data2 = lang2_file.readline()
	lang1_file.close()
	lang1_clean.close()
	lang2_file.close()
	lang2_clean.close()

tune_corpus("hi","en")
		
	
			
		

