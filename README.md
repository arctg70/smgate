## 树莓派透明翻墙网关设置
simonzhou edited this page on 5 June 2021 · 1 revisions

### 概述

假定主路由器局域网ip设置为192.168.99.1。将设置好的树莓派用网线连接路由器上去即可。 

树莓派配合主路由器使用。

- 正常的不需要翻墙的机器，自动从主路由获取ip和网关信息。

- 需要翻墙的机器，手动设置网关为树莓派的ip。树莓派作为透明翻墙网关，只要是连接到这个网关的设备，自动翻墙，无需再安装设置翻墙软件。

### 准备主路由器

进入到主路由器设置界面，把主路由器的LAN口地址IP设置为192.168.99.1。使用路由器正常联网。

### 准备树莓派

树莓派系统目前为Debian 9，系统镜像为：2021-05-07-raspios-buster-armhf.img ，下载地址：

> https://downloads.raspberrypi.org/raspios_armhf/images/raspios_armhf-2021-05-28/2021-05-07-raspios-buster-armhf.zip

> https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-05-28/2021-05-07-raspios-buster-armhf-lite.zip

下载镜像后，用USB Image Tool或Win32DiskImager、树莓派官方推荐使用Etcher等工具，写入到TF卡中。

如果TF卡以前装过树莓派系统，最好是先用SD Formatter格式化遍，用擦除模式。再写入系统，如果是新卡，可直接写。

TF卡写好系统后，一般会变成两个分区，其中一个名称为boot,在这个分区中建立一个名字为SSH的文件，无后缀，windows系统中可以用写字板新建文件，改名为SSH，注意不带后缀。

TF卡插入树莓派，启动系统，用putty登录进系统。默认用户名：pi 密码：raspberry。 树莓派的IP可以进到路由器中查找。 

### 修改root账户密码：

> sudo passwd root

输入两次密码。

### 开启root登录

> sudo nano /etc/ssh/sshd_config

找到 PermitRootLogin without-password 修改为： PermitRootLogin yes

保存退出，重启ssh服务。

> sudo /etc/init.d/ssh restart

### 设置静态IP

树莓派设置静态 IP（192.168.99.2），与主路由器 LAN 口同一个网段，默认网关为主路由器的IP（192.168.99.1）

备份原来的dhcpcd.conf 同时相当于清空原配置内容。

> sudo mv /etc/dhcpcd.conf /etc/dhcpcd.conf.bak

> sudo nano /etc/dhcpcd.conf 

使用 nano编辑文件，添加下列配置项

    #指定接口 eth0

    interface eth0

    #指定静态IP，/24表示子网掩码为 255.255.255.0

    static ip_address=192.168.99.2/24

    #路由器/网关IP地址

    static routers=192.168.99.1

    #手动自定义DNS服务器

    static domain_name_servers=114.114.114.114

重启树莓派。

> reboot

使用ip:192.168.99.2连接,使用root账户登录系统。

以下命令操作，均在root账户下。

### 更换国内源

> nano /etc/apt/sources.list

注释原来的源,添加下列内容：

    #debian 9 buster 源：

    deb http://mirrors.tuna.tsinghua.edu.cn/raspbian/raspbian/ buster main non-free contrib

    #deb-src http://mirrors.tuna.tsinghua.edu.cn/raspbian/raspbian/ buster main non-free contrib

更换archive.raspberrypi.org源

将 /etc/apt/sources.list.d/raspi.list 文件中默认的源地址 http://archive.raspberrypi.org/ 替换为 http://mirrors.ustc.edu.cn/archive.raspberrypi.org/ 即可。

> sudo nano /etc/apt/sources.list.d/raspi.list

注释原来的源,添加下列内容：

    #debian 9 buster 源

    deb http://mirrors.ustc.edu.cn/archive.raspberrypi.org/debian/ buster main ui

    #deb-src http://mirrors.ustc.edu.cn/archive.raspberrypi.org/debian/ buster main ui

### 安装clash

'''
wget https://github.com/Dreamacro/clash/releases/download/v1.6.0/clash-linux-armv8-v1.6.0.gz
gunzip clash-linux-armv8-v1.6.0.gz
mv clash-linux-armv8 /opt/clash/clash
chmod +x /opt/clash/clash
'''


### 树莓派开启 IP 转发

执行命令：

> nano /etc/sysctl.conf

文件最后添加：

    net.ipv4.ip_forward=1

    net.ipv6.conf.all.forwarding = 1

执行命令生效： 

> sysctl -p

### 配置iptable转发规则

> nano /etc/clashiptable.sh

内容见： https://raw.githubusercontent.com/arctg70/smgate/master/clashiptable.sh

保存退出

> chmod +x /etc/clashiptable.sh

### 添加开机启动

> nano /etc/rc.local

在exit 0前面添加如下内容

> sudo bash /etc/clashiptable.sh

保存退出

> systemctl daemon-reload

至此设置结束。 

### 测试透明网关

将上网设备连接到局域网中，设置手动网关为树莓派192.168.99.2，DNS为192.168.99.2

打开以下网址，测试用于访问国内与国外的IP： http://ip111.cn/

