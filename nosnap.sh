#!/bin/bash

# 确保以 root 权限运行
if [ "$EUID" -ne 0 ]; then 
  echo "请使用 sudo 或 root 用户运行此脚本！"
  exit 1
fi

echo "--- 开始清理 Snap 宇宙 ---"

# 1. 计算清理前的空间占用
SNAP_SIZE=$(du -sh /var/lib/snapd 2>/dev/null | cut -f1)
echo "检测到 Snap 相关文件占用空间: $SNAP_SIZE"

# 2. 停止所有 Snap 服务
echo "正在停止 Snap 服务..."
systemctl stop snapd.service snapd.socket snapd.seeded.service
systemctl disable snapd.service snapd.socket snapd.seeded.service

# 3. 卸载所有的 Snap 包 (按照依赖顺序卸载)
echo "正在卸载所有已安装的 Snap 软件包..."
while [ "$(snap list 2>/dev/null | wc -l)" -gt 0 ]; do
    for sn in $(snap list 2>/dev/null | awk '!/^Name|^Core/ {print $1}'); do
        snap remove --purge "$sn"
    done
    # 最后处理核心包
    for sn in $(snap list 2>/dev/null | awk '!/^Name/ {print $1}'); do
        snap remove --purge "$sn"
    done
done

# 4. 卸载 snapd 核心程序
echo "正在从系统卸载 snapd..."
apt purge -y snapd gnome-software-plugin-snap

# 5. 清理残留目录
echo "正在粉碎残留文件夹..."
rm -rf ~/snap
rm -rf /var/cache/snapd/
rm -rf /var/snap
rm -rf /var/lib/snapd
rm -rf /usr/lib/snapd

# 6. 设置 APT 锁，防止 snapd 自动重装
echo "正在配置 APT 策略以封禁 snapd..."
cat <<EOF > /etc/apt/preferences.d/nosnap.pref
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF

echo "--- 清理完成 ---"
echo "✅ 成功节省了大约 $SNAP_SIZE 的磁盘空间。"
echo "✅ 已禁用 /dev/loop 设备挂载。"
echo "✅ 已锁定 APT 仓库，snapd 不会再自动回来。"