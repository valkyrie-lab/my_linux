# 重新配置hyprland 桌面配置环境
- WM: Hyprland
- OS: Archlinux

## 依赖软件列表
- waybar-hyprland-git waybar-mpris-git starship fish (剔出)
```
paru -S hyprland-git  cava  python rustup kitty wofi xdg-desktop-portal-hyprland-git tty-clock-git swaylockd swaylock-effects-git swayidle grim slurp jq dunst wl-clipboard cliphist wl-clip-persist swww-git zsh tmux ranger sddm-git qt5-base qt5-wayland qt6-base qt6-wayland light g4music btop
```
- 重写 hyprland 配置
hyprctl clients : list of windows message

- 完善 hyprland 脚本

## 触屏相关

## 触摸板手势
libinput-gestures
hyprland-touch-gestures

- 触摸屏配置，支持多点触控，手势
xf86-input-mtrack

- xf86-input-wacom 仅支持x11, wayland 下无法对设备进行配置
    [Wayland · linuxwacom/xf86-input-wacom Wiki](https://github.com/linuxwacom/xf86-input-wacom/wiki/Wayland)

-- libinput
[libinput 1.23.0 文档](https://wayland.freedesktop.org/libinput/doc/latest/)

-- 原来的X11 touch.conf 不太适用

### 数位板支持
````
yay -S opentabletdriver-git

systemctl --user enable --now opentabletdriver

disable wacom modules in /etc/modprobe.d/blacklist.conf
````

### touchscreen setting
````
## hyprland.conf
# 将触控笔和触控屏幕两个功能分开设置即可实现不同的旋转
_________________
device:gxtp7380:00-27c6:0113-stylus { ## touch  pen
    transform=0
    output=DSI-1
  }

device:gxtp7380:00-27c6:0113 { ## touch screen
    transform=1
    output=DSI-1
  }
````
### 锁屏禁止触屏,仅通过键盘按键点亮屏幕
 ````
 misc {
  mouse_move_enables_dpms = false ## 关闭禁用鼠标移动唤醒可以一同禁用触控唤醒
  key_press_enables_dpms = true ##dmps为关闭时，只能通过键盘来唤醒屏幕
}
````

- [libinput - ArchWiki](https://wiki.archlinux.org/title/libinput)
libinput 不解释手势 触摸屏 所以这个实用程序只能用于触摸板，不能用于触摸屏。-- (https://github.com/bulletmark/libinput-gestures)

### wvkbd 虚拟键盘 (工作)

````
yay -S wvkbd

wvkbd-mobintl
````

hyprland-per-window-layout 支持多键盘布局
````
exec-once = hyprland-per-window-layout
````

## GPD pocket 3 自动旋转支持
[iio-hyprland, Listen iio-sensor-proxy and auto change Hyprland output orientation](https://github.com/JeanSchoeller/iio-hyprland/)
-- 开机自动旋转正常支持
-- 不支持触摸旋转
````
yay -S iio-hyprland-git

# 添加到hyprland config
exec-once iio-hyprland DSI-1
````
### 脚本实现自动旋转触控以及手写笔和屏幕显示
````
````

## Clipboard setting
- wl-clipboard: 提供 wayland 剪贴板支持
    - exec-once
        `exec-once = wl-paste --type text --watch cliphist store   #Stores only text data`
        `exec-once = wl-paste --type image --watch cliphist store  #Stores only image data`

- cliphist: 支持文本和图片的剪贴板包装应用
- - clipboard store show whith wofi
    - keybind
        `bind = SUPER, V, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy`

- wl-clip-persist: 长时间保存剪贴板数据
    - exec-once
        `exec-once = wl-clip-persist --clipboard both              # Use Regular and Primary clipboard,long :w`

## Screenshot
- grim: Grab images from a Wayland compositor.
- slurp: Select a region in a Wayland compositor and print it to the standard output
这两个一起配合实现选区截图并保存到剪切板上
    - keybind:
        ````
        bind=SUPER,i,exec,grim -g "$(slurp)" - | wl-copy
        ````
- 配合 `bar` 实现鼠标点击截图功能
````
`~/.config/hypr/scripts/screensort`
_____________________________
#!/usr/bin/bash

grim -g "$(slurp)" - | wl-copy
````

## Lock Screen
- swaylock-effects-git: 锁屏
- swaylockd: swaylock 的启动器，对实用功能进行了包装
- swayidle: 管理空闲事件
配合hyprctl 控制dpms

````
# ~/.config/hypr/scripts/lock
_____________________________
#!/usr//bin/bash

swaylockd --screenshots \
          --grace-no-mouse \
          --grace-no-touch \
          --indicator \
          --clock \
          --inside-wrong-color f38ba8 \
          --ring-wrong-color 11111b \
          --inside-clear-color a6e3a1 \
          --ring-clear-color 11111b \
          --inside-ver-color 89b4fa \
          --ring-ver-color 11111b \
          --text-color  f5c2e7 \
          --indicator-radius 80 \
          --indicator-thickness 5 \
          --effect-blur 10x7 \
          --effect-vignette 0.2:0.2 \
          --ring-color 11111b \
          --key-hl-color f5c2e7 \
          --line-color 313244 \
          --inside-color 0011111b \
          --separator-color 00000000 \
          --indicator-caps-lock \
          --fade-in 0.1 \
          --daemonize

## Dpms ctl ( 2 s )
swayidle -w \
  timeout 2 'if pgrep -x swaylock; then hyprctl dispatch dpms off; else killall swayidle; fi'

````

## 壁纸切换
- 自动切换壁纸
在swww的示例配置中的自动换壁纸脚本
- [swww/swww_randomize.sh at main](https://github.com/Horus645/swww/blob/main/example_scripts/swww_randomize.sh)

## wallpaper and file maneger
- thunar
````
 # @ thunar
   # 支持键盘操作的GUI文件浏览器
   TUMBLER 显示缩略图 -- 默认包不显示缩略图
   # 一些其他文件的缩略图支持
     VEDIO :FFMPEGTHUMBNAILER
     PDF   :POPPLER-GLIB
   # --------------------------
   # 支持移动设备自动挂载需要额外的包
     GVFS
     GVFS-MTP
     GVFS-AFC
````
- ranger + 壁纸切换
````
~/.bscripts/wallset PATH_TO_FILE
#_______________________________
````
- 使用ranger快捷切换壁纸

````
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
            self.fm.run('swww img ' + target_filename )
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
````



## Hight DPI
### FireFox DPI 高分辨率下firefox字体和界面自动放大的问题

1. Open about:config
2. Search `layout.css.devPixelsPerPx` change to `1.5` same to hyprland scale (1.5)

### xwayland 高DPI模糊问题
- aur/hyprland-hidpi-xprop-git

## 其他程序
- https://github.com/sezanzeb/input-remapper : 鼠标键盘按键重新映射工具
- https://wiki.archlinux.org/title/Xmodmap

## 空闲音频抑制器
- https://github.com/ErikReider/SwayAudioIdleInhibit

## bar (暂时不需要)
- time
- workspace

## github ssh (Done)


## broot (Done)
- [Install br - Broot --- 安装 br - 布根](https://dystroy.org/broot/install-br/)
yay -S broot-git


##  不用 DM 启动 hyprland
````
if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
  # exec wayfire
  # exec sway --unsupported-gpu
  exec Hyprland
  # startx
fi
````

## zsh 相关
- zshenv zshrc zshlogin
````
path+=(~/.local/bin;~/.ghcup/bin)

# use bat as man pager
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
````

## 音量 背光快捷键控制
````
# Light (未添加通知)
binde=,code:232,exec,light -U 10
binde=,code:233,exec,light -A 10

# Audio (未添加通知), 使用bindle 可以在锁屏的情况下更改音量
bindle=,code:122,exec,amixer set Master 1%-
bindle=,code:123,exec,amixer set Master 1%+
````

## 音量 背光， 进度条
- wob : [GitHub - francma/wob: Wayland 的轻量级叠加卷/背光/进度/任何栏。](https://github.com/francma/wob) 暂时不采用
    - 创建配置文件
````
    ~/.config/wob/wob.ini
    _____________________
    timeout = 1000
    max = 100
    width = 400
    height = 50
    border_offset = 4
    bar_padding = 4
    bar_color = FFFFFF
    margin = 0
    anchor = top center # (top = 1, bottom = 2, left = 4, right = 8 |  top, left, right, bottom, center)
    overflow_mode = 0 # (wrap = 0, nowrap = 1)
    output_mode = whitelist # (whitelist = 0, all = 1, focused = 2)
    #border_color =
    #


    [output.left]
    name = DP-1

    [output.ips]
   name = HDMI-1

    [style.muted]
    background_color = 032cfc
````

- hyprland env config
````
set $WOBSOCK $XDG_RUNTIME_DIR/wob.sock
exec rm -f $WOBSOCK && mkfifo $WOBSOCK && tail -f $WOBSOCK | wob
````

- 采用dunst 显示背光，音量调节的进度条

- wlsunset [yes] 支持 wlr-gamma-control-unstable-v1 和 xdg-output-unstable-v1 的 Wayland 合成器的日/夜伽玛调整。
````
wlsunset -l 39.9 -L 116.3
````

## 特殊工作区（暂存区）
````
# Scratchpad
## 将当前窗口发送到特殊工作区
bind = SUPER_ALT,grave,movetoworkspace, special
## 显示和隐藏特殊工作区
bind = SUPER,grave,togglespecialworkspace,

### 将特殊工作区的窗口发送到当前屏幕活动的工作区并平铺
bind = SUPER_ALT, w, movetoworkspace, m+1
bind = SUPER_ALT, w, togglefloating, window

````
## 实用程序
-- Chat
    -- icalingua++ : QQ
    -- telegram

-- ScreenSort
    -- flameshot :  Working bad on wayland, No supper multi-monitor display
    -- kooha : 支持wayland的录屏工具
    -- OBS
    -- grimblast: 

-- tailscale-git

-- wev :键盘按键码识别

-- vimiv-qt :利用键盘来预览图像的gui图像预览
    -- [Getting Started — vimiv documentation](https://karlch.github.io/vimiv-qt/documentation/getting_started.html)

-- waydroid :完整的安卓

--

## waydroid
[Waydroid | Android in a Linux container --- 机器人 |Linux 容器中的 Android](https://waydro.id/)

## TODO
截屏
z-shell H-S-MW
dpms: switch 不好使
手动dpms
