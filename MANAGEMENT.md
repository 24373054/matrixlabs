# MatrixLab Exchange - 管理脚本使用指南

## 🚀 快速开始

所有管理脚本都在项目根目录下，可以直接运行：

```bash
cd /home/ubuntu/yz/Web3/网站test1
```

## 📋 可用命令

### 启动应用
```bash
./start.sh
```

**功能：**
- 检查应用是否已在运行（避免重复启动）
- 检查端口3104是否被占用
- 后台启动应用
- 保存进程PID到文件
- 输出日志到 `app.log`

**输出示例：**
```
🚀 Starting MatrixLab Exchange...
   Project: /home/ubuntu/yz/Web3/网站test1
   Port: 3104
   Log: /home/ubuntu/yz/Web3/网站test1/app.log

✅ Application started successfully!
   PID: 12345
   Local: http://localhost:3104
   Public: https://exchange.matrixlab.work
```

---

### 停止应用
```bash
./stop.sh
```

**功能：**
- 读取PID文件找到进程
- 验证进程确实是我们的应用（不会误杀其他进程）
- 先尝试优雅关闭（SIGTERM）
- 如果5秒内未关闭，强制终止（SIGKILL）
- 清理PID文件

**安全特性：**
- ✅ 只停止本项目的进程
- ✅ 验证进程命令包含 `server.js`
- ✅ 不会影响其他Node.js进程
- ✅ 不会影响其他端口的应用

**输出示例：**
```
🛑 Stopping MatrixLab Exchange...
   PID: 12345
   Process: node server.js

✅ Application stopped successfully
```

---

### 查看状态
```bash
./status.sh
```

**功能：**
- 检查PID文件状态
- 检查端口3104占用情况
- 测试本地HTTP连接
- 测试HTTPS域名访问
- 检查Nginx状态
- 显示最近5行日志

**输出示例：**
```
==========================================
MatrixLab Exchange - Status Check
==========================================

📄 PID File: /home/ubuntu/yz/Web3/网站test1/.app.pid
   PID: 12345
   Status: ✅ Running
   Command: node server.js
   Resources: 0.1 5.2 00:15:30

🔌 Port 3104:
   Status: ✅ In Use
   PID: 12345
   Process: node server.js

🌐 Local Connection (http://localhost:3104):
   Status: ✅ Responding
   HTTP Code: 200

🔒 HTTPS (https://exchange.matrixlab.work):
   Status: ✅ Responding
   HTTP Code: 200

🔧 Nginx:
   Status: ✅ Running

📋 Recent Logs (last 5 lines):
----------------------------------------
MatrixLab Exchange Platform running on port 3104
Access at: http://localhost:3104
----------------------------------------
```

---

### 重启应用
```bash
./restart.sh
```

**功能：**
- 先停止应用
- 等待2秒
- 重新启动应用

**使用场景：**
- 更新代码后
- 修改配置后
- 应用出现问题时

---

## 🔍 常见使用场景

### 场景1：首次启动
```bash
cd /home/ubuntu/yz/Web3/网站test1
./start.sh
```

### 场景2：检查是否运行
```bash
./status.sh
```

### 场景3：更新代码后重启
```bash
git pull  # 或其他更新方式
./restart.sh
```

### 场景4：停止应用
```bash
./stop.sh
```

### 场景5：查看实时日志
```bash
tail -f app.log
```

### 场景6：清理并重启
```bash
./stop.sh
rm -f app.log  # 可选：清理旧日志
./start.sh
```

---

## 🛡️ 安全特性

### 1. 进程隔离
- 使用PID文件精确跟踪进程
- 验证进程命令确保是正确的应用
- 不会误杀其他Node.js进程

### 2. 端口检查
- 启动前检查端口是否被占用
- 避免端口冲突

### 3. 重复启动保护
- 检测应用是否已在运行
- 防止重复启动导致的问题

### 4. 优雅关闭
- 先尝试SIGTERM信号
- 给应用5秒时间清理资源
- 必要时才使用SIGKILL强制终止

