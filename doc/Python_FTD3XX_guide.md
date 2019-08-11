准备 FTD3XX Python 运行环境
====================================

要运行 FT600 相关的 Python 程序，请进行以下步骤： 

### 安装 D3XX 驱动

进入 [D3XX Driver 官网页面](https://www.ftdichip.com/Drivers/D3XX.htm) ，在 D3XX Drivers 那一栏的表格里。请根据你的计算机平台选择驱动下载并安装。

### 安装 python3 和 numpy

因为 **FTDI官网** 提供的 **FTD3XX.DLL** 是 **32-bit** 的，所以似乎无法用 **64 位 Python** 运行 FT600。笔者特地安装了 **32位 python 3.7.2** 。 请前往 [Anaconda官网](https://www.anaconda.com/distribution/) 下载安装任意一个 Python3 的 **32-bit** 版本，具体步骤略。

### 安装 Python ftd3xx 库

这一步似乎没有办法用 **pip install** 。而是在 [FTDI官网下载](http://www.ftdichip.cn/Support/SoftwareExamples/FT60X.htm) 。 网页最下方有 Python 的支持。下载后解压，在里面找到 **setup.py** ， 使用CMD命令 **python setup.py install** 安装。 **注意，如果你的计算机安装了多个版本的 Python，要确保该命令中的 python 是上一步装好的 32 位的 python, 请在搜索引擎查询 "Windows 中多个版本的 Python 如何共存" **

### 准备 FTD3XX.DLL 文件

该 DLL 可在 **FTDI官网** 找到 ， 不过本库中有关 FT600 的代码旁边都附有 **FTD3XX.DLL** 文件，不需要另外下载。

至此，FT600 所需的 Python 运行环境已就绪。
