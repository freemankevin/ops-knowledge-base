# Ops Knowledge Base

## 项目介绍

ops-knowledge-base 是一个基于 MkDocs 构建的文档项目，用于收集和分享运维相关的知识、经验和工具。


## 🚀 快速开始

### 本地预览

```bash
# 1. 克隆仓库
git clone https://github.com/freemankevin/ops-knowledge-base.git
cd ops-knowledge-base

# 2. 安装依赖
bash scripts/deploy.sh --install

# 3. 启动本地服务
bash scripts/deploy.sh --serve
```

访问 [http://127.0.0.1:8000](http://127.0.0.1:8000) 预览效果。

### 部署脚本使用

```bash
# 安装依赖
bash scripts/deploy.sh --install

# 启动开发服务器
bash scripts/deploy.sh --serve

# 构建静态站点
bash scripts/deploy.sh --build

# 部署到 GitHub Pages
bash scripts/deploy.sh --deploy

# 清理构建文件
bash scripts/deploy.sh --clean

# 查看帮助
bash scripts/deploy.sh --help
```

## 🔧 技术栈

- **文档生成**：[MkDocs](https://www.mkdocs.org/)
- **主题框架**：[Material for MkDocs](https://squidfunk.github.io/mkdocs-material/)
- **语法扩展**：[PyMdown Extensions](https://facelessuser.github.io/pymdown-extensions/)
- **自动部署**：[GitHub Actions](https://github.com/features/actions)
- **托管平台**：[GitHub Pages](https://pages.github.com/)

## 🤝 贡献指南

我们欢迎任何形式的贡献！

1. **Fork** 本仓库
2. 创建特性分支 (`git checkout -b feature/新功能`)
3. 提交更改 (`git commit -m '添加新功能'`)
4. 推送到分支 (`git push origin feature/新功能`)
5. 创建 **Pull Request**

## 📝 更新日志

查看 [更新日志](changelog.md) 了解版本变化。

## 📄 许可证

本项目采用 [MIT 许可证](https://github.com/freemankevin/ops-knowledge-base/blob/main/LICENSE)。

## 📞 联系方式

- **作者**：freemankevin
- **项目地址**：[https://github.com/freemankevin/ops-knowledge-base](https://github.com/freemankevin/ops-knowledge-base)
- **在线文档**：[https://freemankevin.github.io/ops-knowledge-base](https://freemankevin.github.io/ops-knowledge-base)

---

**Happy Coding! 🎉**