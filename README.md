FTDI-245fifo-interface
===========================
基于FPGA的 FT232H、FT600 等 USB 芯片的高速通信 IP 核

# 简介

245fifo 模式是 FTDI USB 芯片常见的一种高速字节流传输模式。该库将 245fifo 封装成接口IP核，留出精简易用的接口，方便Verilog开发者使用。并提供了几个测试用的python程序。

![Image text](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/doc/structure.png)

如上图，该IP核解决了以下关键性问题：

* **读写分离**：工作在 245fifo 模式下的 USB 芯片的接口是半双工的，使用8bit或16bit inout 信号分时复用的完成读写，本IP核将读写接口分离出来，内部使用状态机控制分时复用的读写。
* **跨时钟域**：工作在 245fifo 模式下的 USB 芯片有自己的时钟，不同于FPGA的时钟。该IP核使用异步 fifo 解决了跨时钟域问题。如下图，IP核跨3个时钟域：读时钟域，写时钟域、USB时钟域。当然，读写时钟域可以使用同一时钟。
* **位宽变换**：由于USB芯片引脚数量固定，所以每次能够读写的位宽也是固定的。但开发者可能希望一个时钟周期发送自定义位宽的数据。该IP核分离出的读接口和写接口的位宽是可自定义的。
* **移植性**：纯 SystemVerilog 编写，不调用任何 IP 核，方便在Altera、Xilinx等各种平台上一直

### 测试结果

* **FT232H USB2.0**: 上行链路稳定工作在 **40MBps** 不丢失字节。(上行链路是指 FPGA->USB->PC机器)
* **FT600  USB3.0**: 上行链路稳定工作在 **110MBps** 不丢失字节。(待改进，希望能达到之前裸测的170MBps)
* 上行传输的同时支持少量的下行数据。还没有测试饱和的下行带宽。

# 应用场景

* 采集卡
* 示波器、信号发生器
* 图象传感器读出
* 加速计算棒

# 接口与时序

下图是 IP 核的接口图，IP核顶层是 ./RTL/src/ftdi_245fifo.sv ，它还调用了 ./RTL/src/fifo/ 目录下的 4 个 .sv文件，除此之外没有其它依赖。

![Image text](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/doc/ports.png)

右侧是 FT232H/FT600 等芯片的接口，直接将引脚对应名称相连即可。 注意，在有些芯片手册上，例如 FT232H 手册(见./doc/FT232H.pdf第7页)，并不会直接告诉你芯片引脚与本IP核的对应关系，因为FTDI芯片有很多配置模式，只有在 245 sync fifo 模式下才能使用该 IP核，具体的引脚对应请见 ./doc/FT232H.pdf 第8页的表格。

值得注意的是，有两个引脚在该IP核中未出现：**SIWU** 和 **PWRSAV**。如果这两个引脚连接到了FPGA，请将他们置1。另外，**usb_be** 信号是 **usb_data**  **byteenable** (独热码)，**usb_be** 只在 FT600 和 FT601 中出现，使用其它芯片时请忽略。

上图左侧的读接口和写接口的时序如下图：

![Image text](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/doc/timing.png)

如图，所有写信号应该在 **wr_clk** 的上升沿被捕获或更新。**wr_req** (写请求)与 **wr_gnt** (写允许)是一对握手信号，**wr_req** 置1时，如果 **wr_gnt** 变1，则这周期的 **wr_data **会成功的写入USB，如果 **wr_gnt** 是0，说明 USB 还没准备好接受当前的数据。

读时序与写时序非常相似。所有读信号应该在 **rd_clk** 的上升沿被捕获或更新。**rd_req** (读请求)与 **rd_gnt** (读允许)是一对握手信号，**rd_req** 置1时，如果 **rd_gnt** 变1，则这周期 **rd_data** 上会出现读出的数据，如果 **rd_gnt** 是0，说明当前无数据可读，往往是因为 PC 还没有发送数据给 FPGA。

# 模块参数

IP核有几个 parameter，如下表

| parameter        | 默认值    |  含义  |  FT232H 推荐值 |  FT600 推荐值  | FT601推荐值 |
| --------         | -----:    | :----: | :----: | :----: | :----: |
| USER_WRITE_DSIZE | \$1600    | 写接口的数据位宽(wr_data的位宽)，用户自由调整，必须是 8 的 2^n 倍数 | 8,16,32,64等 | 8,16,32,64等 | 8,16,32,64等 |
| USER_READ_DSIZE  |   \$12    | 读接口的数据位宽(rd_data的位宽)，用户自由调整，必须是 8 的 2^n 倍数 | 8,16,32,64等 | 8,16,32,64等 | 8,16,32,64等 |
| FTDI_DSIZE       | 8         | USB 芯片的数据线位宽，取决于芯片型号  | 8 | 16 | 32 |
| WRITE_FIFO_ASIZE | 10        | IP核内发送缓存的大小 = 2^WRITE_FIFO_ASIZE | \>9 | \>12 | \>13 |
| READ_FIFO_ASIZE  | 9         | IP核内接收缓存的大小 = 2^READ_FIFO_ASIZE  | \>7  | \>8  | \>9  |
| TX_MIN_BITS      | 4096      | 当TX FIFO中积攒多少个bit后才启动发送，防止 USB 帧碎片化，提高峰值带宽 | 2048 | 4096 | 8192 |

# QuickStart (FPGA)

./RTL/example_top/ 目录中提供了两个示例顶层，展示了如何在使用 FT232H 和 FT600 时最简单的调用IP核，实现收发。请按照以下步骤建立 FPGA 工程：

