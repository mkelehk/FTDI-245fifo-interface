#-*- coding:utf-8 -*-
# Python3

# Function: Function: Verify the correctness of the data received by the host computer

from warnings import filterwarnings
import numpy as np
import ftd2xx

datatype = np.uint8

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
        tx_data = bytearray(8)
        rx_cnt  = 0
        datas = []
        
        for ii in range(4):
            for jj in range(4):
                usb.write(bytes(tx_data))     # While receiving massive data, scattered transmit a few data to verify the stability of FPGA code
                tx_data[-1] += 1
                data = usb.read(BUFFER_SIZE)  # receiving massive data
                datas.append(data)
                rx_cnt += len(data)
            print("  recieved %dB" % (rx_cnt, ) )
        usb.close()
        
        # Combine all received data into a numpy array
        for ii,data in enumerate(datas):
            arr_tmp = np.frombuffer(data, dtype=datatype)
            if ii==0:
                arr = arr_tmp
            else:
                arr = np.append(arr,arr_tmp)
            
        print("\n  Verify...")
        filterwarnings('ignore')
        
        # In order to verify the correctness of USB transmission, the sending rule of the FPGA is incremental array, and the array is verified by the host computer.
        corrent_cnt, uncorrect_cnt = 0, 0
        for i in range(len(arr)-1):
            if arr[i+1]-arr[i] == datatype(1):
                corrent_cnt += 1
            else:
                #print('     Error at %d:   %08x' % (i+1, arr[i],) )
                uncorrect_cnt += 1
        print('\n  Correct count:%d     Error count:%d\n' % (corrent_cnt, uncorrect_cnt))
    else:
        print("\n  *** USB open failed! ***\n")

    
    