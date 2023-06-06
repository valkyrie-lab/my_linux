# 备份
利用tar对系统进行全备份

# 打包系统
##备份软件安装列表
pacman -Qqen > packages-repository.txt
pacman -Qqem > packages-AUR.txt
### 从软件列表中重新安装软件
pacman --needed -S - < packages-repository.txt
cat packages-AUR.txt | xargs yaourt -S --needed --noconfirm
清除多余软件（孤包）
yaourt -R `pacman -Qdqt`

## 创建一个排除备份的列表

```markdonw
#vi /excl
/proc/*
/dev/*
/sys/*
/tmp/*
/mnt/*
/media/*
/run/*
/var/lock/*
/var/run/*
/var/lib/pacman/*
/var/cache/pacman/pkg/*
/lost+found
```

sudo tar --use-compreess-program=pigz -cvpf arch-backup.tgz --exclude=/proc --exclude=/lost+found --exclude=/arch-backup.tgz --exclude=/mnt --exclude=/sys --exclude=/run/media --exclude=/media 


# 备份uuid  目录挂载 分区
$ sudo uuid > a.uuid

$ df -Th

$ sudo fdisk -l


# 从备份中恢复
## 按之前的系统进行分区后挂载目录
live-cd 是没有用户密码的需要先设置root密码
$ sudo passwd root

### 切换到/mnt 目录下 解包

$ tar -xvpzf arch-backup.tgz -C . --numeric -owner

### 修改 UUID
/mnt/etc/fstab

###reboot

