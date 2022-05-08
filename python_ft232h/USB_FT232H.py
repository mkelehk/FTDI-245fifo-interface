#-*- coding:utf-8 -*-

import ftd2xx


class USB_FT232H_sync245mode():
    
    def __init__(self, name_bytes, timeout=2000):
        self._chunk = 4096
        self._usb = None
        for i in range(16):
            try:
                usb = ftd2xx.open(i)
            except:
                continue
            if usb.description == name_bytes:
                usb.setTimeouts(timeout, timeout)
                usb.setUSBParameters(self._chunk, self._chunk)
                usb.setBitMode(0xff, 0x40)
                print('opened usb[%d]: %s\n' % (i, str(usb.description, encoding = "utf8"),) )
                self._usb = usb
                return
            else:
                usb.close()
        raise Exception('Could not open USB device: %s' % str(name_bytes, encoding = "utf8"))
    
    
    def close(self):
        self._usb.close()
    
    
    def send(self, data):
        txlen = 0
        for ii in range(0, len(data), self._chunk):
            chunk = data[ ii : min(ii+self._chunk, len(data)) ]
            txlen_once = self._usb.write(chunk)
            txlen += txlen_once
            if txlen_once < len(chunk):
                break
        return txlen
    
    
    def recv(self, rxlen):
        data = b''
        for ii in range(rxlen, 0, -self._chunk):
            rxlen_once = min(self._chunk, ii)
            chunk = self._usb.read(rxlen_once)
            data += chunk
            if len(chunk) < rxlen_once:
                break
        return data





if __name__ == '__main__':

    usb = USB_FT232H_sync245mode(name_bytes=b'USB <-> Serial Converter')

    usb.close()












