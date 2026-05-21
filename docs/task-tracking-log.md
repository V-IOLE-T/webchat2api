# webchat2api 任务跟踪日志

## 任务目标

将项目正式统一命名为 `webchat2api`，补齐可交付给开发者和运维人员的部署、运行、维护技术文档，并保证 Docker CLI proxy 部署路径可直接执行。

## 当前状态

| 项目 | 状态 | 说明 |
| --- | --- | --- |
| 项目名称 | 已完成 | 元信息、README、Docker、Compose、管理端标题和 API 文档标题统一为 `webchat2api`。 |
| 版本号 | 已完成 | `VERSION`、`pyproject.toml`、`web/package.json`、`uv.lock` 更新为 `0.0.1`。 |
| 默认端口 | 已完成 | Docker、Compose、本地入口和前端开发 API 默认使用 `83`。 |
| 默认登录密钥 | 已完成 | 默认登录密钥为 `admin`，支持 `LOGIN_SECRET` 覆盖。 |
| 旧环境变量兼容 | 已完成 | 保留 `WEBCHAT2API_AUTH_KEY` 作为兼容覆盖项。 |
| 代理配置 | 已完成 | 支持 `PROXY_URL` 覆盖配置文件代理。 |
| 健康检查 | 已完成 | 新增 `GET /health`，返回 `{"status":"ok"}`。 |
| 技术文档 | 已完成 | 新增根目录 `技术文档.md`。 |
| README | 已完成 | 重写为 `webchat2api` 快速部署和 API 概览。 |
| Docker 构建 | 已完成 | `docker build -t webchat2api:latest .` 已通过。 |

## 子任务记录

| 编号 | 任务 | 状态 |
| --- | --- | --- |
| T1 | 并行探索项目结构、配置、API 和部署状态 | 已完成 |
| T2 | 识别旧名称、旧端口和默认密钥冲突 | 已完成 |
| T3 | 对齐运行时端口到 `83` | 已完成 |
| T4 | 增加 `LOGIN_SECRET=admin` 默认登录密钥支持 | 已完成 |
| T5 | 增加 `/health` 健康检查接口 | 已完成 |
| T6 | 更新 Dockerfile、Compose 和环境变量示例 | 已完成 |
| T7 | 更新 README 与新增 `技术文档.md` | 已完成 |
| T8 | 更新测试默认 API 地址到 `83` | 已完成 |
| T9 | 执行类型检查、构建和 Docker 验证 | 进行中 |

## 当前部署参数

| 项目 | 当前值 |
| --- | --- |
| 镜像名 | `webchat2api:latest` |
| 容器名 | `webchat2api` |
| 默认端口 | `83:83` |
| 默认服务地址 | `http://localhost:83` |
| 默认 API Base URL | `http://localhost:83/v1` |
| 默认登录密钥 | `admin` |
| 推荐生产密钥配置 | `LOGIN_SECRET=your-strong-secret` |

## 验证命令

```bash
LOGIN_SECRET=admin python3 -m compileall api services utils main.py test/test_config.py
cd web && npm run typecheck
cd web && npm run build
docker build -t webchat2api:latest .
docker run -d \
  --name webchat2api \
  --restart unless-stopped \
  -p 83:83 \
  -e LOGIN_SECRET=admin \
  webchat2api:latest
curl http://localhost:83/health
```

## 安全提醒

默认登录密钥 `admin` 仅适合本地测试。生产环境必须修改 `LOGIN_SECRET`，并建议启用 HTTPS、限制管理后台访问来源、保护 `data/` 数据目录。
