#! /usr/bin/python

import sys
import serial
import time

#--------------------------------------------------------------------------

def openserial():
	global port
	try:
		port = serial.Serial(sys.argv[2], baudrate=115200, timeout=0.3, stopbits=2)
	except Exception:
		print "Cannot open port '" + sys.argv[2] + "'"
		sys.exit(3)


def sendrecord(record):
#	sys.stdout.write("'"+record+"'\n")
	port.write(record+"\n")
	ack = 'E'
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

openserial()

linecount = 0
retry = 0
while True:
	if retry == 0:
		linecount = linecount + 1
		srec = f.readline()
	if not srec: break
	if retry == 0: sys.stdout.write( "\r" + str(linecount) + ": ")
	sys.stdout.flush()
#	sys.stdout.write(srec)
	if srec[0] != 'S': break
	if sendrecord( srec.strip() ) == 0:
		port.write("\n\n\n\n\n\n")
		port.read(port.inWaiting())

f.close()
port.close()

print "done."
