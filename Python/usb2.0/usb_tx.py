#!/usr/bin/env python  
#coding:utf-8
# Python3
# WangXuan

from time import time
import numpy as np
import ftd2xx

datatype = np.uint16

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
            
if __name__ == '__main__':
    # These 3 lines of boilerplate are necessary each time you open the device
    usb = openUSB( b'USB <-> Serial Converter' )
    usb.setTimeouts(1000,1000)
    usb.setUSBParameters(BUFFER_SIZE,BUFFER_SIZE)
    usb.setBitMode(0xff, 0x40)

    usb.write('123456')
    usb.close()
    