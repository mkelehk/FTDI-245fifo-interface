#-*- coding:utf-8 -*-
# Python3

# Function: Generate random bytearray, send and recv(loopback), compare send bytes and recv bytes

from random import randint
import ftd2xx

USB_DEVICE_NAME = b'USB <-> Serial Converter'
BUFFER_SIZE = 65536

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
            
def RandomBytes(size):  # generate a random bytes array
    arr = bytearray(size)
    for i in range(size):
        arr[i] = randint(0,255)
    return bytes(arr)
            
if __name__ == '__main__':
    ret, usb = openUSB( USB_DEVICE_NAME )
    
    if ret:
        for i in range(20):
            sendbytes = RandomBytes(4096)
            usb.write(sendbytes)
            recvbytes = usb.read(BUFFER_SIZE)
            if(sendbytes==recvbytes):
                print('  [%02d] === loopback test passed! ===' % (i,) )
            else:
                print('  [%02d] *** loopback test failed! ***' % (i,) )
        usb.close()
    else:
        print("USB open Failed!")
    