* **准备硬件**: 需要一个带有 FT232H 或 FT600 芯片的 FPGA 开发板。
* **建立工程**: 用开发板对应的开发软件建立工程，选择芯片型号。
* **添加源文件**: 将该库的 ./RTL/ 目录复制到工程目录下，将里面的所有 .sv 文件添加进工程。
* **选择顶层**: 如果是 FT232H，选择 ft232h_top.sv 作为工程的顶层。如果是 FT600，选择 ft600_top.sv 作为工程的顶层。
* **分配引脚**: 根据顶层中的信号名，为FPGA分配引脚。
* **综合、上传开发板**

# QuickStart (FT232H上位机程序）

本库提供几个简单的上位机 Python 测试程序，FT232H 相关的程序都在 **./Python/usb2.0/** 目录里。要运行这些程序，需要：

* **安装 D2XX 驱动**：在 FTDI 官网上下载 D2XX Driver：https://www.ftdichip.com/Drivers/D2XX.htm，在 D2XX Drivers 那一栏的表格里。请根据你的电脑平台选择驱动下载并安装。
* **安装 FT_Prog **：https://www.ftdichip.com/Support/Utilities.htm#FT_PROG 。用于配置 FT232H 的工作模式。
* **配置 FT232H**：将开发板的 FT232H USB 口插入电脑，如果成功安装了驱动则“设备管理器”里应该识别出“USB <-> Serial Converter"。打开 FT_Prog，按照下图的步骤设置：
1) 点击 **Scan and Parse**，图标为**小放大镜** ，扫码出插在该电脑的所有 FTDI 芯片。根据具体信息找到 FT232H 对应的芯片。（**警告**：很多 FPGA 下载器，例如 Xilinx Digilent 下载器也会识别成 FT232H 芯片，请不要看错了，如果万一覆盖了下载器内部的程序，你的**下载器就废了**) 
2) 在 FT232H 下方的属性树中逐级展开，找到并点击 Hardware。
3) 在右侧选择 245 FIFO 模式
4) 点击上方工具栏中的 **Program** ，图标为 **小闪电** 
5) 弹出确认窗口，点击 Program。烧录该配置到 FT232H。
![Image text](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/doc/ft232hconfig.png)
* **安装 python3 和 numpy**：笔者使用的是 **Python 3.5.2 |Anaconda 4.2.0 (64-bit)**
* **安装 python ftd2xx库**: 在命令行运行 **pip install ftd2xx**
* **准备硬件**: 见上一节，确保 FPGA 程序已经烧录
* **运行本库提供的程序**: 在本库的 **./Python/usb2.0/** 中运行程序，它们的功能如下表：
| 文件名           | 功能    |
| --------         | -----    |
| usb_tx.py        | 发送一个字符串给 FT232H，FPGA的 LED灯会相应的变化    |
| usb_rx_rate.py   | 持续读取 USB 数据，计算持续的带宽  |
| usb_rx_check.py  | 同上，但多了一个字节流检查功能。因为本库提供的 FPGA 程序持续的发送递增的 16bit 数，该程序接收到数后，检查它是否递增 |

# QuickStart (FT600上位机程序）

本库提供几个简单的上位机 Python 测试程序，FT600 相关的程序都在 **./Python/usb3.0/** 目录里。要运行这些程序，需要：

* **安装 D3XX 驱动**：在 FTDI 官网上下载 D3XX Driver：https://www.ftdichip.com/Drivers/D3XX.htm，在 D3XX Drivers 那一栏的表格里。请根据你的电脑平台选择驱动下载并安装。
* **安装 python3 和 numpy**: 笔者还没研究出怎么用 64 位 python 跑 FT600，因此特地安装了 32位 python: **Python 3.7.2 (tags/v3.7.2:9a3ffc0492, Dec 23 2018, 22:20:52) [MSC v.1916 32 bit (Intel)] on win32**
* **安装 python ftd2xx库**: 似乎没有办法直接用 pip install。而是在这里下载： http://www.ftdichip.cn/Support/SoftwareExamples/FT60X.htm。 最下方有 python 的支持。下载后解压，找到 setup.py ， 使用命令 **python setup.py install** 安装。（注意：要确保该命令中的 python 是上一步装好的 32 位的 python）
* 在本库的 **./Python/usb3.0/** 中运行程序，它们的功能如下表：
| 文件名           | 功能    |
| --------         | -----    |
| get_usb_info.py  | 查看 FT600 芯片的状态    |
| usb_tx.py   | 运行后，会让你输入二进制串，该串通过USB发送给FPGA后用于设定LED值，例如，你发送了1001，则LED灯变为 亮灭灭亮  |
| usb_rx.py  | 持续读取 USB 数据，计算持续的带宽，并进行字节流检查。因为本库提供的 FPGA 程序持续的发送递增的 16bit 数，所以该程序接收到数后，检查它是否递增 |
另外：如果你的 USB3.0 线没插好，或者插在了 USB2.0 口上，则程序会给你报一个 Warning，还挺人性化的。这时 FT600 也能传输数据，只不过峰值带宽受限制。

# 拓展资料

FT600 芯片资料：http://www.ftdichip.cn/Products/ICs/FT600.html
FT600/FT601 软件示例： http://www.ftdichip.cn/Support/SoftwareExamples/FT60X.htm
FT232H 芯片资料：http://www.ftdichip.cn/Products/ICs/FT232H.htm
FT232H 软件示例：http://www.ftdichip.cn/Support/SoftwareExamples/CodeExamples.htm

还可能支持的芯片（没有测试）：
FT245BL、FT601