#!/usr/bin/python

import sys
TOLERANCE = 0.1


if len(sys.argv)==1:
	print "USAGE:: ./extract-phrases <input_file> {output_file}"
	print "Output file defaults to \"revised-phrases\""
	exit(1)
elif len(sys.argv)==2:
	fOutput="revised-phrases"
else:
	fOutput=sys.argv[2]

try:
	InFile=open(sys.argv[1],'r')
except:
	print "Error. File Cannot be Opened."
	exit(1)

OutFile=open(fOutput,'w')

def extractPhrases():
	def freadLine(InFile):
		fLine=InFile.readline()
		if fLine == "":
			exit(1)
		dataList=fLine.split(" ")
		return dataList, fLine
	def fwriteLine(OutFile, line):
		OutFile.write(line)
	def process():
		dataList,line = freadLine(InFile)
		if float(dataList[2]) > TOLERANCE:
			fwriteLine(OutFile, line)
	while 1:
		process()


extractPhrases()
InFile.close()
OutFile.close()
