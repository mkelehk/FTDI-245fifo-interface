#-*- coding:utf-8 -*-

import sys
import ftd3xx


class USB_FT60X_sync245mode():
    
    def __init__(self, timeout=2000):
        usb = None
        
        if sys.platform == 'win32':
            usb = ftd3xx.create(0, ftd3xx._ftd3xx_win32.FT_OPEN_BY_INDEX)
        elif sys.platform == 'linux2':
            usb = ftd3xx.create(0, ftd3xx._ftd3xx_linux.FT_OPEN_BY_INDEX)
        
        if usb is None:
            raise Exception("Could not find or open Device!")
        
        if sys.platform == 'win32' and usb.getDriverVersion() < 0x01020006:
            usb.close()
            raise Exception("Old kernel driver version. Please update driver!")
        
        if usb.getDeviceDescriptor().bcdUSB < 0x300:
            print("*** Warning: Device is NOT connected using USB3.0 cable or port!")
        
        cfg = usb.getChipConfiguration()
        numChannel = [4, 2, 1, 0, 0][cfg.ChannelConfig]
        if numChannel != 1:
            usb.close()
            raise Exception("Number of Channels invalid! (numChannel=%d)" % (numChannel,) )
        
        usb.setPipeTimeout(0x02, timeout)
        usb.setPipeTimeout(0x82, timeout)
        self._usb = usb
        self._chunk = 16384
    
    
    def close(self):
        self._usb.close()
    
    
    def send(self, data):
        txlen = 0
        for ii in range(0, len(data), self._chunk):
            chunk = data[ ii : min(ii+self._chunk, len(data)) ]
            txlen_once = self._usb.writePipe(0x02, chunk, len(chunk))
            txlen += txlen_once
            if txlen_once < len(chunk):
                break
        return txlen
    
    
    def recv(self, rxlen):
        data = b''
        for ii in range(rxlen, 0, -self._chunk):
            chunk = bytes( min(self._chunk, ii) )
            rxlen_once = self._usb.readPipe(0x82, chunk, len(chunk))
            if rxlen_once < len(chunk):
                data += chunk[0:rxlen_once]
                break
            else:
                data += chunk
        return data





if __name__ == '__main__':

    usb = USB_FT60X_sync245mode()

    usb.close()












