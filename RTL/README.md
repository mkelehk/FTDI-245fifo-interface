FTDI 245fifo interface 核心 RTL 代码
=============================

* **ftdi_245fifo.sv** : 模块顶层，其接口说明见 [README](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/README.md)
* **fifos.sv** : 定义了同步 FIFO 和异步 FIFO， 该文件被 **ftdi_245fifo.sv** 调用
