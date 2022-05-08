#-*- coding:utf-8 -*-
# Python3

import numpy as np

from USB_FT232H import USB_FT232H_sync245mode


total_idx = 9999

if __name__ == '__main__':
    
    # 一定要确保你的 FT232H 和这里的 'USB <-> Serial Converter' 匹配！如果不匹配，可用 FT_Prog 软件来查看 FT232H 的设备名，或者修改这里的字符串，使之匹配
    # timeout 是超时值（毫秒），如果在 timeout 时间内发送失败或没接收到预期的数据量，send 或 recv 函数就会提前结束
    usb = USB_FT232H_sync245mode(name_bytes=b'USB <-> Serial Converter', timeout=4000)
    
    send_start_number = 0
    recv_start_number = -1
    
    for idx in range(total_idx):
        print('[%4d/%4d]' % (idx+1, total_idx), end='  ')
        
        if np.random.randint(0,10) == 0:                                             # 有 10% 的概率进行发送
            send_end_number = send_start_number + 4 * np.random.randint(1,513)
            send_numbers = np.arange(send_start_number, send_end_number) % 256
            print('send 0x%02x~0x%02x' % (send_numbers[0], send_numbers[-1]))
            send_data = send_numbers.astype('<B').tobytes()
            usb.send(send_data)
            send_start_number = send_end_number % 256
            
        else:                                                                        # 有 90% 的概率进行接收
            rxlen = 8 * np.random.randint(1,1025)
            recv_data = usb.recv(rxlen)
            if (len(recv_data) % 8) != 0 and len(recv_data) == 0:
                print('*** recv length not met')
                exit(-1)
            recv_numbers = np.frombuffer(recv_data, dtype=np.uint64)
            if recv_start_number == -1:
                recv_start_number = recv_numbers[0]
            recv_end_number = recv_start_number + len(recv_numbers)
            recv_expect_numbers = np.arange(recv_start_number, recv_end_number) % (1<<64)
            recv_expect_numbers = recv_expect_numbers.astype(np.uint64)
            if (recv_expect_numbers == recv_numbers).all() :
                print('recv %4d B, validation okay' % len(recv_data))
            else:
                print('*** recv data not in order, validation failed')
                exit(-1)
            recv_start_number = recv_end_number % (1<<64)

    usb.close()
    