#-*- coding:utf-8 -*-
# Python3

from USB_FT232H import USB_FT232H_sync245mode
   
if __name__ == '__main__':
    
    # 一定要确保你的 FT232H 和这里的 'USB <-> Serial Converter' 匹配！如果不匹配，可用 FT_Prog 软件来查看 FT232H 的设备名，或者修改这里的字符串，使之匹配
    # timeout 是超时值（毫秒），如果在 timeout 时间内发送失败或没接收到预期的数据量，send 或 recv 函数就会提前结束
    usb = USB_FT232H_sync245mode(name_bytes=b'USB <-> Serial Converter', timeout=4000)
    
    data = usb.recv(32)
    
    print("recv %d B" % len(data))
    print(data)

    usb.close()
    