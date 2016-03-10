#!/usr/bin/python

import sys


def create_hexline( f, addr, buf ):
    bytecount = len(buf) + 3 + 1 # 3 address bytes, 1 checksum byte
    databytes = ""
    chksum = (bytecount&255) + ((addr>>16)&0xFF) + ((addr>>8)&0xFF) + (addr&0xFF)
    for b in buffer:
        databytes += "{0:02X}".format(ord(b))
        chksum += ord(b)
    chksum = (~chksum) & 255
    hexline = "S2{0:02X}{1:06X}".format(bytecount, addr)
    hexline += databytes + "{0:02X}".format(chksum)
    return hexline

def create_endblock(addr):
    bytecount = 3 + 1 # 3 address byte + 1 checksum byte
    chksum = (bytecount&255) + ((addr>>16)&0xFF) + ((addr>>8)&0xFF) + (addr&0xFF)
    chksum = (~chksum) & 255
    line = "S8{0:02X}{1:06X}{2:02X}".format(bytecount, addr, chksum)
    return line

#------------------------------------------------------

if len(sys.argv) < 3:
    print "Usage: "
    print sys.argv[0]+" [bin file] [dstaddr (hex)]"
    sys.exit(1)

try:
    f = open( sys.argv[1], "r" )
except Exception:
    print "Cannot open file '" + sys.argv[1] + "'"
    sys.exit(2)

first_addr = 0
try:
    first_addr = int(sys.argv[2], 16)
except ValueError:
    print "No valid address."
    sys.exit(3)

addr = first_addr

while True:
    buffer = f.read(0x10)
    if len(buffer) == 0: break
    line = create_hexline( f, addr, buffer )
    print line
    if len(buffer) < 0x10: break
    addr += 0x10

line = create_endblock(first_addr)
print line