---

## 📁 相关文件

### PID文件
- **位置**: `/home/ubuntu/yz/Web3/网站test1/.app.pid`
- **内容**: 应用进程的PID
- **用途**: 跟踪和管理进程
- **注意**: 不要手动编辑或删除（除非应用异常）

### 日志文件
- **位置**: `/home/ubuntu/yz/Web3/网站test1/app.log`
- **内容**: 应用的标准输出和错误输出
- **查看**: `tail -f app.log`
- **清理**: 可以安全删除，下次启动会重新创建

---

## 🔧 故障排除

### 问题1：启动失败，提示端口被占用
```bash
# 查看谁在使用端口3104
sudo lsof -i :3104

# 如果是其他进程，可以：
# 1. 停止那个进程
# 2. 或者修改本应用使用其他端口（如3105）
```

### 问题2：停止失败，进程仍在运行
```bash
# 查找进程
ps aux | grep "node server.js"

# 手动强制终止（替换PID）
kill -9 [PID]

# 清理PID文件
rm -f .app.pid
```

### 问题3：状态显示不一致
```bash
# 清理状态
./stop.sh
rm -f .app.pid

# 重新启动
./start.sh
```

### 问题4：应用启动但无法访问
```bash
# 检查应用日志
tail -50 app.log

# 检查端口
curl http://localhost:3104

# 检查Nginx
sudo systemctl status nginx
sudo nginx -t
```

---

## 🎯 最佳实践

### 1. 定期检查状态
```bash
# 添加到crontab，每小时检查一次
0 * * * * cd /home/ubuntu/yz/Web3/网站test1 && ./status.sh >> status.log 2>&1
```

### 2. 日志轮转
```bash
# 定期清理大日志文件
if [ -f app.log ] && [ $(stat -f%z app.log) -gt 10485760 ]; then
    mv app.log app.log.old
    ./restart.sh
fi
```

### 3. 开机自启动
如果需要开机自启动，使用systemd：
```bash
sudo ./setup-systemd.sh
```

### 4. 监控脚本
创建简单的监控：
```bash
#!/bin/bash
# monitor.sh
while true; do
    if ! ./status.sh | grep -q "Status: ✅ Running"; then
        echo "Application down, restarting..."
        ./start.sh
    fi
    sleep 60
done
```

---

## 📞 命令速查

| 命令 | 功能 | 使用场景 |
|------|------|----------|
| `./start.sh` | 启动应用 | 首次启动、停止后重启 |
| `./stop.sh` | 停止应用 | 维护、更新前 |
| `./restart.sh` | 重启应用 | 更新代码、修改配置后 |
| `./status.sh` | 查看状态 | 检查运行状态 |
| `tail -f app.log` | 实时日志 | 调试、监控 |
| `cat .app.pid` | 查看PID | 手动管理进程 |

---

## ⚙️ 高级用法

### 使用不同端口启动
```bash
# 修改 server.js 或使用环境变量
PORT=3105 ./start.sh
```

### 后台运行并脱离终端
脚本已经使用 `nohup`，可以安全关闭终端

### 与systemd配合使用
```bash
# 如果已安装systemd服务
sudo systemctl start matrixlab-exchange   # 使用systemd启动
./stop.sh                                  # 使用脚本停止

# 建议：选择一种方式，不要混用
```

---

## 📝 注意事项

1. **不要同时使用多种启动方式**
   - 选择脚本或systemd，不要混用
   
2. **权限问题**
   - 脚本需要执行权限：`chmod +x *.sh`
   - 不需要root权限运行
   
3. **端口冲突**
   - 确保3104端口未被其他应用占用
   - 或修改为3105端口
   
4. **日志管理**
   - 定期检查日志文件大小
   - 必要时清理或轮转
   
5. **进程管理**
   - 不要手动删除PID文件（除非应用异常）
   - 使用脚本管理，不要直接kill进程

---

**快速帮助**: 运行 `./status.sh` 查看当前状态和可用命令
