#-*- coding:utf-8 -*-
# Python3

import time

from USB_FT60X import USB_FT60X_sync245mode
   
if __name__ == '__main__':
    
    # timeout 是超时值（毫秒），如果在 timeout 时间内发送失败或没接收到预期的数据量，send 或 recv 函数就会提前结束
    usb = USB_FT60X_sync245mode(timeout=4000)

    print("\n  Reading...")
    
    rxlen_total = 0
    time_start = time.time()
    for ii in range(32):
        for jj in range(16):
            recv_data = usb.recv(16384)
            rxlen_total += len(recv_data)
        print("    recv %dB" % rxlen_total)
    
    time_cost = time.time() - time_start
    print("\n  time:%.2fs   rate:%.2fMBps" % (time_cost,rxlen_total/(1+time_cost*1000000.0) ) )

    usb.close()
    