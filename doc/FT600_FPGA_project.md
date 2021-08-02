FT600 loopback 示例
===============================

## 简介

我提供一个基于 [FT600](https://ftdichip.com/Products/ICs/FT600.htm) 的FPGA示例工程。其中 FPGA 不断地以 64bit 的宽度发送递增数据，同时不断以 8bit 的宽度接收数据并检验它是否是递增的。

## 建立工程

如果你用 **Altera FPGA** ，则可以直接打开 [FT600_example/FPGA文件夹](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/FT600_example/FPGA) 中的 Quartus 工程。在工程中修改 FPGA 型号以适配你的 FPGA 板卡。

如果你用的不是 **Altera FPGA**，请使用以下源文件建立工程：

* [FT600_example/FPGA/top.sv](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/FT600_example/FPGA/top.sv) : 作为工程的顶层
* [RTL文件夹](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/RTL) 里的所有 .sv 文件，它们会被 top.sv 调用。

## 分配引脚

请确保 FT600 芯片的引脚被正确分配到 FPGA：

* **FT600** 芯片的引脚命名参加 [FT600 DataSheet](https://www.ftdichip.com/Support/Documents/DataSheets/ICs/DS_FT600Q-FT601Q%20IC%20Datasheet.pdf) 第 7~10 页的表格。请将这些引脚分配到 Verilog 中的同名信号上。
* 分配引脚时，你可以参考开发板供应商提供的引脚约束文件或原理图。
* FT600 的 **SIWU** 引脚在示例程序中未出现，这是因为我开发板上该引脚被上拉到高电平，不需要FPGA去驱动。如果在你的开发板上这两个引脚连接到了 FPGA 且没有上拉电阻，请在 Verilog 中将它们 assign 为 1。
* FT600 的 **WAKE_UP** 引脚在示例程序中未出现，这是因为我的开发板上该引脚被下拉到GND，不需要FPGA去驱动。如果在你的开发板上这个引脚连接到了 FPGA 且没有下拉电阻，请在 Verilog 中将它 assign 为 0。
* 模块的 **usb_be** 是独热码，要连，不要忽略了。
* **usb_clk** 频率为 **100MHz** 。 在综合之前，你可以为 **usb_clk** 添加 100MHz 的时钟频率约束，来指导时序分析。当然，即使不加该约束，也很可能不影响结果的正确运行。

另外，Verilog 顶层另有时钟 clk 引脚和 led 引脚需要分配：

* clk 是必须的，连在 FPGA 板的晶振上，频率不限， 若干 MHz 即可。 我测试时是 50MHz
* led 引脚连一个 led，不是必须连的，它平常是1，当发现接收到的数据不是递增的时，会变成 0 一秒。

我们注意到，模块的 C_DEXP 参数被设为 1，因为 FT232H 的数据线是 16bit 的；TX_DEXP 参数被设为 3，因此用户发送接口的宽度是 64bit 的；RX_DEXP 参数被设为 0，因此用户接收接口的宽度是 8bit 的。

## 综合、下载到FPGA

略
