#!/usr/bin/env python  
#coding:utf-8
# Python3
# WangXuan

from time import time
import numpy as np
import ftd2xx

datatype = np.uint16

BUFFER_SIZE = 65536 * 4

def openUSB(name_byte_array):
    for i in range(16):
        try:
            usb = ftd2xx.open(i)
        except:
            continue
        if usb.description==name_byte_array:
            print('opened usb%d: %s' % (i, usb.description,) )
            return usb
        else:
            usb.close()
            
if __name__ == '__main__':
    # These 3 lines of boilerplate are necessary each time you open the device
    usb = openUSB( b'USB <-> Serial Converter' )
    usb.setTimeouts(1000,1000)
    usb.setUSBParameters(BUFFER_SIZE,BUFFER_SIZE)
    usb.setBitMode(0xff, 0x40)

    datas = []
    rx_cnt = 0
    for jj in range(8):
        usb.read(BUFFER_SIZE)
    time_start = time()
    for ii in range(4):
        for jj in range(4):
            data = usb.read(BUFFER_SIZE)
            datas.append(data)
            rx_cnt += len(data)
        print("  收到%dB" % (rx_cnt, ) )

    time_cost   = time() - time_start
    print("  time:%.2fs   rate:%.2fMBps" % (time_cost,rx_cnt/time_cost/1000000.0) )

    # 将接收到的所有数据合成一个 numpy 数组，相邻两字节合并，元素类型为 
    for ii,data in enumerate(datas):
        arr_tmp = np.frombuffer(data, dtype=datatype)
        if ii==0:
            arr = arr_tmp
        else:
            arr = np.append(arr,arr_tmp)
        
    # 下位机发送规则为递增数组，在上位机验证数组是否为递增，以验证USB传输的正确性
    corrent_cnt, uncorrect_cnt = 0, 0
    for i in range(len(arr)-1):
        if arr[i+1]-arr[i] == datatype(0x00001):
            corrent_cnt += 1
        else:
            #print('     在%d处出错:   %x  %x  %x' % (i+1, arr[i], arr[i+1], arr[i+1]-arr[i]) )
            uncorrect_cnt += 1
    print('正确数量%d    错误数量%d' % (corrent_cnt, uncorrect_cnt))
    