FT232H FPGA 示例工程
===============================

## 简介

我提供一个基于 [FT232H](https://ftdichip.com/Products/ICs/FT232H.htm) 或 [FT2232H](https://ftdichip.com/Products/ICs/FT2232H.htm) 的FPGA示例工程。其中 FPGA 不断地以 64bit 的宽度发送递增数据，同时不断以 8bit 的宽度接收数据并检验它是否是递增的。

>  FT2232H 与 FT232H 高度相似，FT2232H 的 **channel A** 可配置成与 FT232H 完全相同的 **sync-245-fifo 模式**，因此也可以运行该示例。


## 建立工程

如果你用 **Altera FPGA** ，则可以直接打开 [FT232H_example/FPGA文件夹](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/FT232H_example/FPGA) 中的 Quartus 工程。在工程中修改 FPGA 型号以适配你的 FPGA 板卡。

如果你用的不是 **Altera FPGA**，请使用以下源文件建立工程：

* [FT232H_example/FPGA/top.sv](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/FT232H_example/FPGA/top.sv) : 作为工程的顶层
* [RTL文件夹](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/RTL) 里的所有 .sv 文件，它们会被 top.sv 调用。

## 分配引脚

请确保 FTDI 芯片的引脚被正确分配到 FPGA：

* **FT232H/FT2232H** 芯片有多种工作模式。只有工作在 **sync-245-fifo 模式** 时，才能为本工程所用。该模式下的引脚命名见 [FT232H DataSheet](https://www.ftdichip.com/Support/Documents/DataSheets/ICs/DS_FT232H.pdf) 第9页、或 [FT2322H DataSheet](https://www.ftdichip.com/Support/Documents/DataSheets/ICs/DS_FT2232H.pdf) 第9页。请将这些引脚分配到 Verilog 中的同名信号上。
* 分配引脚时，你可以参考开发板供应商提供的引脚约束文件或原理图。
* **sync-245-fifo 模式** 下， FT232H/FT2232H 的 **SIWU** 和 **PWRSAV** 这两个引脚在示例程序中未出现，这是因为我开发板上这两个引脚被上拉到高电平，不需要FPGA去驱动。如果在你的开发板上这两个引脚连接到了 FPGA 且没有上拉电阻，请在 Verilog 中将它们 assign 为 1。
* 模块的 **usb_be** 是字节独热码，FT232H 和 FT2232H 没有这个信号，因此请忽略。
* **usb_clk** 频率为 **60MHz** 。 在综合之前，你可以为 **usb_clk** 添加 60MHz 的时钟频率约束，来指导时序分析。当然，即使不加该约束，也很可能不影响结果的正确运行。

另外，Verilog 顶层另有时钟 clk 引脚和 led 引脚需要分配：

* clk 是必须的，连在 FPGA 板的晶振上，频率不限， 若干 MHz 即可。 我测试时是 50MHz
* led 引脚连一个 led，不是必须连的，它平常是1，当发现接收到的数据不是递增的时，会变成 0 一秒。

我们注意到，模块的 C_DEXP 参数被设为 0，因为 FT232H 的数据线是 8bit 的；TX_DEXP 参数被设为 3，因此用户发送接口的宽度是 64bit 的；RX_DEXP 参数被设为 0，因此用户接收接口的宽度是 8bit 的。

## 综合、下载到FPGA

略
