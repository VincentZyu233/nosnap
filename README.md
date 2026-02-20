![nosnap](https://socialify.git.ci/VincentZyu233/nosnap/image?description=1&font=Jost&forks=1&issues=1&language=1&logo=https%3A%2F%2Favatars.githubusercontent.com%2Fu%2F142771491%3Fv%3D4&name=1&owner=1&pulls=1&stargazers=1&theme=Auto)
# 🚫 NoSnap

> **Ubuntu你老是惦记着你那snap干啥？**

一键清除 Ubuntu 系统中的 Snap 全家桶，还你一个干净清爽的 Linux 环境。

---

## 🤔 为什么要用这个？

曾几何时，Ubuntu 是多少人入门 Linux 的第一选择——轻量、优雅、开箱即用。

然而不知从何时起，Canonical 开始疯狂推销自家的 Snap 包管理器，把它塞进系统的每一个角落：

- 🐌 **启动速度感人**：一个计算器打开要 5 秒，你以为你在用 Windows 11？
- 💽 **`/dev/loop` 洗版**：执行一下 `lsblk`，满屏的 loop 设备，仿佛在数羊。
- 🎃 **磁盘空间黑洞**：每个 Snap 包都自带完整运行时，500MB 起步，Ubuntu 这是在致敬 Windows 的体积艺术。
- 🔒 **强制自动更新**：说好的 Linux 自由呢？用户的选择权被 Canonical 吃了？
- 🧟 **杀不死的 snapd**：你卸了它，它自己又装回来，比牛皮癣还顽强。

Ubuntu 越来越臃肿，再这么搞下去怕是要被开除 Linux 籍了。别的发行版都在努力做减法，就 Ubuntu 在往系统里疯狂塞私货，`apt install chromium` 装回来一个 Snap 版——这跟挂羊头卖狗肉有什么区别？

所以，**NoSnap** 来了。一个脚本，一行命令，把 Snap 连根拔起，永绝后患。

---

## ✨ 功能

- ✅ 停止并禁用所有 Snap 相关服务
- ✅ 按依赖顺序卸载全部 Snap 软件包
- ✅ 彻底卸载 `snapd` 本体
- ✅ 清理所有 Snap 残留目录（`~/snap`、`/var/lib/snapd` 等）
- ✅ 配置 APT 策略锁定，**防止 `snapd` 死灰复燃**
- ✅ 显示释放的磁盘空间，让你直观感受自由的味道

---

## 🚀 使用方法

```bash
# 下载脚本
git clone https://github.com/VincentZyu233/nosnap
# 或者去gitee下载
git clone https://gitee.com/vincent-zyu/nosnap
cd nosnap

# 赋予执行权限
chmod +x nosnap.sh

# 以 root 权限运行
sudo ./nosnap.sh
```

就这么简单。一杯咖啡的时间都不用，Snap 就从你的系统里彻底消失了。

---

## ⚠️ 注意事项

- 请确保在 **Ubuntu / 基于 Ubuntu 的发行版** 上运行（Debian 用户一般没这烦恼，毕竟人家没被 Canonical 绑架）。
- 如果你正在使用 Snap 版的 Firefox 或其他软件，运行脚本前请先通过 APT 或 PPA 安装替代版本。
- 脚本需要 **root 权限**，毕竟要做手术嘛。

---

## 📋 脚本做了什么？

| 步骤 | 操作 |
|------|------|
| 1 | 计算当前 Snap 占用的磁盘空间 |
| 2 | 停止并禁用 `snapd` 相关服务 |
| 3 | 逐一卸载所有 Snap 包（先普通包，再核心包） |
| 4 | `apt purge` 卸载 `snapd` 本体 |
| 5 | 删除所有 Snap 残留目录 |
| 6 | 写入 APT Pin 策略，永久封禁 `snapd` 安装 |

---

## 🗣️ 写在最后

Linux 的灵魂是**自由与选择**。如果一个发行版开始替用户做决定、往系统里强塞谁都不想要的东西，那它离社区的心就越来越远了。

Snap 本身不是原罪，**强制推广才是。**

希望 Canonical 有一天能想明白这个道理。在那之前——

```
sudo ./nosnap.sh
```

---

## 📜 License

MIT — 自由地使用，就像 Linux 本该有的样子。
