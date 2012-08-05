#!/usr/bin/python

import os

if not os.path.exists("lang.list"):
	print "cache2parallel needs lang.list to work!"
	exit(1)

if not os.path.exists(os.path.expanduser("~/corpus")):
	os.system("mkdir ~/corpus")

lang_config_file = open("lang.list","r")


def cache2parallel(lang_code):
	cache_file = open("cache_"+lang_code+".php")
	cache_file.readline()
	data = cache_file.read()
	cache_file.close()
	data = data.replace("\n","")
	data = data.replace("$tmx[","\n")
	data = data.replace("\"","")	
	data = data.replace(";","")
	data = data.replace("(","")
	data = data.replace(")","")
	parallel_file = open(".tmp", "w")
	parallel_file.write(data[1:])
	parallel_file.close()
	os.system("cut -d \"=\" -f2 .tmp >"+os.path.expanduser("~/corpus/Mozilla."+lang_code))

lang_code=lang_config_file.readline()[:-1]

while lang_code != "":
	cache2parallel(lang_code)
	lang_code=lang_config_file.readline()[:-1]

os.system("rm .tmp")
