RTL 仿真指导
=============================

[**tb_ftdi_245fifo.sv**](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/testbench/tb_ftdi_245fifo.sv) 是仿真的顶层，该仿真将 **用户发送接口** 与 **用户接收接口** 连接，形成回环。因此，运行仿真时，能看到 usb_rxf, usb_oe, usb_wr上不断的收到数据，然后 usb_txe, usb_wr 上又不断发出相同的数据（可能延迟一轮，但一定是按顺序且不丢失任何字节）

如果你安装过 **iverilog** 套装，可以直接在CMD中运行 [**run_simulation_iverilog.bat**](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/testbench/run_simulation_iverilog.bat) 来运行仿真和查看波形。

如果你使用其它仿真工具，例如 vivado，请新建仿真工程，然后将 [tb_ftdi_245fifo.sv](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/testbench/tb_ftdi_245fifo.sv) 和 [RTL文件夹](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/RTL) 里的设计文件一同加入仿真工程，然后运行仿真即可。

