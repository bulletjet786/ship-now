# Ship Now

部署模板：**InsForge BaaS** + 用户自定义应用。

## 架构

```
         ┌──────────────────┐
         │    frontend      │  App Layer
         │   (前端/Nginx)   │
         └─────┬────────┬───┘
               │        │
     ┌─────────▼──┐ ┌──▼──────────┐
     │  backend   │ │  insforge   │
     │ (后端服务) │ │  (主应用)   │
     └─────┬──────┘ └────┬────────┘
           │             │
     ┌─────▼──────┐ ┌───▼──────────┐
     │ postgrest  │ │    deno      │  BaaS Layer
     │ (REST API) │ │ (边缘运行时)  │
     └─────┬──────┘ └───┬──────────┘
           └──────┬─────┘
              ┌───▼─────┐
              │ postgres│
              │ (数据库) │
              └─────────┘
```

## 服务

### BaaS（固定，无需修改）

| 服务 | 镜像 |
|------|------|
| `postgres` | `crpi-trm32rse0qhwf009.cn-shanghai.personal.cr.aliyuncs.com/insforge/postgres-all:latest` |
| `postgrest` | `crpi-trm32rse0qhwf009.cn-shanghai.personal.cr.aliyuncs.com/insforge/postgrest:v12.2.12` |
| `insforge` | `crpi-trm32rse0qhwf009.cn-shanghai.personal.cr.aliyuncs.com/insforge/insforge-oss:${INSFORGE_VERSION:-v1.5.0}` |
| `deno` | `crpi-trm32rse0qhwf009.cn-shanghai.personal.cr.aliyuncs.com/insforge/deno-runtime:latest` |

### App（示例，按需修改）

| 服务 | 默认构建路径 |
|------|-------------|
| `backend` | `../backend` |
| `frontend` | `../frontend` |

## 容器名

项目名通过 `COMPOSE_PROJECT_NAME` 隔离：

```
{project}_postgres_1
{project}_postgrest_1
{project}_insforge_1
{project}_deno_1
{project}_backend_1
{project}_frontend_1
```

## 环境变量

`.env` 由 `install.sh` 自动生成，位于 `deploy/.env`。

### 密钥（自动生成）

- `JWT_SECRET` — JWT 签名
- `ENCRYPTION_KEY` — 数据加密
- `POSTGRES_PASSWORD` — 数据库密码
- `ADMIN_EMAIL` — 管理员邮箱
- `ADMIN_PASSWORD` — 管理员密码

### 可选

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `COMPOSE_PROJECT_NAME` | `{project_name}` | 容器/卷/网络前缀 |
