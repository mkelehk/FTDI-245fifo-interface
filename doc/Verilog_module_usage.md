# 模块使用方法

本库包含 3 个设计文件，供 FPGA 开发者调用来开发自己的 USB 通信业务，见下表。

| 文件名                                                       | 说明                               |
| ------------------------------------------------------------ | ---------------------------------- |
| [**RTL/ftdi_245fifo.sv**](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/RTL/ftdi_245fifo.sv) | 顶层模块，开发者应该直接调用它。   |
| [**RTL/stream_async_fifo.sv**](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/RTL/stream_async_fifo.sv) | 异步 FIFO，被顶层模块调用。        |
| [**RTL/stream_wtrans.sv**](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/RTL/stream_wtrans.sv) | 数据流位宽变换器，被顶层模块调用。 |

下面讲解顶层模块 **ftdi_245fifo** 的使用方法，它的接口和参数（parameter）如下图：

![模块接口图](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/doc/ports.png)

## 确定 parameter

要调用本模块，首先要根据实际情况确定 parameter，下表展示了 **ftdi_245fifo** 模块的所有 parameter ：

| parameter 名称 | 说明                                                         |
| -------------- | ------------------------------------------------------------ |
| TX_DEXP        | 决定了用户发送接口的数据宽度（即tx_data的宽度）：0对应8bit宽，1对应16bit宽，2对应32bit宽，3对应64bit宽，以此类推。可以根据实际需要任意设置，不受所选的 USB 芯片型号限制。 |
| TX_AEXP        | 决定了用户发送缓存的深度，深度=2^TX_AEXP。默认为10（即默认深度为1024），如果 FPGA BRAM 较大，该项可以设得更大，来提高突发性能。 |
| RX_DEXP        | 决定了用户接收接口的数据宽度（即rx_data的宽度）：0对应8bit宽，1对应16bit宽，2对应32bit宽，3对应64bit宽，以此类推。可以根据实际需要任意设置，不受所选的 USB 芯片型号限制。 |
| RX_AEXP        | 决定了用户接收缓存的深度，深度=2^RX_AEXP。默认为10（即默认深度为1024），如果 FPGA BRAM 较大，该项可以设得更大，来提高突发性能。 |
| C_DEXP         | 决定了USB数据信号（即usb_data）的宽度：0对应8bit宽，1对应16bit宽，2对应32bit宽，3对应64bit宽。应该根据所选的 USB 芯片型号而设置：FT232H设为0，FT600设为1，FT601设为2。 |

## 连接 FTDI USB 芯片

usb_rxf, usb_txe, usb_oe, usb_rd, usb_wr, usb_data, usb_be 这些信号应连接到 FTDI USB 芯片的管脚上。注意以下几点：

* FTDI USB 芯片工作在 **sync-245-fifo 模式** 时，引脚名称参加芯片 Datasheet，以 FT232H 为例，见 [FT232H DataSheet](https://www.ftdichip.com/Support/Documents/DataSheets/ICs/DS_FT232H.pdf) 第9页。
* usb_be 信号是字节独热码，仅 FT600 和 FT601 芯片有这个信号，使用其它芯片时请忽略。
* 这些信号的时序图见 Datasheet，例如 [FT232H DataSheet](https://www.ftdichip.com/Support/Documents/DataSheets/ICs/DS_FT232H.pdf) 第23页。该时序由模块维护，不需要开发者关注。

## 用户发送接口

本模块内置一个发送缓存，开发者需要提供一个 tx_clk 时钟，并在该时钟域下操作 tx_valid, tx_ready, tx_data 这三个信号，来把数据从 FPGA 发送到发送缓存，（Host-PC上启动接收程序时，发送缓存的数据会自动发给PC）。它们的时序类似 **AXI-stream slave** 。注意以下几点：

* tx_clk 的频率不限，tx_valid, tx_ready, tx_data 信号应该在 tx_clk 上升沿更新或捕获。
* tx_valid (请求) 为 1 时，说明用户想发送一个数据到模块内部的发送缓存。同时，tx_data 应产生有效数据。
* tx_ready (允许) 为 1 时，说明模块已经准备好接收发送数据。tx_ready=0 时，模块的发送缓存暂时满，不能接收更多数据。
* tx_valid 与 tx_ready 是一对握手信号。二者同时为 1 时， tx_data 写入缓存成功。
* 与 AXI-stream 相比，这里没有 tlast 信号，因此用户发送接口没有包的概念，是单纯的流。

发送接口如下时序图，它通过用户接口发送了3个数据：D1,D2,D3。其中：

* 第 1, 2 周期，用户令 tx_valid=0 ，因此暂时空闲没发数据。

* 第 3 周期，用户要发 D1，因此令 tx_valid=1，本周期 tx_ready=1 ，说明 D1 即刻发送成功。

* 第 4, 5, 6, 7 周期，用户要发 D2，因此令 tx_valid=1，但第 4, 5, 6 周期 tx_ready=0 导致发送暂时失败，直到第 7 周期 tx_ready=1 时，才发送成功。

* 第 8, 9 周期，用户令 tx_valid=0 ，因此暂时空闲没发数据。

* 第 10 周期，用户要发 D3，因此令 tx_valid=1，本周期 tx_ready=1 ，说明 D3 即刻发送成功。

      cycle       1     2     3     4     5     6     7     8     9     10    11
                _    __    __    __    __    __    __    __    __    __    __    __
       clk       \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \
                            _____________________________             _____
      tx_valid  ___________/                             \___________/     \________
                _________________                   ________________________________
      tx_ready                   \_________________/
                            _____ _______________________             _____
      tx_data   XXXXXXXXXXXX__D1_X___________D2__________XXXXXXXXXXXXX__D3_XXXXXXXXX



## 用户接收接口

本模块内置一个接收缓存，开发者需要提供一个 rx_clk 时钟，并在该时钟域下操作 rx_valid, rx_ready, rx_data 这三个信号，来把来自 Host-PC 的暂存在接收缓存内的数据拿出来。它们的时序类似 **AXI-stream master** ，与用户发送接口时序相同，但方向相反。注意以下几点：

* rx_clk 的频率不限，而且当然可以和 tx_clk 接在同一个时钟上，rx_valid, rx_ready, rx_data 信号应该在 rx_clk 上升沿更新或捕获。
* rx_valid (请求) 为 1 时，说明模块想发送一个数据给用户。同时，rx_data 上出现有效数据。而 rx_valid=0 时，接收缓存空，不能拿出更多数据。
* rx_ready (允许) 为 1 时，说明用户已经准备好拿出一个数据。
* rx_valid 与 rx_ready 是一对握手信号。二者同时为 1 时， rx_data 成功从接收缓存中取出。
* 与 AXI-stream 相比，这里没有 tlast 信号，因此用户接收接口没有包的概念，是单纯的流。

用户接收接口的时序类似用户发送接口（唯一的区别是方向相反），因此不再赘述其时序图。