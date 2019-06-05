#coding:utf-8
# Python2.7.12 x86
# WangXuan

import sys
import time
import numpy as np
import warnings
import ftd3xx
warnings.filterwarnings("ignore",category=RuntimeWarning)
if sys.platform == 'win32':
    import ftd3xx._ftd3xx_win32 as _ft
elif sys.platform == 'linux2':
    import ftd3xx._ftd3xx_linux as _ft
    
datatype = np.uint16

   
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
    #DisplayChipConfiguration(cfg)
    
    numChannels = [4, 2, 1, 0, 0]
    numChannels = numChannels[cfg.ChannelConfig]
    if numChannels!=1:
        print("Number of Channels invalid! (numChannels=%d)" % (numChannels,) )
    
    print("\nReading...")

    datas = []
    
    rx_cnt = 0
    for jj in range(8):    #flush
        data = bytes(65536*4)
        D3XX.readPipe(0x82, data, len(data))
    time_start = time.time()
    for ii in range(16):
        for jj in range(32):
            data = bytes(65536*4)
            rxc = D3XX.readPipe(0x82, data, len(data))
            rx_cnt += rxc
            datas.append(data[:rxc])
        print("  recieved %dB" % rx_cnt)
    time_cost   = time.time() - time_start
    print("  time:%.2fs   rate:%.2fMBps" % (time_cost,rx_cnt/time_cost/1000000.0) )
    D3XX.close()
    

    
    # 将接收到的所有数据合成一个 numpy 数组，相邻两字节合并，元素类型为 uint16
    for ii,data in enumerate(datas):
        arr_tmp = np.frombuffer(data, dtype=datatype)
        if ii==0:
            arr = arr_tmp
        else:
            arr = np.append(arr,arr_tmp)
        
    # 下位机发送规则为递增数组，在上位机验证数组是否为递增，以验证USB传输的正确性
    
    corrent_cnt, uncorrect_cnt = 0, 0
    for i in range(len(arr)-1):
        if arr[i+1]-arr[i] == datatype(1):
            corrent_cnt += 1
        else:
            #print('     在%d处出错:   %d  %d' % (i+1, arr[i], arr[i+1]) )
            uncorrect_cnt += 1
    print('正确数量%d    错误数量%d' % (corrent_cnt, uncorrect_cnt))
    
