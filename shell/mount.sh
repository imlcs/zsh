#!/bin/bash

# ==============================================
# Ubuntu 自动挂载 2TB 以上硬盘脚本
# 功能：自动检测未分区的硬盘，格式化为 GPT + ext4/XFS，并挂载
# 使用方法：sudo ./mount.sh  <挂载目录>
# ==============================================

set -e  # 遇到错误立即退出

# --------------------------
# 用户可配置参数（按需修改）
# --------------------------

FS_TYPE="ext4"          # 文件系统类型（ext4 或 xfs）
AUTO_MOUNT=true         # 是否自动配置开机挂载（修改 /etc/fstab）

# --------------------------
# 检查参数 $1 是否存在
# --------------------------
if [ -z "$1" ]; then
    echo "错误：必须指定挂载目录参数！"
    echo "使用方法：sudo $0 <挂载目录>"
    exit 1
fi

MOUNT_DIR="$1"

# --------------------------
# 检查挂载目录是否已存在
# --------------------------
if [ -d "$MOUNT_DIR" ]; then
    # 检查该目录是否已经挂载了磁盘设备
    if mountpoint -q "$MOUNT_DIR"; then
        echo "错误：挂载目录 $MOUNT_DIR 已经挂载了磁盘设备，请换一个未使用的目录！"
        exit 1
    else
        echo "警告：挂载目录 $MOUNT_DIR 已存在，但未挂载设备，将继续使用该目录。"
    fi
fi
# --------------------------
# 检查 root 权限
# --------------------------
if [ "$(id -u)" -ne 0 ]; then
    echo "错误：请使用 sudo 运行此脚本！"
    exit 1
fi

# --------------------------
# 检查依赖工具
# --------------------------
for cmd in lsblk parted mkfs.$FS_TYPE blkid; do
    if ! command -v $cmd &> /dev/null; then
        echo "错误：未找到 $cmd 命令，请确保系统已安装相关工具！"
        exit 1
    fi
done

# --------------------------
# 查找未分区的磁盘
# --------------------------
echo "正在扫描可用的磁盘..."
DISK=$2

# --------------------------
# 确认操作（防止误操作）
# --------------------------
read -p "即将格式化 $DISK 为 $FS_TYPE 并挂载到 $MOUNT_DIR，所有数据将被清除！确认继续吗？[y/N] " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "操作已取消。"
    exit 0
fi

# --------------------------
# 创建分区和文件系统
# --------------------------
echo "正在创建 GPT 分区表..."
parted -s "$DISK" mklabel gpt
parted -s "$DISK" mkpart primary 0% 100%

PARTITION="${DISK}1"
echo "正在格式化 $PARTITION 为 $FS_TYPE..."
sleep 3
mkfs.$FS_TYPE "$PARTITION"

# --------------------------
# 挂载分区
# --------------------------
echo "正在创建挂载点 $MOUNT_DIR..."
mkdir -p "$MOUNT_DIR"
mount "$PARTITION" "$MOUNT_DIR"
echo "已挂载 $PARTITION 到 $MOUNT_DIR"

# --------------------------
# 配置开机自动挂载
# --------------------------
if [ "$AUTO_MOUNT" = true ]; then
    echo "正在配置开机自动挂载..."
    UUID=$(blkid -o value -s UUID "$PARTITION")
    if [ -z "$UUID" ]; then
        echo "错误：无法获取 $PARTITION 的 UUID！"
        exit 1
    fi

    FSTAB_ENTRY="UUID=$UUID $MOUNT_DIR $FS_TYPE defaults 0 0"
    if grep -q "$MOUNT_DIR" /etc/fstab; then
        echo "警告：$MOUNT_DIR 已在 /etc/fstab 中存在，跳过添加。"
    else
        echo "$FSTAB_ENTRY" | tee -a /etc/fstab > /dev/null
        echo "已添加 /etc/fstab 条目：$FSTAB_ENTRY"
    fi

    # 测试 fstab 配置是否正确
    if ! mount -a; then
        echo "错误：/etc/fstab 配置测试失败，请检查！"
        exit 1
    fi
fi

# --------------------------
# 完成
# --------------------------
echo "操作完成！"
df -h "$MOUNT_DIR"
exit 0
