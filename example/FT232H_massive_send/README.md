FT232H massive send 示例
===============================

## 简介

该示例基于 **FT232H**，FPGA 不断的发送递增的数据，同时接收数据显示在LED上，Host-PC 可以不断的接收数据进行正确性检验、带宽测试。或者发送数据，观察 LED 的变化

>  [FT2232H](https://ftdichip.com/Products/ICs/FT2232H.htm) 与 [FT232H](https://ftdichip.com/Products/ICs/FT232H.htm) 高度相似，也可以运行该示例， FT2232H 的 **channel A** 可配置成与 FT232H 完全相同的 **245-sync-fifo 接口** 。


## 建立工程

如果你用 **Altera FPGA** ，则可以直接修改 [FPGA目录](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/example/FT232H_massive_send/FPGA) 中的笔者运行成功的 Quartus 工程。在工程中修改 FPGA 型号和引脚约束以适配你的 FPGA 板卡。

如果你用的不是 **Altera FPGA** ，请使用 **以下3个源文件** 建立工程：

* [ft232h_top.sv](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/example/FT232H_massive_send/FPGA/ft232h_top.sv) : 作为工程的顶层
* [ftdi_245fifo.sv](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/RTL/ftdi_245fifo.sv)
* [fifos.sv](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/RTL/fifos.sv)

## 分配引脚

请确保 FTDI 芯片的引脚被正确分配到 FPGA：

* 请参考开发板供应商提供的引脚约束文件或原理图。
* **FT232H/FT2232H** 芯片有多种工作模式。工作在 **sync-245-fifo 模式** 时，引脚命名参加 [FT232H DataSheet](https://www.ftdichip.com/Support/Documents/DataSheets/ICs/DS_FT232H.pdf) 第9页 、[FT2322H DataSheet](https://www.ftdichip.com/Support/Documents/DataSheets/ICs/DS_FT2232H.pdf) 第9页、
* **sync-245-fifo 模式** 下， **SIWU** 和 **PWRSAV** 这两个引脚在示例程序中未出现，这是因为笔者的开发板上这两个引脚被上拉到高电平，不需要FPGA去驱动。如果在你的开发板上这两个引脚连接到了 FPGA 且没有上拉电阻，请在 Verilog 中将它们置 1。
* 模块的 **usb_be** 是独热码，仅在 FT600 和 FT601 中有效，请忽略。
* **USB_CLK** 频率为 **60MHz** 。 在综合之前，你可以为 **USB_CLK** 添加 60MHz 的时钟频率约束。当然，即使不加该约束，也很可能不影响结果的正确运行。

另外，模块另有时钟 CLK 引脚和 LED 引脚需要分配：

* CLK 是必须的，频率不限， 若干 MHz 即可。 笔者测试时使用了 50MHz
* LED 不是必须的，如果不使用，可以从源文件中删除。

我们注意到，模块的 **FTDI_DSIZE 参数** 被设为 1，因为 FT232H 的数据线是 1Byte (8bit) 的

## 综合、下载到FPGA

略

## 准备 FTD2XX Python 运行环境

见 [《 准备 Python 运行环境 (FT232H) 》](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/doc/Python_FTD2XX_guide.md)

## 运行 Python 测试程序

该示例配套的 Python 程序在 [./Python 目录](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/example/FT232H_massive_send/Python) 中，列表说明如下：

| 文件名           | 功能    |
| :--------:       | -----    |
| [**usb_tx.py**](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/example/FT232H_massive_send/Python/usb_tx.py) | Host-PC 发送少量字节给 FT232H，FPGA的 LED灯会相应的变化    |
| [**usb_rx_check.py**](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/example/FT232H_massive_send/Python/usb_rx_check.py)   | 持续读取 FPGA 发来的数据，因为 FPGA 发送的数据是递增的，该程序对递增性进行判断，从而验证接收到的数据是否正确 |
| [**usb_rx_rate.py**](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/example/FT232H_massive_send/Python/usb_rx_rate.py)  | 持续读取 FPGA 发来的数据，测量 持续传输的带宽 |


