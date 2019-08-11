准备 FTD2XX Python 运行环境
====================================

要运行 FT232H 相关的 Python 程序，请进行以下步骤： 

### 安装 D2XX 驱动

进入 [D2XX Driver 官网页面](https://www.ftdichip.com/Drivers/D2XX.htm) ，在 D2XX Drivers 那一栏的表格里，根据你的计算机平台选择驱动下载并安装。

### 找到 FT232H 设备

将开发板的 FT232H USB 口插入电脑，如果成功安装了驱动，则 **Windows设备管理器** 里应该识别出 **USB <-> Serial Converter** 。


### 安装 FT_Prog

进入 [FT_Prog下载页面](https://www.ftdichip.com/Support/Utilities.htm#FT_PROG) 下载并安装 。该软件用于配置 FT232H 的工作模式。

### 使用 FT_Prog 配置 FT232H

> **警告**：在使用 **FT_Prog软件** 的时候，建议拔下计算机上所有的 FPGA 下载器。因为很多 FPGA 下载器，例如 Xilinx Digilent 下载器是 FT232H 芯片实现的，如果万一覆盖了下载器内部的程序，你的**下载器就废了**。

这一步的目的是将 **FT232H** 配置为 **sync-245-fifo** 模式。打开 **FT_Prog** ，进行以下步骤：

* 点击 **Scan and Parse**，图标为**小放大镜** ，扫描出插在该电脑的所有 FTDI 芯片。根据具体信息找到 FT232H 对应的芯片。
* 在 FT232H 下方的属性树中逐级展开，找到并点击 Hardware。
* 在右侧选择 245 FIFO 模式
* 点击上方工具栏中的 **Program** ，图标为 **小闪电** 
* 弹出确认窗口，点击 Program。烧录该配置到 FT232H。

![FT_Prog配置FT232H步骤图](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/doc/ft232hconfig.png)

### 安装 Python3

笔者使用的是 **Python 3.5.2|Anaconda 4.2.0 (64-bit)** ，如果你没有安装 Python， 请前往 [Anaconda官网](https://www.anaconda.com/distribution/) 下载安装任意一个 Python3 的版本，具体步骤略。

### 安装 python ftd2xx库

在命令行运行 **pip install ftd2xx** ，

至此，FT232H 所需的 Python 运行环境已就绪。
