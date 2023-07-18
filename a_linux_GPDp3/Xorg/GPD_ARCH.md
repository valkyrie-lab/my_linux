# GPD Pocket 3
CreateTime: 2022/11
> 2022.11 记录：由于将 NetworkManager 与 dhcpcd 服务同时开启后禁用了一次网卡后使用rfkill，nmcli，ip等工具皆无法解除网卡限制，故重装。如果对此问题感兴趣可以一起讨论。

```
# 仅保证本配置适合以下列出的主要配置
        - 机器型号：  Pocket 3,i7-1195G7 以下简称为 P3
        - 仅安装：    ArchLinux 系统(非双系统)
        - 启动方式：  EFI+bios
        - 文件系统：  lvm+btrfs (lvm应该舍弃，lvm+btrfs毫无作用)
        - WM：       bspwm
```
[TOC]
---
# **参考文章列表:**
- [Arch-Install-Note/arch安装,lvm+btrfs+zfs -----------GitHub](https://github.com/a15355447898a/Arch-Install-Note/blob/main/arch%E5%AE%89%E8%A3%85%2Clvm%2Bbtrfs%2Bzfs.md)

- [Arch linux 202209版本安装实录--------------------------SDN博客](https://blog.csdn.net/zo2k123/article/details/126325231)

- [2022.5 archlinux详细安装过程--------------------------- 知乎](https://zhuanlan.zhihu.com/p/513859236)

- [Arch Linux 安装教程（基础安装篇）------------------- 哔哩哔哩](https://www.bilibili.com/read/cv16392057)

- [安装Arch Linux【2022.09.10】--------------------------知乎](https://zhuanlan.zhihu.com/p/112541071)

- [Installation guide--------------------------------------------ArchWiki](https://wiki.archlinux.org/title/Installation_guide)

- [在 LVM 上安装 Arch Linux---------------------------------ArchWiki](https://wiki.archlinux.org/title/Install_Arch_Linux_on_LVM)

- [ArchWiki:GPD_pocket_3-----------------------------------ArchWiki](https://wiki.archlinux.org/title/GPD_Pocket_3)

- [mount-oremountrw命令----------------------------------百度文库](https://wenku.baidu.com/view/f82936054b2fb4daa58da0116c175f0e7cd119c8.html?_wkts_=1669002848566&bdQuery=mount+-o+umount+rw+%2F)

- [host: Network configuration - --------------------------ArchWiki](https://wiki.archlinux.org/title/Network_configuration#Set_the_hostname)

- [ defencore/gpd-pocket-3-linux--------------------------GitHub](https://github.com/defencore/gpd-pocket-3-linux)

- [bspwm 入门 ---------------------------------------------------哔哩哔哩](https://www.bilibili.com/read/cv7417123)

- [从零开始的Bspwm安装与配置教程---------------------知乎](https://zhuanlan.zhihu.com/p/568211941)

- [Linux-patches/GPD-Pocket-3.md at main · JohnJayMcKaye/Linux-patches · GitHub](https://github.com/JohnJayMcKaye/Linux-patches/blob/main/GPD-Pocket-3.md)

# **TIP 列表**
- [FS#68945：user_readenv --------------------------------# .pam_environment 已弃用](https://bugs.archlinux.org/task/68945)
- [Network configuration  ------------------------------------# about hosts --- ArchWiki](https://wiki.archlinux.org/title/Network_configuration#localhost_is_resolved_over_the_network)
---
> 关于P3固件更新  [GPD Pocket 3 - ArchWiki](https://wiki.archlinux.org/title/GPD_Pocket_3#Firmware)

 P3 不支持 fwupd 更新固件，目前仅支持通过 Windows 程序提供固件更新 \
 由于硬件驱动问题 手写笔(Digitizer) 有部分功能支持不完善，指纹传感器(Fingerprint Sensor)不支持

# 提前准备
- arch linux镜像---[推荐在arch官网下载](https://archlinux.org/download/)
- [ventoy](https://github.com/ventoy/Ventoy.git) 启动盘制作工具
- U盘

# 一、 基础archlinux安装
## 1. 制作 Live CD
  使用 ventoy 制作启动盘, 注意由于ventoy会将整个U盘格式化，请准备一个空的U盘，或提前做好数据备份\
  启动盘制作完成后将系统镜像文件拷贝到U盘即可

## 2. 进入 Live CD
  更改电脑启动方式为U盘启动

1. 临时改变显示方向，并解决 TTY 字体过小---[linux console](https://wiki.archlinux.org/title/Linux_console_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)) （安装完基础系统后会有持久化的方法）
    - P3 屏幕默认是逆时针旋转90度显示，因为 P3 显示屏是专为纵向设备设计的
```sh
    echo 1 > /sys/class/graphics/fbcon/rotate_all

    setfont ter-u32b
```

## 3. 连接网络
> 以下所使用的命令都是安装镜像预配置并已经启用的
---
```
# 有线连接
## 使用 DHCP 获取 ip 和 DNS
    dhcpcd

# 无线网
## 使用 ip-link 查看网卡状态
    ip link
```
- 如果无线网卡无法启动，尝试使用 rfkill 解除限制 [ArchWiki_rfkill](https://wiki.archlinux.org/title/Network_configuration/Wireless#Rfkill_caveat)

```
# 使用 iwctl 扫描并连接 wifi
## 查看网卡名称(Driver Name)
    device list

## 扫描 wifi
    station 'DeviceName' scan

## 显示扫描结果
    station 'DeviceName' get-networks

## 连接wifi
    station 'DeviceName' connect 'SSID-Wifi-Name'

# 连接隐藏 wifi
## 扫描获取目标AP设备的MAC
    station 'DeviceName' get-hidden-access-points
## 使用MAC连接
    station 'DeviceName' connect 'AP-MAC'
```

- 拨号连接(PPP/PPPOE)
拨号连接使用 'NetworkManager' 提供的 tui 应用: nmtui
![nmtui](/home/awarewen/Pictures/Screenshots/2023-02-07_09:16:15.png)

## 4. 更新系统时钟
```
# 如果不进行此步可能造成后续下载基本系统失败
    timedatectl set-ntp true
```

## 5. 分区
- 2023年2月19日：lvm+btrfs 应该改为btrfs

- 1T SSD 硬盘分区方案 (使用 cfdisk):

     |Driver_name | Part_name   | Filesystem | Size       | 备注|
     |------------|-------------|------------|------------|--
     |nvme0n1p1   | system boot | BIOS boot  |  2M        |启动分区
     |nvme0n1p2   | EFI         | EFI System |  1G        |启动分区
     |nvme0n1p3   | linux swap  | linux swap |  18G       |交换分区
     |nvme0n1p4   | Arch        | Linux LVM  |  剩下的空间|root/home/snapshots


```
# 创建LVM卷
______________________________________
## 创建物理卷标记(PV)
    pvcreate  /dev/nvme0n1p4

## 检查物理卷
    pvdisplay
    pvs

## 创建卷组(VG)
    vgcreate Arch /dev/nvme0n1p3
## 检查：
    vgdisplay
    vgs

## 创建逻辑卷(LV)
    lvcreate -L 400G Arch -n root
    lvcreate -L 400G Arch -n homepool
    lvcreate -l +100%FREE Arch -n .snapshots

## 检查：
    lvdisplay
    lvs
--------------------------------------
```

```
# 格式化分区
______________________________________
    mkfs.vfat /dev/nvme0n1p2
    mkswap /dev/nvme0n1p3
    swapon /dev/nvme0n1p3
    mkfs.btrfs /dev/mapper/Arch-root
    mkfs.btrfs /dev/mapperArch-homepool
--------------------------------------
```
```
# 创建btrfs子卷
______________________________________
## root 子卷
    mount /dev/mapper/Arch-root /mnt
    cd /mnt
    btrfs subvolume create @
    cd /
    umount /mnt

## snapshots 子卷
    mount /dev/mapper/Arch-.snapshots /mnt
    cd /mnt
    btrfs subvolume create @snapshots
    cd /
    umount /mnt

## home 子卷
    mount /dev/mapper/Arch-homepool /mnt
    cd /mnt
    btrfs subvolume create @home
    cd /
    umount /mnt
--------------------------------------
```

```
# 挂载
______________________________________
## 根目录
    mount /dev/mapper/Arch-root /mnt -o subvol=@

## boot分区
    mkdir /mnt/boot
    mount /dev/nvme0n1p2 /mnt/boot

## home分区
    mkdir /mnt/home
    mount /dev/mapper/Arch-homepool /mnt/home -o subvol=@home

## snapshots分区
    mkdir /mnt/.snapshots
    mount /dev/mapper/Arch-.snapshots /mnt/.snapshots -o subvol=@snapshots
--------------------------------------
```
> ##### TIP
` mount -o remount,rw -a`将原先是只读的文件系统以可读写的模式重新挂载
- 分区 label 重写
`wipefs --all /dev/DISK_NAME` 命令清除label
[WIKI中描述了一个非常类似的问题](https://wiki.archlinux.org/title/USB_flash_installation_medium)
VFAT文件系统： dosfslabel
ntfs文件系统： ntfslabel

## 7. 镜像安装
```
# 更新国内镜像源
    reflector -c China -a 10 --sort rate --save /etc/pacman.d/mirrorlist

# 安装archlinux-keyring 刷新密钥
## 如果使用旧镜像安装系统请先更新密钥
    pacman -Syy archlinux-keyring

# 安装基本包及基本工具
    pacstrap -k /mnt base linux linux-firmware networkmanager network-manager-applet\
                dhcpcd vim neovim linux-headers bash-completion zsh\
                git openssh base-devel lvm2 btrfs-progs\
                intel-ucode  efibootmgr grub
    # ~btrfs-progs~
    # ~xfsprogs~
    # @os-prober
    # --检测多系统引导
```

## 8. 生成分区表
```
    genfstb -U /mnt >> /mnt/etc/fstab

# 检查分区表：
    cat /mnt/etc/fstab
```
- 请仔细查对分区表所对应的UUID是否正确，查看是否有漏缺

## 9. 切换根目录
```sh
    arch-chroot /mnt
```
## 10. 配置 LVM 支持和grub (弃用LVM)
### 1. mkinitcpio 钩子
```
#### mkinitcpio 钩子
    vim /etc/mkinitcpio.conf
____________________________
    ###
    #
    'HOOKS=".... lvm2'
    # @ HOOKS="... lvm2 filesystems"请在filesystems 前面添加 lvm2模块加载

#### for btrfs check
    MODULES=(btrfs)
    BINARIES=(btrfs)
----------------------------

#### 重新生成 initcpio
    mkinitcpio -P
```
### 2. 修改默认 Grub 参数
- [GRUB (简体中文) - ArchWiki](https://wiki.archlinux.org/title/GRUB_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)#BIOS_%E7%B3%BB%E7%BB%9F)
```
    /etc/default/grub
_____________________
    GRUB_PRELOAD_MODULES="... btrfs"
    GRUB_DISABLE_OS_PROBER=false
    GRUB_CMDLINE_LINUX_DEFAULT="... root=/dev/mapper/Arch-root nowatchdog"
    # @ nowatchdog
    # --减少关机时需要等待的时间
--------------------------------------------------------------------------

#### 如果已经安装生成过 grub，修改后请重新生成 grub
grub-mkconfig -o /boot/grub/grub.cfg
```

### 3. 安装 Grub

```
## BIOS_boot
### 注意留空的 '2M' 未格式化分区，用来存放 'BIOS_boot' 方式启动所需要文件
    grub-install --target=i386-pc /dev/nvme0n1
    # @ '/dev/nvme0n1'
    # --注意此处为设备名称而非分区名称 'nvme0n1p1'

### UEFI_efi
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch --recheck
    # @ '--bootloader-id'
    # --指定一个显示在 GRUB 菜单的名称

### 生成 Grub 配置
    grub-mkconfig -o /boot/grub/grub.cfg
```

## 11. 校正时区
```
### 设置本地时区
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

### 同步硬件时钟
    hwclock --systohc
```

## 12. 本地化
````
### 将 'en_US.UTF-8 UTF-8' 'zh_CN.UTF-8 UTF-8' 取消注释
    vim /etc/locale.gen
    locale-gen

### 字符终端不要用 'zh_CN.UTF-8' 会中文乱码
    echo "LANG=en_US.UTF-8" >> /etc/locale.conf

### 主机名
    echo "your_hostname" >> /etc/hostname

### 设置 hosts 解析
### systemd 中提供了 NSS 模块无需配置 hosts 就可以使用本地主机名称解析服务
### 但是一些程序仍然会依赖于 /etc/hosts 文件
/etc/hosts
______________
    127.0.0.1       localhost
    ::1             localhost
    127.0.0.1       'your_hostname'.localdomain   'your_hostname'
    # @ 'your_hostname' 请和'/etc/hostname'中填写相同主机名称
-----------------------------------------------------------------
````
- host 请见:[Network configuration - ArchWiki](https://wiki.archlinux.org/title/Network_configuration#localhost_is_resolved_over_the_network)

## 13. Root用户和普通用户
```
# 设置 root 用户密码
    passwd root

# 创建用户并添加到 wheel 用户组
    useradd -m -g users -G wheel,storage,power 'the_user_name'

# 设置密码
    passwd 'the_user_name'

# 为 wheel 用户组更改用户权限
    EDIOR=vim visudo
    # 找到 'Uncomment to allow members of group wheel to execute any command' 将下一行配置取消注释
```
[xdg-用户目录](https://www.freedesktop.org/wiki/Software/xdg-user-dirs/)

# 二、安装桌面前的准备
```
# 提供基本的用户文件管理服务
    sudo pacman -S xdg-user-dirs

# 安装sddm
    sudo pacman -S sddm xorg
```

## 1. systemed ：一些必要的服务配置
```
    sudo systemctl disable dhcpcd
    sudo systemctl enable NetworkManager
    sudo systemctl enable sshd
    sudo systemctl enable sddm
```

## 2. 如果需要更换SHELL
- [Command-line shell - ArchWiki](https://wiki.archlinux.org/title/Command-line_shell)
```
# 检查当前用户默认SHELL:Zsh SHELL
    echo $SHELL

# 检查可用的Shell
    chsh -l

# 更换 Shell
    chsh -s /bin/zsh your_user_name`
```

## 3. 配置AUR
1. 添加国内源打开,并32位支持
[2022.5 archlinux详细安装过程 - 知乎](https://zhuanlan.zhihu.com/p/513859236)
```
    /etc/pacman.conf
____________________
    [archlinuxcn]
    #Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch
    #深大源
    Server = https://mirrors.sustech.edu.cn/archlinuxcn/$arch

    [Clansty]
    SigLevel = Never
    Server = https://repo.lwqwq.com/archlinux/$arch
    Server = https://pacman.ltd/archlinux/$arch
    Server = https://repo.clansty.com/archlinux/$arch
-------------------------------------------------------------------

# 添加keyring
    sudo pacman -S archlinuxcn-keyring
```
2. 安装 AUR HELPER
```
# 安装AUR helper
    sudo pacman -S base-devel --needed
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si

# 可选依赖可以装一下
    sudo pacman -S bat asp
```

## 4. 驱动
```
# 显示驱动(intel 核显)
    sudo pacman -S xf86-video-intel vulkan-intel
    # -- mesa驱动，造成firefox画面撕裂

# 蓝牙
    sudo pacman -S bluedevil

# 声音
    sudo pacman -S alsa-utils pulseaudio pulseaudio-bluetooth

    /etc/modprobe.d/alsa.conf
_____________________________
    options snd-intel-dspcfg dsp_driver=1
-----------------------------------------

# 2022 12/7
# @ pipewire 替换 pulseaudio
# --pipewire pipewire-pulse pipewire-zeroconf lib32-pipewire pipewire-alsa
# --@ pipewire 管理器选择：wireplumber
```

## 5. 显示，触屏方向问题，字体显示并持久化

- [GitHub - defencore/gpd-pocket-3-linux: GPD Pocket 3 Linux](https://github.com/defencore/gpd-pocket-3-linux)
1. TTY界面

```
# 添加内核参数fbcon
    /etc/default/grub
_____________________
    GRUB_CMDLINE_LINUX_DEFAULT="... fbcon=rotate:1"
    GRUB_CMDLINE_LINUX="... fbcon=rotate:1"
    GRUB_GFXMODE=1200x1920x32
---------------------------------------------------

# 重新生成grub启动配置
    sudo grub-mkconfig -0 /boot/grub/grub.cfg
```
2. SDDM界面
```
# 添加Xsetup脚本旋转SDDM登陆界面
    /usr/share/sddm/scripts/Xsetup
__________________________________
    #! /bin/sh
    `xrandr -o right`
-----------------------------
```
3. 自动旋转(目前不可用)
```
  1. xrandr and xinput rotation can be automated with 2in1screen.
  yay -S xorg-xinput

2. # 自动旋转屏幕方向
    sudo iio-sensor-proxy-git
         kded-rotation-git (KDE)
         screenrotator-git (GNOME)

    ##
    3 .wget https://raw.githubusercontent.com/defencore/gpd-pocket-3-linux/main/screen-auto-rotate.c
    gcc -O2 -o screen-auto-rotate screen-auto-rotate.c
    ./screen-auto-rotate
```

4. 触屏方向
```
    /etc/X11/xorg.conf.d/99-touchsreen.conf
___________________________________________
    Section         "InputClass"
      Identifier    "calibration"
      MatchProduct  "GXTP7380"
      Option        "TransformationMatrix" "0 1 0 -1 0 1 0 0 1"
    EndSection

    # 0°   Option "TransformationMatrix" "0 1 0 -1 0 1 0 0 1"
    # 90°  Option "TransformationMatrix" "-1 0 1 0 -1 1 0 0 1"
    # 180° Option "TransformationMatrix" "0 -1 1 1 0 0 0 0 1"
    # 270° Option "TransformationMatrix" "1 0 0 0 1 0 0 0 1"
---------------------------------------------------------------
```


5. TTY字体
- [vconsole 介绍](https://man.archlinux.org/man/vconsole.conf.5)
```
# 新环境请先安装 terminus-font
    yay -S terminus-font

# 创建并写入配置
    touch /etc/vconsole.conf
____________________________
    FONT=ter-u32b
----------------------------
```

### NOTE
  > 由于底层原因这并没能将Grub菜单旋转，目前无法修复

6. 安装装bspwm sxhkd
- [从零开始的Bspwm安装与配置教程 - 知乎](https://zhuanlan.zhihu.com/p/568211941)
```
# 窗口管理器 bspwm 和快捷键守护进程 sxhkd
    sudo pacman -S bspwm sxhkd

# 将 bspwm 与 sxhkd 示例配置文件拷贝到 '.config' 目录下
    mkdir ~/.config
    # .config 目录将作为大部分程序或软件的配置存放目录
    cd ~/.config
    cp /usr/share/doc/bspwm/examples/bspwmrc bspwm/
    cp /usr/share/doc/bspwm/examples/sxhkdrc sxhkd/

# Firefox浏览器,Rofi应用启动器,Kitty终端
    sudo pacman -S firefox rofi kitty

# 更改 sxhkdrc 配置
    ~/.config/bspwm/sxhkdrc
___________________________
    # kitty terminal
    super + Return
      kitty
    # rofi program launcher
    super + space
      rofi -show drun
---------------------------
```

# 三、完成准备重启
    reboot

# 四、开始配置桌面环境
## 1. 输入法和字体
```
# 英文字体
pacman -S ttf-dejavu ttf-droid ttf-hack ttf-font-awesome otf-font-awesome ttf-lato ttf-liberation ttf-linux-libertine ttf-opensans ttf-roboto ttf-ubuntu-font-family

# 中文字体
paru -S ttf-hannom noto-fonts noto-fonts-extra noto-fonts-emoji noto-fonts-cjk adobe-source-code-pro-fonts \
          adobe-source-sans-fonts adobe-source-serif-fonts adobe-source-han-sans-cn-fonts \
          adobe-source-han-sans-hk-fonts adobe-source-han-sans-tw-fonts adobe-source-han-serif-cn-fonts wqy-zenhei wqy-microhei
```

1. Fcitx5 框架、主题、词库
    - [Fcitx5 - ArchWiki](https://wiki.archlinux.org/title/Fcitx5#Configuration)
    - [Environment variables - ArchWiki](https://wiki.archlinux.org/title/Environment_variables#Defining_variables)
```
# 安装输入法框架和配套
    sudo pacman -S fcitx5-im fcitx5-chinese-addons fcitx5-material-color fcitx5-pinyin-moegirl fcitx5-pinyin-zhwiki fcitx5-lua
    # @fcitx5-im：基础输入框架
    # @fcitx5-chinese-addons 中文输入引擎
    # @fcitx5-material-color 主题
    # @fcitx5-pinyin-moegirl @fcitx5-pinyin-zhwiki 词库
    # @fcitx5-lua lua插件支持

# 添加运行环境参数
    touch ~/.xprofile
_____________________
    ### 此配置仅适合xorg环境
    # @Tip:
    # --不要使用'.pam_environment' 已被弃用
    # --可以使用 '.xprofile','.zprofile','.bash_profile' 进行环境参数配置

    export GTK_IM_MODULE=fcitx
    export QT_IM_MODULE=fcitx
    export XMODIFIERS=\@im=fcitx
    export INPUT_METHOD=fcitx
    export SDL_IM_MODULE=fcitx
    export GLFW_IM_MODULE=ibus    # for kitty terminal
-------------------------------------------------------------------------
```

- 修改字体渲染设置
```
    vim /etc/profile.d/freetype2.sh
___________________________________
    # 取消注释最后一句
    export FREETYPE_PROPERTIES="truetype:interpreter-version=40"
----------------------------------------------------------------
```

## 2. 从Dotfile开始
- [ikz87/dots-2.0: eww + bspwm rice c](https://github.com/ikz87/dots-2.0)
```sh
    git clone git@github.com:ikz87/dots-2.0.git
    cd dots-2.0.git
    chmod +x install.sh
# 将自动备份你的dot配置
    ./install.sh
```
### 添加 fcitx5 自启 (待定)
    echo "fcitx5 -d" >> ~/.config/bspwm/autostart

### 安装依赖
```

yay -Sy tlp tlp-rdw alsa-utils-git blueman bspwm colorpicker
        dunst eww-git flameshot hsetroot imagemagick jq kitty light
        betterlockscreen network-manager-applet pa-applet-git picom-ftlabs-git
        playerctl polkit-gnome polybar pipewire python3 rofi
        scrot sox sxhkd sysstat thunar wmctrl wpgtk-git xclip
        xdotool xprintidle xwinfo-git lm_sensors --needed

# 需要补充的依赖选项和配置项
tlpui tlp board
        # tlp电源管理
          - [TLP - ArchWiki](https://wiki.archlinux.org/title/TLP)
          # 屏蔽systemd服务防止冲突
              sudo systemctl mask systemd-rfkill.service
              sudo systemctl mask systemd-rfkill.socket

          # 启动网络服务
              sudo systemctl enable NetworManager-dispatcher.service
          # （P3设备）添加配置项
              # nano /etc/tlp.conf
              # ___________________________________
              CPU_SCALING_GOVERNOR_ON_AC=powersave
              CPU_SCALING_GOVERNOR_ON_BAT=powersave
              CPU_ENERGY_PERF_POLICY_ON_BAT=power
              CPU_BOOST_ON_AC=1
              CPU_BOOST_ON_BAT=0
              PLATFORM_PROFILE_ON_AC=performance
              PLATFORM_PROFILE_ON_BAT=low-power
              DISK_IOSCHED="mq-deadline"
              PCIE_ASPM_ON_AC=default
              PCIE_ASPM_ON_BAT=powersupersave
              # ------------------------------------

        # @ pipewire
          # pipewire 内部不实现任何连接逻辑，这些被其他外部组件如会话管理器所负担。
          lib32-pipewire  :32位应用支持
          wireplumber     :目前唯一推荐的会话管理器
              pipewire-pulse  :取代 pulseaudio 和 pulseaudio-bluetooth，（使用 pipewire-pulse.server 替换 pulseaudio.server）'pactl info 查看 "Server Name:PulseAudio (on PipeWire)'" 即成功
          pipewire-audio  :PulseAudio 和 JACK 兼容的服务器实现和 API兼容库来替代它们，处理蓝牙设备连接
          pipewire-alsa   :取代 ALSA 客户端（如果安装了pulseaudio-alsa ，请移除它）
          pipewire-jac   :jack 客户端启动支持
          pipewire-zeroconf   :pipewire 零配置支持（自动配置）

        # @ thunar
          # 支持键盘操作的GUI文件浏览器
          tumbler 显示缩略图 -- 默认包不显示缩略图
          # 一些其他文件的缩略图支持
            vedio :ffmpegthumbnailer
            PDF   :poppler-glib
          # --------------------------
          # 支持移动设备自动挂载需要额外的包
            gvfs
            gvfs-mtp
            gvfs-afc

## 2023/1/27 : picom 版本更改
# @picom-ftlabs-git

## 2023/3/17 : picom ftlabs 持续一个月没有更新，返回主线版本
```

```
# 依赖程序简介

# 一个用python和Qt编写的弹出通知工具
## python依赖：pyqt5 argparse inotify
    `pop_report`

# 电源管理
    acpi

# 声音
    alsa-utils

# 蓝牙
    blueman

# 窗口管理器
    bspwm

# 颜色拾取
    colorpicker

# 通知
    dunst

# bar
    eww
    polybar

    flameshot
    hsetroot

# kitty终端中显示图像
    imagemagick
#   @ C编写的跨平台的开源套件，用于显示、转换、编辑光栅图像和矢量图像，可读写超过200种图像文件格式。
#   imagemagick 提供了两个二进制文件：convert 和 identify

    jq

# 终端
    kitty

# 锁屏
    mantablockscreen
>   依赖：i3lock-color-git , imagemagick, xorg-xrandr, otf-san-francisco , imagemagick, xorg-xrandr, otf-san-francisco
>   @ betterlockscreen 替代

# 网络
    network-manager-appler
    pa-applet

# 合成器
    picom-animations-git
    # 替换 picom-ftlabs-git

# 媒体控制
    playerctl

# 声音后端
    pulseaudio

    polkit-gnome
    python3

# rofi
    rofi
    scrot
    sox

# 声破天
    spicetify-cli
    spotify

# 快捷键
    sxhkd

# 支持键盘操作的GUI文件浏览器
    thunar
    #_____
    # -- 默认包不显示缩略图，安装 tumbler 显示缩略图
    # -- 一些其他文件的缩略图支持
    # @vedio ：ffmpegthumbnailer
    # @PDF   ：poppler-glib
    #----------------------------
    # 支持移动设备自动挂载需要额外的包
    # @gvfs
    # @gvfs-mtp
    # @gvfs-afc


    wmctrl
    wpgtk

# 剪切板
    xclip


    xdotool
    xprintidle

# 系统信息打印
    xwinfo

sysstat

lm_sensors

```
####  软件/程序推荐
```
 #    桌面图形软件
-     ark       #       解压软件
-     dolphin   #       图形文件浏览器
-     telegram-desktop#
#     >     需要去项目地址下载编译

 #    终端下
-     fzf       #       信息过滤 配合fd / find / rg 等
-     fd        #       类似find
-     tmux      #       终端复用

-     neofetch  #       系统信息打印
-     fastfetch #       C语言编写的类neofetch
-     autojump  #       路径跳转
-     xoxide    #       更加智能的CD替代
-     rangerzoxide    #       更加智能的CD替代

-     ranger    #       文本文件浏览器
#     >     示例配置: ranger --copy-config=all(~/.config/ranger/)

      cups      #       开源的打印机驱动
#     编辑器
-     Emacs     #       支持多功能拓展的终端编辑器
      >DOOM Emacs
      >
-     vim/vi/neovim#    终端下专注于编辑的富文本编辑器
      >SpaceVim
#     VPN
-     tailscale #       点对点的外网穿透
-     v2raya    #       xray 内核的客户端程序

-     go-musicfox #     网易云
#     >     需要beep 这个包支持引擎

-     cava      #       音乐动画

 #    功能支撑
-     ntfs-3g   #       挂载ntfs文件格式硬盘
-     fcitx5    #       输入法支持
-     grub-custiomizer# 修改grub菜单启动界面
```
### 合成器
- ~~[AlexNomadrg/picom-animations: A lightweight compositor for X11](https://github.com/AlexNomadrg/picom-animations)~~ [x] (已弃用)
- [FT-Labs/picom: More than 10 unique animation supported picom fork (open window, tag change, fading ...)](https://github.com/FT-Labs/picom)
- [awarewen/dots-2.0: eww + bspwm rice c:](https://github.com/awarewen/dots-2.0)

### 屏幕亮度背光
- brightlight (弃用)
> [multiplexd/brightlight](https://github.com/multiplexd/brightlight)
和脚本(.bscripts/brightness.sh)配合控制背光

- light替换brightlight: [haikarainen/light: GNU/Linux application to control backlights](https://github.com/haikarainen/light#permissions)
---

> 如果选择配合脚本通知亮度即跟随以下配置
```
yay -S light

# 安装 light 包
    git clone git@github.com:haikarainen/light.git

# 更改权限为当前用户安装
    # Note: in this mode light runs unpriviliged, so the /etc/light directory (for cached settings) is not used, instead the per-user specific ~/.config/light is used.
    cd light
    ./autogen.sh
    ./configure --with-udev && make
    sudo make install

# 将用户添加到video组
    usermod -aG video <user>

# 修改'dots-2.0' 配置中的屏幕亮度调节脚本
    ~/.bscripts/brightness.sh
_____________________________
    #!/bin/bash

    # You can call this script like this:
    # $./brightness.sh up
    # $./brightness.sh down

    function get_brightness {
        var=`light -G`
        echo $var | sed 's/[^0-9][^.]*//g'
    }

    function send_notification {
        DIR=`dirname "$0"`
        brightness=`get_brightness`
        icon_name="${HOME}/Pictures/Important/icons/other/b.png"

        # Send the notification
        dunstify "Brightness: $brightness%" -h int:value:$brightness -i "$icon_name" -t 1000 --replace=555 -u critical
    }

    case $1 in
        up)
          # Raise the brightness (+ 5%)
          light -A 5 > /dev/null
          send_notification
      ;;
        down)
          # Lower the brightness (+ 5%)
          light -U 5 > /dev/null
          send_notification
      ;;
    esac
---------------------------------------

```

> 如果不考虑通知亮度调节
```sh
~/.config/bspwm/sxhkdrc
#______________________
# 注释原先用于调节亮度的脚本调用
~~"~/.bscripts/brightness.sh up"~~
~~"~/.bscripts/brightness.sh down"~~
# 分别添加
light -A 5 # 亮度增加 5%
light -U 5 # 亮度降低 5%
```

### 壁纸切换
```sh
~/.bscripts/wallset PATH_TO_FILE
#_______________________________
```
- 使用ranger快捷切换壁纸

```
# 添加一个自定义命令
    ～/.config/ranger/commands.py
_________________________________
    class set_wallpaper(Command)
        def execute(self):
            if self.arg(1):
                target_filename = self.rest(1)
            else:
                target_filename = self.fm.thisfile.path
            if not os.path.exists(target_filename):
                self.fm.notify("The given file does not exist!", bad=True)
                return
            self.fm.notify("run command: set_wallpaper " + target_filename)
            self.fm.run('~/.bscripts/wallset ' + target_filename)
---------------------------------------------------------------------------
    # @ self.fm.thisfile.path 获取当前选定的绝对文件路径
    # @ self.fm.notify 在ranger底栏显示一条信息
    # @ self.fm.run 运行一条命令，这里对wallset进行调用

# 为自定义命令添加键位绑定
    ~/.config/ranger/rc.conf
__________________________
    map tw set_wallpaper
--------------------------
    # @ tw 可以选择一个不冲突的键位绑定
```

### 锁屏
- mantablockscreen
    `yay -S mantablockscreen`

- 使用
缓存图像：
    `mantablockscreen -i PATH/TO/IMAGE`

### 2023/1/12 弃用 `mantablockscreen` ，使用 `betterlockscreen` 代替
- [betterlockscreen/betterlockscreen: 🍀 sweet looking lockscreen for linux system](https://github.com/betterlockscreen/betterlockscreen#usage)
```
# 在启动脚本中注释mantablockscreen
    ~/.config/bspwm/autostart
_____________________________
# Cache lockscreen
# mantablockscreen -i ~/Pictures/Important/lockscreen.png&

# 安装
    yay -S betterlockscreen

# 依赖
    i3lock-color-git
    imagemagick
    feh (可选)
    xorg-xdpyinfo
    xorg-xrandr
    dunst (可选)

# 示例配置文件，如果不执行复制示例配置，将使用硬编码的配置(与示例配置相同)
    mkdir -p ~/.config/betterlockscreen/
    cp /usr/share/doc/betterlockscreen/examples/betterlockscreenrc ~/.config/betterlockscreen/

# 缓存图像：
    betterlockscreen -u /PATH/TO/IMAGE

# 更改配置脚本
    ~/.bscripts/lock.sh
_______________________
    #!/bin/sh

    pkill -SIGUSR1 dunst # pause
    # mantablockscreen 弃用
    #mantablockscreen -sc # requires https://github.com/reorr/mantablockscreen
    betterlockscreen -l dim
    pkill -SIGUSR2 dunst # resume
```

## 切换内核
linux-lts linux-lts-headers
驱动 intel: xf86-video-intel
nvidia-lts
声音驱动 gpd匹配的
usbmuxd -usb设备驱动

## 记录LVM移除卷
创建 pv - vg - lv
移除 lv - vg - pv
如果移除时提示 read-only ：mount -o remount,rw -a (mount -o remount rw /) 以可读写的方式重新挂在所有设备
>
> partprobe 同步硬盘更改
wipefs 擦除分区filesystem标记


- [use KVM on pocket 3:Pocket 3 linux: Start kvm module with VLC : GPDPocket ](https://www.reddit.com/r/GPDPocket/comments/sd0pjs/pocket_3_linux_start_kvm_module_with_vlc/)

### 关于安装更新时遇到'PGP signature 'marginal trust' errors blocking upgrade'\
[ PGP signature 'marginal trust' errors blocking upgrade / Newbie Corner / Arch Linux Forums](https://bbs.archlinux.org/viewtopic.php?id=280650)\
```
    rm -rf /etc/pacman.d/gnupg
    pacman-key --init
    pacman-key --populate archlinux archlinuxcn
    pacman -Syy
```
如果还是有问题，请检查系统时间是否正确
```
    timedatectl set-ntp 1
    hwclock --systohc
```

#### zsh
    `sudo pacman -S zsh zsh-autosuggestions zsh-syntax-highlighting zsh-completions   `
- Z-shell
- zsh-zi-mode

#### git && github && ssh key
[Generating a new SSH key and adding it to the ssh-agent - GitHub Docs](https://docs.github.com/cn/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
```sh
# 检查 ssh 服务是否运行
    systemctl status sshd

# 创建ssh 密钥，用于Git操作GitHub远程仓库
    ssh-keygen -t ed25519 -C "your_enmail@example.com"

    eval "$(ssh-agent -s)"

# 添加已创建的私钥(默认名称)
    ssh-add ~/.ssh/id_ed25519

# 最后将公钥添加到 GitHub 设置中
## 测试
    ssh -T git@github.com

# 实现多个密钥的加载，需要在.zshrc中添加
    eval "$(ssh-agent -s)" &> /dev/null
    ssh-add ~/.ssh/id_ed25519 &> /dev/null
    ssh-add ~/.ssh/id_2 &> /dev/null
```


##    终端下代理（仍然存在问题）
```sh
#     kitty终端下
#     添加:
      export http_proxy=127.0.0.1:20171
      export https_proxy=127.0.0.1:20170
      export all_proxy=127.0.0.1:20171
#     @all_proxy 是为了让curl也能走代理

#     Tip
#     如果在删除 proxy 取消设置环境变量不起作用 请用 unset 命令
      unset http_proxy
```

####  SpaceVim
```sh
      curl -sLf https://spacevim.org/install.sh | bash -s -- -h
```


#### 添加一个副屏
- 仅做参考
    `xrandr --output HDMI1 --primary --rotate inverted --mode 1920x1080 --left-of DSI1`

## 安装deb包
```
# 安装debtap
    yay -S debtap
    sudo debtap -u

# 将deb包转换为pkg包
    debtap xxx.pkg

# 使用pacman安装xxx.pkg
    sudo pacman -U xxx.pkg
```

## 启用GuC HuC (11代intel cpu)
- [如何充分使用英特尔硬件（指南） - FAQ and Tutorials - Garuda Linux Forum](https://forum.garudalinux.org/t/how-to-fully-use-intel-hardware-guide/8193)

```
# TIP for P3: xf86-video-intel 请不要卸载，否则无法正常旋转桌面的方向

sudo pacman -S mesa lib32-mesa libva libva-intel-driver\
               libva-mesa-driver libva-vdpau-driver libva-utils\
               lib32-libva lib32-libva-intel-driver lib32-libva-mesa-driver\
               lib32-libva-vdpau-driver intel-ucode iucode-tool vulkan-intel\
               lib32-vulkan-intel intel-gmmlib intel-graphics-compiler intel-media-driver\
               intel-media-sdk intel-opencl-clang libmfx --need

    /etc/mkinitcpio.conf
________________________
    MOUDULE(intel_agp i915)
------------------------

    /etc/modprobe.d/i915.conf
_____________________________
    options i915 enable_guc=3
    options i915 enable_fbc=1
-----------------------------

    sudo grub-mkconfig -o /boot/grub/grub.cfg

    sudo mkinitcpio -P
```

## s2挂起 (P3)
- 目前 S3 休眠失效已经在 6.1.5 内核修复，无需任何配置即可正常使用
- [arch wiki :Suspend](https://wiki.archlinux.org/title/GPD_Pocket_3)

```
    /etc/default/grub
_____________________
    mem_sleep_default=s2idle
---------------------
    sudo grub-mkconfig -o /boot/grub/grub.cfg

# 忽略合盖操作

  /etc/systemd/logind.conf
__________________________
  IdleAction=lock
  HandleLidSwitch=lock

```
- 不同级别休眠的区别(s1,s2,s3,s4)
  处于这些状态之一的系统不执行任何计算任务，但是与关机状态不同，处于休眠状态的系统会在RAM或磁盘上保留内存状态，无需重新启动系统即可恢复到之前的工作状态。
s1 ：功耗比s0少，处理时钟关闭，停止总线时钟，硬件延迟通常不超过2秒
s2 ：与s1类似，cpu上下文和系统缓存的内容丢失，处理器关闭，某些总线断电，硬件延迟大于等于s1
s3 ：处理器关闭，主板上的一些芯片可能关闭，硬件延迟与s2相当，仅保留系统内存。
s4 ：关闭所有设备，系统从保存的休眠文件重启，如果无法加载休眠文件，则需要重新启动。硬件延迟较长且不确定。
s5

## 修复锁屏后蓝牙 wifi断开
  经过检查是在配置文件中的 ~/.bscripts/idle.sh 中设置了系统休眠，系统进入休眠状态后会停止wifi,蓝牙等外部设备
- 解决方案1): 移除此脚本
- 解决方案2): 注释启动脚本idle.sh
```
    ~/.config/bspwm/autostart
_____________________________
    # Autosuspend
    # killall idle.sh
    # pgrep idle.sh || ~/.bscripts/idle.sh > /dev/null 2> /dev/null&
-----------------------------
```

## 使系统在合盖时进入锁屏
- [logind.conf](https://www.freedesktop.org/software/systemd/man/logind.conf.html)

```
    /etc/systemd/logind.conf
____________________________
# 系统空闲时 （ignore 不做任何操作）
    IdleAction=ignore

# 笔记本合盖 （lock 锁屏）
    HandleLidSwitch=lock
----------------------------
```

默认情况下，在ArchLinux中挂载非系统分区需要密码验证，非常麻烦，可以修改配置文件：
/usr/share/polkit-1/actions/org.freedesktop.udisks2.policy
将此配置文件中的<action id="org.freedesktop.udisks2.filesystem-mount-system">
标签中的子标签<allow_active></allow_active>的值改为yes即可无需通过密码验证直接挂载分区。

####  记录好看的 dotfile
- [ayamir/bspwm-dotfiles: My Arch+Bspwm dotfiles](https://github.com/ayamir/bspwm-dotfiles)

- [rxyhn/tokyo: BSPWM - Aesthetic Dotfiles 🍚](https://github.com/rxyhn/tokyo)

- [ikz87/dots-2.0: eww + bspwm rice c:](https://github.com/ikz87/dots-2.0)

- [owl4ce/dotfiles: Aesthetic OpenboxWM Environment](https://github.com/owl4ce/dotfiles)


## eww 样式异常

# firefox
## 视屏加速
- [Linux-patches/GPD-Pocket-3.md at main · JohnJayMcKaye/Linux-patches · GitHub](https://github.com/JohnJayMcKaye/Linux-patches/blob/main/GPD-Pocket-3.md)
- `about:config`
```
gfx.webrender.enabled									true
widget.wayland-dmabuf-vaapi.enabled						true
media.ffmpeg.vaapi.enabled set to 						true
media.ffvpx.enabled set to 								false
media.rdd-vpx.enabled set to 							false
media.navigator.mediadatadecoder_vpx_enabled set to 	true

- install

yay -S intel-gpu-tools vainfo
sudo intel_gpu_top
vainfo
```

## firefox触屏滚动

- `/etc/security/pam_env.conf`
`MOZ_USE_XINPPUT2 DEFAULT=2`
- `about:config` ( default = 2 )
`dom.w3c_touch_events.enabled=1`
## 根据机体偏移角度旋转屏幕
大于多少旋转
小于多少不旋转
是否存在过度

## 多屏情况下触摸屏 (Xorg)
- [双显示器和多显示器设置 · linuxwacom/xf86-input-wacom Wiki · GitHub](https://github.com/linuxwacom/xf86-input-wacom/wiki/Dual-and-Multi-Monitor-Set-Up)

`yay -S xf86-input-wacom` :提供了xsetwacom工具

```
# 副屏拓展,将触控限定在DSI1输出并旋转方向
alias screenout='xrandr --output HDMI1 --primary --rotate inverted --mode 1920x1080 --right-of DSI1 && xrandr --output DSI1 --primary && bspc wm -r ~/.config/rice_assets/Images/wallpaper.png' && \
		xsetwacom set "GXTP7380:00 27C6:0113 touch" MapToOutput DSI1 && \
		xinput set-prop "GXTP7380:00 27C6:0113 touch" --type=float "Coordinate Transformation Matrix" 0 0.5 0 -1 0 1 0 0 1

alias screenout_all='xrandr --output HDMI1 --rotate inverted --mode 3840x2160 --right-of DSI1 && xrandr --output DSI1 --primary && bspc wm -r ~/.config/rice_assets/Images/wallpaper.png'
```


## 修复旋转屏幕时Eww/Polybar 显示问题
- 思路：
目前没有自动适应的方案，只能重写一份配置
采用手动或者在bar上面添加按钮点击时， (参考2inlscreen) 读取传感器参数然后切换触控矩阵和bar的大小
- 找个屏幕键盘 [x]: `yay -S wvkbd, wvkbd-mobintl`

