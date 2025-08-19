#!/bin/bash

# 运维知识库部署脚本
# 作者: freemankevin
# 版本: 1.0.0
# 描述: 本地开发和部署的便捷脚本

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目信息
PROJECT_NAME="ops-knowledge-base"
REPO_URL="https://github.com/freemankevin/ops-knowledge-base"
DOCS_URL="https://freemankevin.github.io/ops-knowledge-base"

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 显示帮助信息
show_help() {
    cat << EOF
运维知识库部署脚本

用法: $0 [选项]

选项:
    -h, --help      显示此帮助信息
    -i, --install   安装依赖
    -s, --serve     启动本地开发服务器
    -b, --build     构建静态站点
    -d, --deploy    部署到 GitHub Pages
    -c, --clean     清理构建文件
    -u, --update    更新依赖包
    --init          初始化项目环境

示例:
    $0 --install        # 安装依赖
    $0 --serve          # 启动开发服务器
    $0 --build          # 构建项目
    $0 --deploy         # 部署到 GitHub Pages
    $0 --clean          # 清理构建文件

EOF
}

# 检查命令是否存在
check_command() {
    if ! command -v $1 &> /dev/null; then
        log_error "$1 未安装，请先安装 $1"
        exit 1
    fi
}

# 检查 Python 环境
check_python() {
    log_info "检查 Python 环境..."
    
    if ! command -v python3 &> /dev/null && ! command -v python &> /dev/null; then
        log_error "Python 未安装，请先安装 Python 3.8+"
        exit 1
    fi
    
    # 获取 Python 版本
    if command -v python3 &> /dev/null; then
        PYTHON_CMD="python3"
        PIP_CMD="pip3"
    else
        PYTHON_CMD="python"
        PIP_CMD="pip"
    fi
    
    PYTHON_VERSION=$($PYTHON_CMD --version 2>&1 | cut -d' ' -f2)
    log_info "使用 Python 版本: $PYTHON_VERSION"
}

# 检查 Git 环境
check_git() {
    log_info "检查 Git 环境..."
    check_command "git"
    
    # 检查是否在 Git 仓库中
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "当前目录不是 Git 仓库"
        exit 1
    fi
    
    # 检查远程仓库
    if ! git remote get-url origin > /dev/null 2>&1; then
        log_warning "未设置 origin 远程仓库"
    fi
}

# 安装依赖
install_deps() {
    log_info "安装项目依赖..."
    check_python
    
    if [ -f "requirements.txt" ]; then
        $PIP_CMD install -r requirements.txt
        log_success "依赖安装完成"
    else
        log_error "requirements.txt 文件不存在"
        exit 1
    fi
}

# 启动开发服务器
serve_dev() {
    log_info "启动本地开发服务器..."
    check_python
    
    if ! command -v mkdocs &> /dev/null; then
        log_warning "MkDocs 未安装，正在安装依赖..."
        install_deps
    fi
    
    log_info "服务器启动中... 访问地址: http://127.0.0.1:8000"
    mkdocs serve --dev-addr=127.0.0.1:8000
}

# 构建静态站点
build_site() {
    log_info "构建静态站点..."
    check_python
    
    if ! command -v mkdocs &> /dev/null; then
        log_warning "MkDocs 未安装，正在安装依赖..."
        install_deps
    fi
    
    # 清理旧的构建文件
    if [ -d "site" ]; then
        rm -rf site/
        log_info "清理旧的构建文件"
    fi
    
    # 构建站点
    mkdocs build --clean --strict
    log_success "站点构建完成，输出目录: site/"
}

# 部署到 GitHub Pages
deploy_site() {
    log_info "部署到 GitHub Pages..."
    check_python
    check_git
    
    if ! command -v mkdocs &> /dev/null; then
        log_warning "MkDocs 未安装，正在安装依赖..."
        install_deps
    fi
    
    # 检查是否有未提交的更改
    if ! git diff --quiet; then
        log_warning "有未提交的更改，建议先提交"
        read -p "是否继续部署? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "取消部署"
            exit 0
        fi
    fi
    
    # 使用 mkdocs gh-deploy 部署
    mkdocs gh-deploy --clean --message "Deploy {sha} with MkDocs version {version}"
    log_success "部署完成！"
    log_info "访问地址: $DOCS_URL"
}

# 清理构建文件
clean_build() {
    log_info "清理构建文件..."
    
    if [ -d "site" ]; then
        rm -rf site/
        log_info "删除 site/ 目录"
    fi
    
    if [ -d ".cache" ]; then
        rm -rf .cache/
        log_info "删除 .cache/ 目录"
    fi
    
    # 清理 Python 缓存
    find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
    find . -type f -name "*.pyc" -delete 2>/dev/null || true
    
    log_success "清理完成"
}

# 更新依赖
update_deps() {
    log_info "更新项目依赖..."
    check_python
    
    if [ -f "requirements.txt" ]; then
        $PIP_CMD install --upgrade -r requirements.txt
        log_success "依赖更新完成"
    else
        log_error "requirements.txt 文件不存在"
        exit 1
    fi
}

# 初始化项目环境
init_project() {
    log_info "初始化项目环境..."
    
    # 检查环境
    check_python
    check_git
    
    # 安装依赖
    install_deps
    
    # 创建必要的目录结构
    mkdir -p docs/assets/images
    mkdir -p docs/assets/stylesheets
    
    # 如果不存在 index.md，创建一个简单的
    if [ ! -f "docs/index.md" ]; then
        cat > docs/index.md << 'EOF'
# 运维知识库

欢迎来到运维知识库！

## 快速开始

这里是一个基于 MkDocs Material 构建的运维知识库，包含以下内容：

- 基础环境配置
- 容器化部署
- 应用服务管理
- 数据存储方案
- 监控告警系统
- 安全防护措施
- 故障处理流程
- 最佳实践分享

## 使用方法

1. 本地开发：`./deploy.sh --serve`
2. 构建站点：`./deploy.sh --build`
3. 部署上线：`./deploy.sh --deploy`

---

开始你的运维之旅吧！
EOF
        log_info "创建默认 index.md"
    fi
    
    log_success "项目环境初始化完成"
    log_info "运行 './deploy.sh --serve' 启动开发服务器"
}

# 主函数
main() {
    case "${1:-}" in
        -h|--help)
            show_help
            ;;
        -i|--install)
            install_deps
            ;;
        -s|--serve)
            serve_dev
            ;;
        -b|--build)
            build_site
            ;;
        -d|--deploy)
            deploy_site
            ;;
        -c|--clean)
            clean_build
            ;;
        -u|--update)
            update_deps
            ;;
        --init)
            init_project
            ;;
        "")
            log_error "缺少参数，使用 --help 查看帮助"
            exit 1
            ;;
        *)
            log_error "未知选项: $1"
            log_info "使用 --help 查看帮助"
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@"