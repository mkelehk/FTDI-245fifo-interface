#-*- coding:utf-8 -*-
# Python2.7 x86

# Function: Measure the persistent bandwidth of data received by host computer

import sys, time
import numpy as np

def openUSB():
    import ftd3xx
    if sys.platform == 'win32':
        import ftd3xx._ftd3xx_win32 as _ft
    elif sys.platform == 'linux2':
        import ftd3xx._ftd3xx_linux as _ft
    usb = ftd3xx.create(0, _ft.FT_OPEN_BY_INDEX)
    if usb is None:
        print("*** ERROR: Can't find or open Device!")
        return False, None
    if (sys.platform == 'win32' and usb.getDriverVersion() < 0x01020006):
        print("*** ERROR: Old kernel driver version. Please update driver!")
        usb.close()
        return False, None
    if usb.getDeviceDescriptor().bcdUSB < 0x300:
        print("*** Warning: Device is NOT connected using USB3.0 cable or port!")
        return False, None
    cfg = usb.getChipConfiguration()
    numChannels = [4, 2, 1, 0, 0]
    numChannel = numChannels[cfg.ChannelConfig]
    if numChannel != 1:
        print("*** ERROR:Number of Channels invalid! (numChannel=%d)" % (numChannel,) )
        return False, None
    return True, usb

   
if __name__ == '__main__':
    ret, usb = openUSB()
    
    if not ret:
        sys.exit()

    print("\n  Reading...")
    data = bytes(65536*8)
    rx_cnt = 0
    
    time_start = time.time()
    for ii in range(32):
        for jj in range(16):
            rxc = usb.readPipe(0x82, data, len(data))
            rx_cnt += rxc
        print("    recieved %dB" % rx_cnt)
    time_cost   = time.time() - time_start
    print("\n  time:%.2fs   rate:%.2fMBps" % (time_cost,rx_cnt/(1+time_cost*1000000.0) ) )
    usb.close()

