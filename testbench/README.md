RTL 仿真指导
=============================

[**tb_ftdi_245fifo.sv**](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/testbench/tb_ftdi_245fifo.sv) 是仿真的顶层，该仿真将 **发送接口** 与 **接收接口** 连接，形成回环，运行仿真时，能看到 **sync-245-fifo接口** 上不断的出现接收的数据流被原封不动的发送出去的现象。

如果你使用 **iverilog** ，可以直接在CMD中运行 [**run_simulation_iverilog.bat**](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/testbench/run_simulation_iverilog.bat) 。

如果你使用其它仿真工具，请使用以下3个源文件建立仿真工程进行仿真：

* [tb_ftdi_245fifo.sv](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/testbench/tb_ftdi_245fifo.sv) ： 作为仿真的顶层。
* [ftdi_245fifo.sv](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/RTL/ftdi_245fifo.sv)
* [fifos.sv](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/RTL/fifos.sv)
