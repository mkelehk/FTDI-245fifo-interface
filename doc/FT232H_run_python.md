# 运行 FT232H Python 示例通信程序

我在 [FT232H_example/Python文件夹](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/FT232H_example/Python) 中编写了以下几个 Python 程序。FPGA 示例程序部署后，可以运行这些程序。

| 文件                    | 功能                                                         |
| ----------------------- | ------------------------------------------------------------ |
| USB_FT232H.py           | 定义了 USB_FT232H_sync245mode 类，实现了 构造函数, close, send, recv 方法，它会被其它文件调用。 |
| usb_rx.py               | 简简单单地试图接收 32 个字节（FPGA 发送，Host-PC 接收）      |
| usb_tx.py               | 简简单单地发送 16 个字节（FPGA 接收，Host-PC 发送）          |
| usb_rx_rate.py          | Host-PC 不断接收大量数据，并统计带宽                         |
| usb_rx_tx_validation.py | 同时进行收发正确性验证，它会不间断地发送和接收。因为配套的 FPGA 程序会发送的是递增数据，所以该程序会验证收到的数据是否连续递增（遇到不连续则警告并退出）。同时该程序也会不断地发递增的数据，FPGA也会验证收到的数据是否连续递增，遇到不连续则把 led 管脚置 0（灯灭）一秒。通常，程序开始运行时灯会灭一秒（因为本次和上次收到的数据大概率不连续），但之后正常情况下不会再灭。 |

