# 双系统: Windows + ArchLinux

```markdown
机器：GPD Pocket 3
系统：Windows + ArchLinux
硬盘：机械 500G + SDD 500G
目标分区格式：Btrfs
```
- 准备
  ventoy 系统盘，windows11 iso 文件，安装顺序是 windows - linux
> 尤其要记住在启动时要选择 UEFI 模式启动u盘否则在默认UEFI启动的主板上可能出现 windows 安装程序无法正常读取硬盘的情况。

## 分区
1. 在由于windows安装程序会自行分出EFI分区，所有需要在安装程序时使用windows的命令行修改创建的EFI分区
  将 SDD 硬盘分为以下部分

     |Driver_name | Part_name   | Filesystem | Size(MB) | 备注 |
     |------------|-------------|------------|------|--
     |nvme0n1p1   | windows EFI | EFI        | 300  | windows 启动分区
     |nvme0n1p2   | windows MSR | MSR        | 128  | windows 保留分区
     |nvme0n1p3   | windows C   | NTFS       | 150G | windows C盘
     |nvme0n1p4   | linux EFI   | EFI        | 512  | linux 启动分区
     |nvme0n1p5   | linux swap  | Linux Swap | 18G  | linux 交换分区
     |nvme0n1p6   | linux Root  | Btrfs      | 剩余 | linux 根分区
---

```markdown
进入到windows分区界面后，shift+f10 进入命令行模式
# 进入交互式分区程序
  diskpart

# 列出存储硬件列表
  list disk

# 选择要执行操作的硬件
  select disk 0

# 执行清理包括label
  clean

# 将磁盘label更改为GPT
  convert gpt

# 创建 Windows EFI 分区大小为300MB (size 单位为 MB)
  create partition efi size=300 (windows启动分区)

# 创建 Windows MSR 分区大小为128MB即可
  create partition msr size=128

# 创建 Windows C 分区 大小为150G
  create partition primary size=153600 (150G 主分区C盘)

# 退出
exit
exit

出来之后刷新分区，选择主分区即可正常安装系统
```

当windows安装完成后从启动盘进入 ArchLinux liveCD 完成剩余分区 (使用 cfdisk)
> 剩余的一块 HDD 硬盘做不常用的数据文件存储盘（可以用 NTFS 分区格式），这样也可以大幅缓解 SDD 硬盘的空间不足的问题 留下没钱的泪水:(



