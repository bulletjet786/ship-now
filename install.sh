#!/usr/bin/env bash
set -euo pipefail

# ╔══════════════════════════════════════════════════════════════════╗
# ║  Ship Now — 部署模板安装脚本                                     ║
# ║                                                                ║
# ║  在你的项目根目录执行：                                          ║
# ║    curl -fsSL https://raw.githubusercontent.com/                 ║
# ║      bulletjet786/ship-now/v1.0/install.sh | bash               ║
# ╚══════════════════════════════════════════════════════════════════╝

REPO="bulletjet786/ship-now"
TAG="${SHIP_NOW_TAG:-dev-v1.0}"

# ── 检测 ANSI 颜色支持 ─────────────────────────────────────────────
if [ -t 1 ]; then
  GREEN='\033[0;32m'
  CYAN='\033[0;36m'
  YELLOW='\033[1;33m'
  NC='\033[0m'
else
  GREEN=''; CYAN=''; YELLOW=''; NC=''
fi

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         Ship Now — 部署模板安装                  ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# ── 检查 Git 仓库 ──────────────────────────────────────────────────
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo -e "${YELLOW}⚠️  当前目录不是一个 Git 仓库。${NC}"
  echo "   Ship Now 推荐在 Git 仓库中安装。继续将使用目录名作为项目名。"
  echo ""
fi

# ── 交互：deploy 目录名 ────────────────────────────────────────────
DEFAULT_DEPLOY_DIR="deploy"
if (exec </dev/tty) 2>/dev/null; then
  read -r -p "Deploy 目录名 [${DEFAULT_DEPLOY_DIR}]: " DEPLOY_DIR </dev/tty
fi
DEPLOY_DIR=${DEPLOY_DIR:-$DEFAULT_DEPLOY_DIR}

# ── 检查 deploy 目录 ───────────────────────────────────────────────
if [ -d "$DEPLOY_DIR" ]; then
  echo -e "${YELLOW}⚠️  ${DEPLOY_DIR}/ 目录已存在。${NC}"
  if (exec </dev/tty) 2>/dev/null; then
    read -r -p "是否覆盖？(y/N): " CONFIRM </dev/tty
  fi
  if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "已取消。"
    exit 1
  fi
  rm -rf "$DEPLOY_DIR"
fi

# ── 交互：项目名 ───────────────────────────────────────────────────
DEFAULT_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || echo "$(pwd)")")
if (exec </dev/tty) 2>/dev/null; then
  read -r -p "项目名称 [${DEFAULT_NAME}]: " PROJECT_NAME </dev/tty
fi
PROJECT_NAME=${PROJECT_NAME:-$DEFAULT_NAME}
PROJECT_NAME=${PROJECT_NAME:-$DEFAULT_NAME}

echo ""
echo -e "  部署目录: ${GREEN}${DEPLOY_DIR}/${NC}"
echo -e "  项目名称: ${GREEN}${PROJECT_NAME}${NC}"
echo ""

# ── 下载模板 ───────────────────────────────────────────────────────
echo "↓ 下载 ship-now 模板..."
TMPDIR=$(mktemp -d)
curl -fsSL "https://github.com/${REPO}/archive/refs/tags/${TAG}.tar.gz" \
  -o "$TMPDIR/repo.tar.gz"

tar -xzf "$TMPDIR/repo.tar.gz" -C "$TMPDIR"
mv "$TMPDIR/ship-now-${TAG}/deploy" "$DEPLOY_DIR"
rm -rf "$TMPDIR"

echo -e "  已下载到 ${GREEN}${DEPLOY_DIR}/${NC}"
echo ""

# ── 替换项目名占位符 ──────────────────────────────────────────────
echo "🔧 配置项目..."
find "$DEPLOY_DIR" -type f -exec perl -pi -e "s/\\{\\{PROJECT_NAME\\}\\}/$PROJECT_NAME/g" {} +

# ── 生成密钥 ───────────────────────────────────────────────────────
JWT_SECRET=$(openssl rand -base64 32)
ENCRYPTION_KEY=$(openssl rand -base64 32)
POSTGRES_PASSWORD=$(openssl rand -base64 32)
ADMIN_PASSWORD=$(openssl rand -base64 32)

# ── 写入 .env ─────────────────────────────────────────────────────
cat > "$DEPLOY_DIR/.env" <<EOF
# ─── 密钥 ─────────────────────────────────────────────────────────
JWT_SECRET=${JWT_SECRET}
ENCRYPTION_KEY=${ENCRYPTION_KEY}

# ─── 管理员 ───────────────────────────────────────────────────────
ADMIN_EMAIL=admin@${PROJECT_NAME}.local
ADMIN_PASSWORD=${ADMIN_PASSWORD}

# ─── 数据库 ───────────────────────────────────────────────────────
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}

# ─── 地址 ─────────────────────────────────────────────────────────
API_BASE_URL=http://localhost:7130
VITE_API_BASE_URL=http://localhost:7130
APP_PORT=7130

# ─── Docker 项目名 ────────────────────────────────────────────────
COMPOSE_PROJECT_NAME=${PROJECT_NAME}
EOF

echo -e "  ${GREEN}.env${NC} 已生成"
echo ""

# ── 清理模板中的 setup.sh ─────────────────────────────────────────
rm -f "$DEPLOY_DIR/setup.sh"

# ── 完成 ───────────────────────────────────────────────────────────
echo -e "${GREEN}✅  Ship Now 安装完成！${NC}"
echo ""
echo "────────────────────────────────────────────"
echo "  项目结构:"
echo "    ./"
echo "    ├── ${DEPLOY_DIR}/"
echo "    │   ├── docker-compose.yml"
echo "    │   ├── .env"
echo "    │   └── AGENTS.md"
echo "    ├── backend/    ← 你的后端代码"
echo "    └── frontend/   ← 你的前端代码"
echo ""
echo "  部署:"
echo "    docker compose -f ${DEPLOY_DIR}/docker-compose.yml up -d"
echo "────────────────────────────────────────────"
echo ""
