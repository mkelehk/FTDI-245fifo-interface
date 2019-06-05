#coding:utf-8
# Python2.7.12 x86
# WangXuan

import sys
import ftd3xx
from struct import pack
if sys.platform == 'win32':
    import ftd3xx._ftd3xx_win32 as _ft
elif sys.platform == 'linux2':
    import ftd3xx._ftd3xx_linux as _ft

    

if __name__ == '__main__':
    D3XX = ftd3xx.create(0, _ft.FT_OPEN_BY_INDEX)
    if D3XX is None:
        print("ERROR: Can't find or open Device!")
        sys.exit()

    if (sys.platform == 'win32' and D3XX.getDriverVersion() < 0x01020006):
        print("ERROR: Old kernel driver version. Please update driver!")
        D3XX.close()
        sys.exit()
        
    devDesc = D3XX.getDeviceDescriptor()
    if devDesc.bcdUSB < 0x300:
        print("Warning: Device is NOT connected using USB3.0 cable or port!")

    cfg = D3XX.getChipConfiguration()
    
    numChannels = [4, 2, 1, 0, 0]
    numChannels = numChannels[cfg.ChannelConfig]
    if numChannels!=1:
        print("Number of Channels invalid! (numChannels=%d)" % (numChannels,) )
    
    while True:
        num_str = input("input a binary:")
        if num_str == 'q' or num_str == 'e':
            break
        try:
            exec("a=0b"+num_str)
            buffer = pack('h', a)
            buffer *= 8
            res = D3XX.writePipe(0x02+0, buffer, len(buffer))
            print("%dB transferred!" % (res,) )
        except:
            print("input invalid!")
    
    D3XX.close()