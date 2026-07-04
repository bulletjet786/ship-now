# Ship Now

**InsForge BaaS + 你的应用** 的一键部署模板。

## 快速开始

在**你的项目根目录**执行：

```bash
curl -fsSL https://raw.githubusercontent.com/bulletjet786/ship-now/main/install.sh | bash
```

脚本会交互式询问：
- **Deploy 目录名** — 默认为 `deploy`
- **项目名称** — 默认为 Git 根目录名（用于容器隔离）

完成后即可部署：

```bash
docker compose -f deploy/docker-compose.yml up -d
```

## 容器隔离

每台机器可部署多个项目，`COMPOSE_PROJECT_NAME` 自动隔离容器/卷/网络：

```
my-blog_insforge_1    my-shop_insforge_1
my-blog_postgres_1    my-shop_postgres_1
my-blog_backend_1     my-shop_backend_1
```

## 文档

详见 [deploy/AGENTS.md](deploy/AGENTS.md)。
