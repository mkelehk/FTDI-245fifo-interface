准备 FTD2XX Python 运行环境
====================================

要运行 FT232H 相关的 Python 程序，请进行以下步骤： 

### 步骤1：准备 D2XX 驱动 和 DLL

进入 [D2XX Driver 官网页面](https://www.ftdichip.com/Drivers/D2XX.htm) ，在 D2XX Drivers 那一栏的表格里，下载exe形式的驱动并安装。如下图。

[FT232h驱动下载](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/doc/ft232h_driver_download.png)

同时，下载 DLL 压缩包（如上图）， 解压后在里面找到符合你计算机的 FTD2XX.DLL 文件（若为32-bit计算机，请找到32-bit(i386) DLL；若为64-bit计算机，请找到64-bit(amd64) DLL）。如果文件名是 FTD2XX64.DLL 等, 请一律重命名为 FTD2XX.DLL

### 步骤2：找到 FT232H 设备

将开发板的 FT232H USB 口插入电脑，如果成功安装了驱动，则 **Windows设备管理器** 里应该识别出 **USB Serial Converter** 。

[FT232H被识别](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/doc/ft232h_ready.png)

### 步骤3：安装 Python3

笔者使用的是 **Python 3.5.2|Anaconda 4.2.0 (64-bit)** ，如果你没有安装 Python3， 请前往 [Anaconda官网](https://www.anaconda.com/distribution/) 下载安装任意一个 Python3 的版本。

注意：如果你的计算机是 32-bit，请安装 32-bit 的 Python3，如果你的计算机是 64-bit，请安装 64-bit 的 Python3。

### 步骤4：安装 python ftd2xx库

在命令行运行 **pip install ftd2xx**

### 步骤5：复制 FTD2XX.DLL 文件

复制 **步骤1** 中我们找到的 **FTD2XX.DLL 文件** 到 Python 根目录。例如在笔者的电脑上， Python 根目录是 **C:\Anaconda3\**


### 步骤6：安装 FT_Prog

进入 [FT_Prog下载页面](https://www.ftdichip.com/Support/Utilities.htm#FT_PROG) 下载并安装 。该软件用于配置 FT232H 的工作模式。

### 步骤7：使用 FT_Prog 配置 FT232H

这一步的目的是将 **FT232H** 配置为 **sync-245-fifo** 模式。打开 **FT_Prog** ，进行以下步骤：

* 点击 **Scan and Parse**，图标为**小放大镜** ，扫描出插在该电脑的所有 FTDI 芯片。根据具体信息找到 FT232H 对应的芯片。
* 在 FT232H 下方的属性树中逐级展开，找到并点击 Hardware。
* 在右侧选择 245 FIFO 模式
* 点击上方工具栏中的 **Program** ，图标为 **小闪电** 
* 弹出确认窗口，点击 Program。烧录该配置到 FT232H。
* 烧录后，重新拔插 FT232H-USB 接口，这一步是为了确保配置生效。

> **警告**：在使用 **FT_Prog软件** 的时候，建议拔下计算机上所有的 FPGA 下载器。因为很多 FPGA 下载器，例如 Xilinx Digilent 下载器是 FT232H 芯片实现的，如果万一覆盖了下载器内部的程序，你的**下载器就废了**。

![FT_Prog配置FT232H步骤图](https://github.com/WangXuan95/FTDI-245fifo-interface/blob/master/doc/ft232hconfig.png)


至此，FT232H 所需的 Python 运行环境已就绪。
