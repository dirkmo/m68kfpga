#! /usr/bin/python

import sys
import serial

#--------------------------------------------------------------------------
def sendrecord(record):
#	sys.stdout.write("'"+record+"'\n")
	port.write(record+"\n")
	ack = port.read(1)
	if ack == 'K':
		return 1
	return 0
#--------------------------------------------------------------------------

if len(sys.argv) < 2:
	print "Usage: "
	print sys.argv[0]+" [srec-file] [port]"
	sys.exit(1)

try:
	f = open( sys.argv[1], "r" )
except Exception:
	print "Cannot open file '" + sys.argv[1] + "'"
	sys.exit(2)

try:
	port = serial.Serial(sys.argv[2], baudrate=115200, timeout=0.3)
except Exception:
	print "Cannot open port '" + sys.argv[2] + "'"
	sys.exit(3)


linecount = 0
retry = 0
while True:
	linecount = linecount + 1
	srec = f.readline()
	if not srec: break
#	sys.stdout.write(srec)
	if srec[0] != 'S': break
	if sendrecord( srec.strip() ) == 0:
		if retry>2:
			print "Error sending line " + str(linecount)
		else:
			retry = retry + 1
	else:
		retry = 0

f.close()
port.close()

