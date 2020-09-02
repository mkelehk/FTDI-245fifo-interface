#-*- coding:utf-8 -*-
# Python2.7 x86

# Function: Function: Verify the correctness of the data received by the host computer

import sys, time
import numpy as np
from warnings import filterwarnings

datatype = np.uint16

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

    datas = []
    tx_data = bytearray(16)
    rx_cnt = 0
    
    time_start = time.time()
    for ii in range(4):
        for jj in range(4):
            data = bytes(65536)
            usb.writePipe(0x02+0, bytes(tx_data), len(tx_data))  # While receiving massive data, scattered transmit a few data to verify the stability of FPGA code
            tx_data[-1] += 1
            rxc = usb.readPipe(0x82, data, len(data))
            rx_cnt += rxc
            datas.append(data[:rxc])
        print("    recieved %dB" % rx_cnt)
    time_cost   = time.time() - time_start
    print("\n  time:%.2fs   rate:%.2fMBps" % (time_cost,rx_cnt/time_cost/1000000.0) )
    usb.close()
    
    print("\n  Verify...")

    # 将接收到的所有数据合成一个 numpy 数组，相邻两字节合并，元素类型为 uint16
    for ii,data in enumerate(datas):
        arr_tmp = np.frombuffer(data, dtype=datatype)
        if ii==0:
            arr = arr_tmp
        else:
            arr = np.append(arr,arr_tmp)
        
    filterwarnings("ignore",category=RuntimeWarning)
    
    # 下位机发送规则为递增数组，在上位机验证数组是否为递增，以验证USB传输的正确性
    corrent_cnt, uncorrect_cnt = 0, 0
    for i in range(len(arr)-1):
        if arr[i+1]-arr[i] == datatype(1):
            corrent_cnt += 1
        else:
            #print('     Error at %d:   %08x  %08x' % (i+1, arr[i], arr[i+1]) )
            uncorrect_cnt += 1
    print('    correct count %d     error count %d\n' % (corrent_cnt, uncorrect_cnt))
    
