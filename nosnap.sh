#!/bin/bash

# ========== 颜色定义 ==========
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
DIM='\033[2m'
RESET='\033[0m'

# ========== 辅助函数 ==========
info()    { echo -e "${CYAN}ℹ️  $1${RESET}"; }
success() { echo -e "${GREEN}✅ $1${RESET}"; }
warn()    { echo -e "${YELLOW}⚠️  $1${RESET}"; }
error()   { echo -e "${RED}❌ $1${RESET}"; }
step()    { echo -e "\n${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; \
            echo -e "${WHITE}📌 [$1/6] $2${RESET}"; \
            echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; }

# ========== Banner ==========
echo ""
echo -e "${RED}    _   __     _____                   ${RESET}"
echo -e "${RED}   / | / /___ / ___/____  ____ _____   ${RESET}"
echo -e "${YELLOW}  /  |/ / __ \\\\\\__ \\/ __ \\/ __ \`/ __ \\  ${RESET}"
echo -e "${GREEN} / /|  / /_/ /__/ / / / / /_/ / /_/ /  ${RESET}"
echo -e "${CYAN}/_/ |_/\\____/____/_/ /_/\\__,_/ .___/   ${RESET}"
echo -e "${BLUE}                           /_/         ${RESET}"
echo ""
echo -e "${DIM}  🚫 Ubuntu你老是惦记着你那snap干啥？${RESET}"
echo -e "${DIM}  🧹 一键清除 Snap 全家桶${RESET}"
echo ""

# ========== 权限检查 ==========
if [ "$EUID" -ne 0 ]; then
  error "请使用 ${WHITE}sudo${RED} 或 ${WHITE}root${RED} 用户运行此脚本！"
  echo -e "  ${DIM}👉 试试: ${WHITE}sudo ./nosnap.sh${RESET}"
  exit 1
fi

# ========== 确认操作 ==========
echo -e "${YELLOW}🤔 即将从系统中完全移除 Snap 及其所有软件包。${RESET}"
echo -e "${DIM}   此操作不可逆，请确认你已备份重要数据。${RESET}"
echo ""
read -p "$(echo -e "${WHITE}👉 确认继续？(y/N): ${RESET}")" confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  warn "操作已取消，Snap 暂时逃过一劫 🏃💨"
  exit 0
fi

echo ""
echo -e "${GREEN}🔥 开始清理 Snap 宇宙！${RESET}"
echo ""

# ========== Step 1: 计算空间占用 ==========
step 1 "🔍 扫描 Snap 占用空间"

if [ -d /var/lib/snapd ]; then
  SNAP_SIZE=$(du -sh /var/lib/snapd 2>/dev/null | cut -f1)
  SNAP_COUNT=$(snap list 2>/dev/null | tail -n +2 | wc -l)
  info "检测到 ${WHITE}${SNAP_COUNT}${CYAN} 个 Snap 软件包"
  info "Snap 相关文件占用空间: ${WHITE}${SNAP_SIZE}${RESET}"
else
  SNAP_SIZE="0"
  warn "未检测到 Snap 安装目录，可能已经被清理过了 🤷"
fi

# ========== Step 2: 停止服务 ==========
step 2 "🛑 停止 Snap 服务"

for service in snapd.service snapd.socket snapd.seeded.service; do
  if systemctl is-active --quiet "$service" 2>/dev/null; then
    systemctl stop "$service" && success "已停止 ${WHITE}${service}${RESET}" || warn "停止 ${service} 失败"
  else
    echo -e "  ${DIM}⏭️  ${service} 未运行，跳过${RESET}"
  fi
done

for service in snapd.service snapd.socket snapd.seeded.service; do
  if systemctl is-enabled --quiet "$service" 2>/dev/null; then
    systemctl disable "$service" 2>/dev/null && success "已禁用 ${WHITE}${service}${RESET}"
  fi
done

# ========== Step 3: 卸载 Snap 包 ==========
step 3 "📦 卸载所有 Snap 软件包"

if command -v snap &>/dev/null && [ "$(snap list 2>/dev/null | wc -l)" -gt 0 ]; then
  info "正在按依赖顺序逐一卸载..."
  
  # 先卸载非核心包
  while [ "$(snap list 2>/dev/null | wc -l)" -gt 0 ]; do
    for sn in $(snap list 2>/dev/null | awk '!/^Name|^core/ {print $1}'); do
      echo -e "  ${RED}🗑️  正在移除: ${WHITE}${sn}${RESET}"
      snap remove --purge "$sn" 2>/dev/null
    done
    # 最后处理核心包
    for sn in $(snap list 2>/dev/null | awk '!/^Name/ {print $1}'); do
      echo -e "  ${RED}🗑️  正在移除核心包: ${WHITE}${sn}${RESET}"
      snap remove --purge "$sn" 2>/dev/null
    done
  done
  
  success "所有 Snap 软件包已卸载 🎉"
else
  echo -e "  ${DIM}⏭️  没有找到已安装的 Snap 包，跳过${RESET}"
fi

# ========== Step 4: 卸载 snapd ==========
step 4 "💀 卸载 snapd 本体"

info "正在从系统中移除 snapd..."
apt purge -y snapd gnome-software-plugin-snap 2>/dev/null
apt autoremove -y 2>/dev/null

if ! command -v snap &>/dev/null; then
  success "snapd 已从系统中彻底移除 💀"
else
  warn "snapd 可能未完全移除，请手动检查"
fi

# ========== Step 5: 清理残留 ==========
step 5 "🧹 清理残留文件"

DIRS_TO_REMOVE=(
  "$HOME/snap"
  "/var/cache/snapd/"
  "/var/snap"
  "/var/lib/snapd"
  "/usr/lib/snapd"
)

for dir in "${DIRS_TO_REMOVE[@]}"; do
  if [ -d "$dir" ] || [ -e "$dir" ]; then
    rm -rf "$dir"
    success "已删除 ${WHITE}${dir}${RESET} 💥"
  else
    echo -e "  ${DIM}⏭️  ${dir} 不存在，跳过${RESET}"
  fi
done

# ========== Step 6: APT 封禁 ==========
step 6 "🔒 配置 APT 策略封禁 snapd"

info "正在写入 APT Pin 策略..."
cat <<EOF > /etc/apt/preferences.d/nosnap.pref
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF

if [ -f /etc/apt/preferences.d/nosnap.pref ]; then
  success "APT 封禁策略已就位，snapd 永世不得翻身 🔒"
else
  error "写入 APT 策略失败，请手动配置"
fi

# ========== 完成 ==========
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GREEN}  🎊 清理完成！Snap 已从你的系统中彻底消失！${RESET}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "  ${CYAN}💾 释放磁盘空间: ${WHITE}~${SNAP_SIZE}${RESET}"
echo -e "  ${CYAN}🔇 已清除 /dev/loop 设备挂载${RESET}"
echo -e "  ${CYAN}🔒 已锁定 APT，snapd 不会再自动回来${RESET}"
echo -e "  ${CYAN}🧼 系统已恢复清爽${RESET}"
echo ""
echo -e "  ${DIM}🐧 享受纯净的 Linux 体验吧！${RESET}"
echo -e "  ${DIM}   — Ubuntu你老是惦记着你那snap干啥？${RESET}"
echo ""