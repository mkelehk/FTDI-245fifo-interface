#-*- coding:utf-8 -*-
# Python2.7 x86

import sys
import ftd3xx


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
    
    
sendbytes = b'abcdefgh01234567'
recvbytes = bytes(1024)

if __name__ == '__main__':
    ret, usb = openUSB()
    
    if ret:
        txc = usb.writePipe(0x02, sendbytes, len(sendbytes))
        print('    send %s' % (sendbytes,) )
        rxc =  usb.readPipe(0x82, recvbytes, len(recvbytes))
        recvbytes = recvbytes[:rxc]
        print('    recv %s' % (recvbytes,) )
        usb.close()
        
        if sendbytes==recvbytes and txc==rxc:
            print('\n  === loopback test passed! ===\n')
        else:
            print('\n  *** loopback test failed! ***\n')
