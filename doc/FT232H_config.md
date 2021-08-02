配置 FT232H 为 sync-245-fifo 模式
====================================


### 步骤1：安装 FT_Prog

进入 [FT_Prog下载页面](https://www.ftdichip.com/Support/Utilities.htm#FT_PROG) 下载并安装 。

### 步骤2：使用 FT_Prog 配置 FT232H

这一步的目的是将 **FT232H** 配置为 **sync-245-fifo** 模式。注：每颗 FT232H 芯片只需要配置一次即可，因为 FT232H 外围都会有个 EEPROM 用来永久保存配置。之后每次使用都不需要再配置（除非你又切换到其它模式用过）。

打开 **FT_Prog** ，进行以下步骤：

* 点击 **Scan and Parse**，图标为**小放大镜** ，扫描出插在该电脑的所有 FTDI 芯片。根据具体信息找到 FT232H 对应的芯片。
* 在 FT232H 下方的属性树中逐级展开，找到并点击 Hardware。
* 在右侧选择 245 FIFO 模式
* 点击上方工具栏中的 **Program** ，图标为 **小闪电** 
* 弹出确认窗口，点击 Program。烧录该配置到 FT232H。
* 烧录后，重新拔插 FT232H-USB 接口，这一步是为了确保配置生效。

> **警告**：在使用 **FT_Prog软件** 的时候，建议拔下计算机上所有的 FPGA 下载器。因为很多 FPGA 下载器，例如 Xilinx Digilent 下载器是 FT232H 芯片实现的，如果万一覆盖了下载器内部的程序，你的**下载器就废了**。

![FT_Prog配置FT232H步骤图](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/doc/ft232hconfig.png)
