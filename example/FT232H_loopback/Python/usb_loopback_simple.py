#-*- coding:utf-8 -*-
# Python3

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
            usb.setTimeouts(1000,1000)
            usb.setUSBParameters(BUFFER_SIZE,BUFFER_SIZE)
            usb.setBitMode(0xff, 0x40)
            print('\n  opened usb[%d]: %s\n' % (i, str(usb.description, encoding = "utf8"),) )
            return True, usb
        else:
            usb.close()
    return False, None
            
sendbytes = b'abcdefghijklmnop'
            
if __name__ == '__main__':
    ret, usb = openUSB( USB_DEVICE_NAME )
    
    if ret:
        usb.write(sendbytes)
        print('    send %s' % (sendbytes,) )
        recvbytes = usb.read(BUFFER_SIZE)
        print('    recv %s' % (recvbytes,) )
        usb.close()
        if(sendbytes==recvbytes):
            print('\n  === loopback test passed! ===\n')
        else:
            print('\n  *** loopback test failed! ***\n')
    else:
        print("USB open Failed!")
    