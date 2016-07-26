#!/usr/bin/python

import sys,json,base64,binascii
with open(sys.argv[1]) as fp:
    pkey=json.load(fp)

def enc(data):
    missing_padding = 4 - len(data) % 4
    if missing_padding:
      data += b'='* missing_padding
    return '0x'+binascii.hexlify(base64.b64decode(data,b'-_')).upper()

for k,v in pkey.items(): 
    if k == 'kty': continue 
    pkey[k] = enc(v.encode())

print "asn1=SEQUENCE:private_key\n[private_key]\nversion=INTEGER:0"
print "n=INTEGER:{0}".format(pkey[u'n'])
print "e=INTEGER:{0}".format(pkey[u'e'])
print "d=INTEGER:{0}".format(pkey[u'd'])
print "p=INTEGER:{0}".format(pkey[u'p'])
print "q=INTEGER:{0}".format(pkey[u'q'])
print "dp=INTEGER:{0}".format(pkey[u'dp'])
print "dq=INTEGER:{0}".format(pkey[u'dq'])
print "qi=INTEGER:{0}".format(pkey[u'qi'])
