FT600 massive send 示例
===============================

## 简介

该示例基于 **FT600**，FPGA 不断的发送递增的数据，同时接收数据显示在LED上，Host-PC 可以不断的接收数据进行正确性检验、带宽测试。或者发送数据，观察 LED 的变化

## 建立工程

如果你用 **Altera FPGA** ，则可以直接修改 [FPGA目录](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/example/FT600_massive_send/FPGA) 中的笔者运行成功的 Quartus 工程。在工程中修改 FPGA 型号和引脚约束以适配你的 FPGA 板卡。

如果你用的不是 **Altera FPGA** ，请使用 **以下3个源文件** 建立工程：

* [ft600_top.sv](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/example/FT600_massive_send/FPGA/ft600_top.sv) : 作为工程的顶层
* [ftdi_245fifo.sv](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/RTL/ftdi_245fifo.sv)
* [fifos.sv](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/RTL/fifos.sv)

## 分配引脚

请确保 FTDI 芯片的引脚被正确分配到 FPGA：

* 请参考开发板供应商提供的引脚约束文件或原理图。
* **FT600** 芯片的引脚命名参加 [FT600 DataSheet](https://www.ftdichip.com/Support/Documents/DataSheets/ICs/DS_FT600Q-FT601Q%20IC%20Datasheet.pdf) 第7页的表格。
* **SIWU_N** 引脚在示例程序中未出现，这是因为笔者的开发板上该引脚被上拉到高电平，不需要FPGA去驱动。如果在你的开发板上这个引脚连接到了 FPGA 且没有上拉电阻，请在 Verilog 中将它置 1。
* **WAKE_UP** 引脚在示例程序中未出现，这是因为笔者的开发板上该引脚被下拉到GND，不需要FPGA去驱动。如果在你的开发板上这个引脚连接到了 FPGA 且没有下拉电阻，请在 Verilog 中将它置 0。
* 模块的 **usb_be** 是独热码，在 FT600 中有效，不要忽略了。
* **USB_CLK** 频率为 **100MHz** 。 在综合之前，你可以为 **USB_CLK** 添加 100MHz 的时钟频率约束。当然，即使不加该约束，也很可能不影响结果的正确运行。

另外，模块另有时钟 CLK 引脚和 LED 引脚需要分配：

* CLK 是必须的，频率不限， 若干 MHz 即可。笔者测试时使用了 50MHz
* LED 不是必须的，如果不使用，可以从源文件中删除。

我们注意到，模块的 **FTDI_DSIZE 参数** 被设为 2，因为 FT600 的数据线是 2Byte (16bit) 的

## 综合、下载到FPGA

略

## 准备 FTD3XX Python 运行环境

见 [《 准备 Python 运行环境 (FT600) 》](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/doc/Python_FTD3XX_guide.md)

## 运行 Python 测试程序

该示例配套的 Python 程序在 [./Python 目录](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/example/FT600_massive_send/Python) 中，列表说明如下：

| 文件名           | 功能    |
| :--------:       | -----    |
| [**usb_tx.py**](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/example/FT600_massive_send/Python/usb_tx.py) | Host-PC 发送少量字节给 FT600，FPGA的 LED灯会相应的变化    |
| [**usb_rx_check.py**](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/example/FT600_massive_send/Python/usb_rx_check.py)   | 持续读取 FPGA 发来的数据，因为 FPGA 发送的数据是递增的，该程序对递增性进行判断，从而验证接收到的数据是否正确 |
| [**usb_rx_rate.py**](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/example/FT600_massive_send/Python/usb_rx_rate.py)  | 持续读取 FPGA 发来的数据，测量 持续传输的带宽 |

另外：如果你使用了 USB2.0 线缆，或者插在了 USB2.0 口上，Python 程序会报一个 Warning。这时 FT600 也能传输数据，只不过带宽受限制。

