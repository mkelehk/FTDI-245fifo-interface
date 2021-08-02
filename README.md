![test](https://img.shields.io/badge/test-passing-green.svg)
![docs](https://img.shields.io/badge/docs-passing-green.svg)

FTDI 245fifo controller
===========================
[FT232H](https://ftdichip.com/Products/ICs/FT232H.htm)、[FT2232H](https://ftdichip.com/Products/ICs/FT2232H.htm)、[FT600](https://ftdichip.com/Products/ICs/FT600.htm) 等芯片的 **sync-245-fifo 模式** 控制器，实现 FPGA 与 Host-PC 的高速通信

> 本库于 2021.8 重大更新，包括：
>
> * 将收发的切换策略更改为更高效的优先级轮换式调度；
> * 消除了输出毛刺、实现了零边界数据丢失；
> * 简化了代码，降低了嵌套层次。

# 简介

**sync-245-fifo** 是 **FTDI 公司 USB 系列芯片**的最高速传输模式。该库将 **245fifo 控制器** 封装成 **Verilog模块** ，留出**精简流式收发接口** ，方便 Verilog 开发者调用。

另外，本库提供配套的 FPGA 示例工程、驱动安装教程、Python 软件库安装教程，并提供几个 Python 程序用于测试。

下图是该模块的结构框图。

![模块结构](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/doc/structure.png)

## 特点

* **精简接口**：发送接口类似 **AXI-stream slave** ， 接收接口类似 **AXI-stream master**
* **收发调度**：FTDI 芯片与 FPGA 之间的接口是半双工的，该模块调度收发分时复用，实现 **收发接口互相独立** 。
* **跨时钟域**：FTDI 芯片有自己的时钟。该模块用异步 FIFO 实现时钟域转换，使得收发接口可使用 **自定义时钟** 。
* **位宽变换**：FTDI 芯片数据位宽是固定的，但本模块实现了位宽变换。收发接口的 **位宽可自定义** 。
* **移植性**：纯 **SystemVerilog** 编写，易于移植和仿真。

## 性能测试结果

以下是用本库测出来的 USB 上行（FPGA发，Host-PC收）的带宽。

| 芯片型号    | FT232H / FT2232H\*  |  FT600     | FT601      |
| :--------: | :------------:     |   :------:    | :--------: |
| **USB模式** | USB2.0 HS          |  USB3.0 SS     | USB3.0 SS  |
| **理论带宽** | <60MBps             |  <200MBps      | <400MBps  |
| **实测带宽** | 42MBps           |  120MBps       | 可用，未测 |

> \* [FT232H](https://ftdichip.com/Products/ICs/FT232H.htm) 与 [FT2232H](https://ftdichip.com/Products/ICs/FT2232H.htm) 高度相似， FT2232H 的 **channel A** 可配置成与 FT232H 完全相同的 **sync-245-fifo 接口** 。因此本库的FT232H示例也适用于FT2232H


# QuickStart

强烈建议首先阅读[模块使用说明](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/doc/Verilog_module_usage.md)。了解该模块如何部署于 FPGA 中，来开发你自己的 USB 通信业务。

然后你可以运行我提供的使用案例，对于 FT232H，进行步骤：

* 步骤1：在 Host-PC 上[安装 FTD2XX 驱动和 Python FTD2XX 库](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/doc/Python_FTD2XX_guide.md)
* 步骤2：针对每颗 FT232H，需要在初次使用时 [配置为 sync-245-fifo 模式](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/doc/FT232H_config.md)
* 步骤3：部署 [FT232H FPGA 示例工程](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/doc/FT232H_FPGA_project.md) 
* 步骤4：在 Host-PC 上运行 [FT232H Python 示例程序](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/doc/FT232H_run_python.md)

对于 FT600，进行步骤：

* 步骤1：在 Host-PC 上[安装 FTD3XX 驱动和 Python FTD3XX 库](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/doc/Python_FTD3XX_guide.md)
* 步骤2：部署 [FT600 FPGA 示例工程](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/doc/FT600_FPGA_project.md) 
* 步骤3：在 Host-PC 上运行 [FT232H Python 示例程序](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/doc/FT600_run_python.md)

如果你好奇于本模块的设计细节，或者想了解 FTDI USB 芯片的操作时序，可以运行 RTL 仿真，见：[仿真指导](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/testbench)

# 参考资料

* FT232H 芯片资料：http://www.ftdichip.cn/Products/ICs/FT232H.htm
* FT232H 软件示例：http://www.ftdichip.cn/Support/SoftwareExamples/CodeExamples.htm
* FT600 芯片资料：http://www.ftdichip.cn/Products/ICs/FT600.html
* FT600/FT601 软件示例： http://www.ftdichip.cn/Support/SoftwareExamples/FT60X.htm
