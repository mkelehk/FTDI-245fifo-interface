![test](https://img.shields.io/badge/test-passing-green.svg)
![docs](https://img.shields.io/badge/docs-passing-green.svg)

FTDI 245fifo interface
===========================
[FT232H](https://ftdichip.com/Products/ICs/FT232H.htm)、[FT2232H](https://ftdichip.com/Products/ICs/FT2232H.htm)、[FT600](https://ftdichip.com/Products/ICs/FT600.htm) 等芯片的 **245-sync-fifo 模式** 控制器，实现FPGA与PC机的高速通信

# 简介

**245-sync-fifo 模式** 是 **FTDI 公司 USB 系列芯片** 的一种高速字节流传输模式。该库将 **245fifo 控制器** 封装成 **Verilog模块** ，留出 **精简接口** ，方便 Verilog 开发者使用。并提供几个 **Python程序** 用于测试。下图是该模块的结构框图。

![模块结构](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/doc/structure.png)

## 特点

* **精简接口**：发送接口类似 **AXI-stream slave** ， 接收接口类似 **AXI-stream master**
* **收发分离**：FTDI 芯片与 FPGA 之间的接口是半双工的，该模块控制收发分时复用，实现 **收发接口互相独立** 。
* **跨时钟域**：FTDI 芯片有自己的时钟。笔者用异步 FIFO 实现时钟域转换，使得收发接口可使用 **自定义时钟** 。
* **位宽变换**：FTDI 芯片数据位宽是固定的，但本模块实现了位宽变换。收发接口的 **位宽可自定义** 。
* **移植性**：纯 **SystemVerilog** 编写，易于移植和仿真

## 性能测试结果

| 芯片型号    | FT232H / FT2232H\*  |  FT600Q     | FT601Q      |
| :--------: | :------------:     |   :------:    | :--------: |
| **USB模式** | USB2.0 HS          |  USB3.0 SS     | USB3.0 SS  |
| **理论带宽** | <60MBps             |  <200MBps      | <400MBps  |
| **实测带宽** | 42MBps             |  130MBps        | 理论可用，笔者未测 |

> \* [FT232H](https://ftdichip.com/Products/ICs/FT232H.htm) 与 [FT2232H](https://ftdichip.com/Products/ICs/FT2232H.htm) 高度相似， FT2232H 的 **channel A** 可配置成与 FT232H 完全相同的 **245-sync-fifo 接口** 。 本库的FT232H示例也适用于FT2232H

* **FT232H 性能测试**: FPGA向Host-PC持续发送数据，稳定工作在 **42MBps** 不丢失字节，同时支持少量的Host-PC向FPGA发送数据。
* **FT600 性能测试**: FPGA向Host-PC持续发送数据，稳定工作在 **130MBps** 不丢失字节，同时支持少量的Host-PC向FPGA发送数据。


# 接口与时序

下图是模块的接口图，模块顶层文件是 [**./RTL/ftdi_245fifo.sv**](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/RTL/ftdi_245fifo.sv) ，它调用了 [**./RTL/fifos.sv**](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/RTL/fifos.sv) ，除此之外无其它依赖。

![模块接口图](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/doc/ports.png)

## FTDI chip Interface

**FTDI chip Interface** 应连接到 FTDI 芯片对应的 FPGA 管脚上。注意以下几点：

* **关于引脚分配**：FTDI USB 芯片工作在 **sync-245-fifo 模式** 时，引脚命名参加芯片 Datasheet，以 FT232H 为例，见 [FT232H DataSheet](https://www.ftdichip.com/Support/Documents/DataSheets/ICs/DS_FT232H.pdf) 第9页。
* 模块的 **usb_be** 是独热码，仅在 FT600 和 FT601 中有效，使用其它芯片时请忽略。
* **FTDI chip Interface** 的时序图见 Datasheet，例如 [FT232H DataSheet](https://www.ftdichip.com/Support/Documents/DataSheets/ICs/DS_FT232H.pdf) 第23页。 该时序由模块维护，不需要用户关注。

## Send Interface （类似 AXI-stream slave)

**Send Interface** 是用户发送接口，该接口用于从 FPGA 发送数据到 Host-PC 。时序类似 **AXI-stream slave** ，如下图左。注意以下几点：

* **iclk 时钟** 由用户指定，时钟频率不限，所有信号应该在 **iclk** 上升沿更新或捕获。
* **itvalid** (发送请求) 为 1 时，说明用户想发送一个数据到 Host-PC。
* **itready** (发送允许) 为 1 时，说明模块已经准备好接受发送数据。itready=0 时，模块FIFO满，不能接受更多数据。
* **itvalid** 与 **itready** 是一对握手信号。二者同时为 1 时， **itdata** 成功写入。
* **Send Interface** 与 **AXI-stream** 相比，没有 **tlast** 信号，因此没有包的概念，是单纯的流。

![发送接口和接收接口的时序图](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/doc/timing.png)

## Recieve Interface （类似 AXI-stream master)

**Recieve Interface** 是用户接收接口，该接口用于接收从 Host-PC 到 FPGA 的数据。时序类似 **AXI-stream master** ，如上图右。注意以下几点：

* **oclk 时钟** 由用户指定，时钟频率不限，所有信号应该在 **oclk** 上升沿更新或捕获。
* **otvalid** (发送请求) 为 1 时，说明模块想发送一个数据给用户。otvalid=0 时，模块FIFO空，不能读出更多数据。
* **otready** (发送允许) 为 1 时，说明用户已经准备好接受数据。
* **otvalid** 与 **otready** 是一对握手信号。二者同时为 1 时， **otdata** 成功读出。
* **Recieve Interface** 与 **AXI-stream** 相比，没有 **tlast** 信号，因此没有包的概念，是单纯的流。

## 模块参数

模块有几个 **parameter** ，用于指定用户想要的参数 ，如下表。

| parameter        | 默认值 |  含义  |  FT232H 推荐值 |  FT600 推荐值  | FT601 推荐值 |
| :--------       | -----: | :---- | :----: | :----: | :----: |
| **INPUT_DSIZE** | 1      | 发送接口的数据宽度(itdata的宽度)，单位为Byte，用户自由调整，必须是 2^n 倍数 | 1,2,4,8 | 1,2,4,8 | 1,2,4,8 |
| **INPUT_ASIZE** | 10     | 模块内发送缓存的深度 = 2^INPUT_ASIZE | \>=8 | \>=9 | \>=10 |
| **OUPUT_DSIZE**  | 1      | 接收接口的数据宽度(otdata的宽度)，单位为Byte，用户自由调整，必须是 2^n 倍数 | 1,2,4,8 | 1,2,4,8 | 1,2,4,8 |
| **OUTPUT_ASIZE**  | 9      | 模块内接收缓存的深度 = 2^OUTPUT_ASIZE  | \>=7  | \>=8  | \>=9  |
| **FTDI_DSIZE**       | 1      | USB 芯片的数据线宽度，单位为Byte，取决于芯片型号  | 1 | 2 | 4 |


# QuickStart

要运行基于 **FT232H** 或 **FT2232H** 的 FPGA 示例，参见：

* [FT232H loopback 示例](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/example/FT232H_loopback)
* [FT232H massive send 示例](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/example/FT232H_massive_send)
* [准备 Python 运行环境 (FT232H)](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/doc/Python_FTD2XX_guide.md)

要运行基于 **FT600** 的 FPGA 示例，参见：

* [FT600 loopback 示例](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/example/FT600_loopback)
* [FT600 massive send 示例](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/example/FT600_massive_send)
* [准备 Python 运行环境 (FT600)](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/doc/Python_FTD3XX_guide.md)

要运行 RTL 仿真，参见：

* [模块仿真指导](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/testbench)

# 拓展资料

* FT232H 芯片资料：http://www.ftdichip.cn/Products/ICs/FT232H.htm
* FT232H 软件示例：http://www.ftdichip.cn/Support/SoftwareExamples/CodeExamples.htm
* FT600 芯片资料：http://www.ftdichip.cn/Products/ICs/FT600.html
* FT600/FT601 软件示例： http://www.ftdichip.cn/Support/SoftwareExamples/FT60X.htm
