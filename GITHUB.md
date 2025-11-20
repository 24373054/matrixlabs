# GitHub 仓库管理指南

## 📦 仓库信息

- **仓库地址**: https://github.com/24373054/matrixlabs
- **分支**: main
- **项目名称**: MatrixLab Exchange - Web3 Innovation Platform

## 🔄 常用Git命令

### 查看状态
```bash
cd /home/ubuntu/yz/Web3/网站test1
git status
```

### 拉取最新代码
```bash
git pull origin main
```

### 提交更改
```bash
# 1. 查看修改的文件
git status

# 2. 添加文件到暂存区
git add .                    # 添加所有文件
git add file1.js file2.css   # 添加指定文件

# 3. 提交更改
git commit -m "描述你的更改"

# 4. 推送到GitHub
git push origin main
```

### 查看提交历史
```bash
git log --oneline -10        # 查看最近10条提交
git log --graph --oneline    # 图形化显示
```

### 查看文件差异
```bash
git diff                     # 查看未暂存的更改
git diff --staged            # 查看已暂存的更改
git diff HEAD~1              # 与上一次提交比较
```

## 📝 提交规范

建议使用清晰的提交信息：

```bash
# 功能添加
git commit -m "feat: 添加新的交易功能"

# Bug修复
git commit -m "fix: 修复VPN检测CORS问题"

# 文档更新
git commit -m "docs: 更新README文档"

# 样式修改
git commit -m "style: 优化移动端布局"

# 性能优化
git commit -m "perf: 优化API响应速度"

# 重构代码
git commit -m "refactor: 重构VPN检测逻辑"
```

## 🌿 分支管理

### 创建新分支
```bash
# 创建并切换到新分支
git checkout -b feature/new-feature

# 或分两步
git branch feature/new-feature
git checkout feature/new-feature
```

### 切换分支
```bash
git checkout main            # 切换到main分支
git checkout develop         # 切换到develop分支
```

### 合并分支
```bash
# 切换到main分支
git checkout main

# 合并其他分支
git merge feature/new-feature

# 推送合并结果
git push origin main
```

### 删除分支
```bash
# 删除本地分支
git branch -d feature/old-feature

# 删除远程分支
git push origin --delete feature/old-feature
```

## 🔧 常见场景

### 场景1: 更新代码后部署
```bash
cd /home/ubuntu/yz/Web3/网站test1

# 1. 拉取最新代码
git pull origin main

# 2. 安装新依赖（如果有）
npm install

# 3. 重启应用
./restart.sh
```

### 场景2: 修改代码并提交
```bash
# 1. 修改文件
nano public/app.js

# 2. 查看修改
git diff

# 3. 提交更改
git add public/app.js
git commit -m "fix: 修复移动端显示问题"
git push origin main
```

### 场景3: 撤销未提交的更改
```bash
# 撤销单个文件的更改
git checkout -- file.js

# 撤销所有未暂存的更改
git checkout -- .

# 撤销已暂存但未提交的更改
git reset HEAD file.js
git checkout -- file.js
```

### 场景4: 回退到之前的版本
```bash
# 查看提交历史
git log --oneline

# 回退到指定提交（保留更改）
git reset --soft <commit-hash>

# 回退到指定提交（丢弃更改）
git reset --hard <commit-hash>

# 推送回退（慎用！）
git push origin main --force
```

## 🔐 GitHub认证

### 使用Personal Access Token (推荐)

1. 访问 GitHub Settings → Developer settings → Personal access tokens
2. 生成新token，勾选 `repo` 权限
3. 保存token（只显示一次）
4. 使用token作为密码：
   ```bash
   git push origin main
   # Username: 24373054
   # Password: <your-token>
   ```

### 配置Git凭证缓存
```bash
# 缓存15分钟
git config --global credential.helper cache

# 缓存1小时
git config --global credential.helper 'cache --timeout=3600'

# 永久存储（不安全）
git config --global credential.helper store
```

### 使用SSH密钥（更安全）
```bash
# 1. 生成SSH密钥
ssh-keygen -t ed25519 -C "your_email@example.com"

# 2. 查看公钥
cat ~/.ssh/id_ed25519.pub

# 3. 添加到GitHub: Settings → SSH and GPG keys → New SSH key

# 4. 测试连接
ssh -T git@github.com

# 5. 更改远程仓库URL
git remote set-url origin git@github.com:24373054/matrixlabs.git
```

## 📊 查看仓库信息

### 查看远程仓库
```bash
git remote -v
git remote show origin
```

### 查看分支
```bash
git branch                   # 本地分支
git branch -r                # 远程分支
git branch -a                # 所有分支
```

### 查看标签
```bash
git tag                      # 列出所有标签
git tag -a v1.0.0 -m "版本1.0.0"  # 创建标签
git push origin v1.0.0       # 推送标签
```

## 🚀 自动化部署

### 使用GitHub Actions

项目已包含 `.github/workflows/deploy.yml`，可以扩展为自动部署：

```yaml
# 示例：自动部署到服务器
name: Deploy to Production

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - name: Deploy to server
      uses: appleboy/ssh-action@master
      with:
        host: ${{ secrets.SERVER_HOST }}
        username: ${{ secrets.SERVER_USER }}
        key: ${{ secrets.SSH_PRIVATE_KEY }}
        script: |
          cd /home/ubuntu/yz/Web3/网站test1
          git pull origin main
          npm install
          ./restart.sh
```

### 设置GitHub Secrets

在仓库设置中添加：
- `SERVER_HOST`: 服务器IP
- `SERVER_USER`: SSH用户名
- `SSH_PRIVATE_KEY`: SSH私钥

## 📦 .gitignore 说明

已配置忽略以下文件：
- `node_modules/` - 依赖包
- `*.log` - 日志文件
- `.app.pid` - 进程ID文件
- `*.pem`, `*.key` - SSL证书和私钥
- `.env` - 环境变量文件

## 🔍 故障排除

### 推送被拒绝
```bash
# 先拉取远程更改
git pull origin main --rebase

# 解决冲突后
git add .
git rebase --continue

# 推送
git push origin main
```

### 合并冲突
```bash
# 1. 拉取时出现冲突
git pull origin main

# 2. 手动编辑冲突文件，查找 <<<<<<< 标记

# 3. 解决后标记为已解决
git add <conflicted-file>

# 4. 完成合并
git commit -m "merge: 解决合并冲突"
```

### 误提交敏感信息
```bash
# 从历史中删除文件
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch path/to/file" \
  --prune-empty --tag-name-filter cat -- --all

# 强制推送
git push origin main --force
```

## 📚 有用的Git别名

添加到 `~/.gitconfig`：

```ini
[alias]
    st = status
    co = checkout
    br = branch
    ci = commit
    unstage = reset HEAD --
    last = log -1 HEAD
    visual = log --graph --oneline --all
    amend = commit --amend --no-edit
```

使用：
```bash
git st              # 等同于 git status
git co main         # 等同于 git checkout main
git visual          # 图形化查看历史
```

## 🔗 相关链接

- **GitHub仓库**: https://github.com/24373054/matrixlabs
- **项目网站**: https://exchange.matrixlab.work
- **开发者主页**: https://24373054.github.io/
- **实验室网站**: https://matrixlab.work

## 📞 需要帮助？

```bash
# Git帮助
git help <command>
git <command> --help

# 示例
git help commit
git push --help
```

---

**快速参考**：
- 提交: `git add . && git commit -m "message" && git push`
- 更新: `git pull && npm install && ./restart.sh`
- 状态: `git status`
- 历史: `git log --oneline`
