#-*- coding:utf-8 -*-
# Python3

from USB_FT60X import USB_FT60X_sync245mode
   
if __name__ == '__main__':
    
    # timeout 是超时值（毫秒），如果在 timeout 时间内发送失败或没接收到预期的数据量，send 或 recv 函数就会提前结束
    usb = USB_FT60X_sync245mode(timeout=4000)

    data = usb.recv(32)
    
    print("recv %d B" % len(data))
    print(data)

    usb.close()
    