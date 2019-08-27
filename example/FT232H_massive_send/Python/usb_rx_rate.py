#-*- coding:utf-8 -*-
# Python3

# Function: Measure the persistent bandwidth of data received by host computer

from time import time
import ftd2xx

USB_DEVICE_NAME = b'USB <-> Serial Converter'
BUFFER_SIZE = 65536 * 4

def openUSB(name_byte_array):
    for i in range(16):
        try:
            usb = ftd2xx.open(i)
        except:
            continue
        if usb.description==name_byte_array:
            # These 3 lines of boilerplate are necessary each time you open the device
            usb.setTimeouts(1000,1000)
            usb.setUSBParameters(BUFFER_SIZE,BUFFER_SIZE)
            usb.setBitMode(0xff, 0x40)
            print('\n  opened usb[%d]: %s\n' % (i, str(usb.description, encoding = "utf8"),) )
            return True, usb
        else:
            usb.close()
    return False, None
            


if __name__ == '__main__':
    ret, usb = openUSB( USB_DEVICE_NAME )
    if ret:
        rx_cnt = 0
        time_start = time()
        for ii in range(16):
            try:
                for jj in range(8):
                    data = usb.read(BUFFER_SIZE)
                    rx_cnt += len(data)
                print("  收到%dB" % (rx_cnt, ) )
            except ex:
                print(ex)
        usb.close()
        time_cost = time() - time_start
        print("  time:%.2fs   rate:%.2fMBps" % (time_cost,rx_cnt/(1+time_cost*1000000.0)) )
    else:
        print("\n  *** USB open Failed! ***\n")
        
