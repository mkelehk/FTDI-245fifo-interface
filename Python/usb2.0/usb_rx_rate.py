#!/usr/bin/env python  
#coding:utf-8
# Python3
# WangXuan

from time import time
import ftd2xx

BUFFER_SIZE = 65536 * 4

def openUSB(name_byte_array):
    for i in range(16):
        try:
            usb = ftd2xx.open(i)
        except:
            continue
        if usb.description==name_byte_array:
            print('opened usb%d: %s' % (i, usb.description,) )
            return usb
        else:
            usb.close()
            

# These 3 lines of boilerplate are necessary each time you open the device
usb = openUSB( b'USB <-> Serial Converter' )
usb.setTimeouts(1000,1000)
usb.setUSBParameters(BUFFER_SIZE,BUFFER_SIZE)
usb.setBitMode(0xff, 0x40)



rx_cnt = 0
time_start = time()
for ii in range(16):
    try:
        for jj in range(8):
            data = usb.read(BUFFER_SIZE)
            rx_cnt += len(data)
        print("  收到%dB" % (rx_cnt, ) )
    except:
        pass
time_cost   = time() - time_start
print("  time:%.2fs   rate:%.2fMBps" % (time_cost,rx_cnt/time_cost/1000000.0) )