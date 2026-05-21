# webchat2api 转型研究记录

## 研究结论

项目已正式统一为 `webchat2api`，当前交付目标为版本 `0.0.1`，默认 Docker/CLI 部署端口为 `83:83`，默认本地测试登录密钥为 `admin`。

## 当前架构

- 后端：Python 3.13 + FastAPI + Uvicorn。
- 前端：Next.js 16 + React 19 + TypeScript，构建为静态产物后由 FastAPI 托管。
- 存储：默认 JSON 文件，支持 SQLite、PostgreSQL 和 Git 存储后端。
- 鉴权：`LOGIN_SECRET`、`WEBCHAT2API_AUTH_KEY`、`config.json` 的 `auth-key` 和用户 API Key。
- 代理：`PROXY_URL` 或后台配置的 HTTP/HTTPS/SOCKS 代理。
- 部署：Docker CLI 和 Docker Compose。

## 关键文件

| 文件 | 当前状态 |
| --- | --- |
| `README.md` | 已更新为 `webchat2api` 快速部署说明，默认端口 `83`，默认登录密钥 `admin`。 |
| `技术文档.md` | 新增完整部署、运行、维护和 API 文档。 |
| `Dockerfile` | 构建前端静态产物并启动 FastAPI，`EXPOSE 83`。 |
| `docker-compose.yml` | 服务名、镜像名和容器名均为 `webchat2api`，端口 `83:83`。 |
| `docker-compose.local.yml` | 本地构建部署文件，端口 `83:83`。 |
| `config.json` / `config.example.json` | `config.json` 为本地运行配置文件，已在 `.gitignore` 中忽略；`config.example.json` 为可提交示例文件。 |
| `services/config.py` | 支持 `LOGIN_SECRET`，兼容 `WEBCHAT2API_AUTH_KEY`，并支持 `PROXY_URL`。 |
| `main.py` | 读取 `HOST` 和 `PORT`，默认 `0.0.0.0:83`。 |
| `api/app.py` | FastAPI 标题为 `webchat2api`，新增 `/health`。 |
| `web/src/constants/common-env.ts` | 本地开发 API 地址为 `http://127.0.0.1:83`。 |

## API 能力

- `GET /health`
- `GET /version`
- `GET /v1/models`
- `POST /v1/chat/completions`
- `POST /v1/images/generations`
- `POST /v1/images/edits`
- `POST /v1/responses`
- `POST /v1/messages`

## 部署研究结论

推荐本地构建并运行：

```bash
docker build -t webchat2api:latest .
docker run -d \
  --name webchat2api \
  --restart unless-stopped \
  -p 83:83 \
  -v $(pwd)/data:/app/data \
  -e PORT=83 \
  -e HOST=0.0.0.0 \
  -e LOGIN_SECRET=admin \
  webchat2api:latest
```

生产环境必须将 `LOGIN_SECRET` 修改为强随机密钥，并建议通过反向代理启用 HTTPS、限制访问来源和保护 `data/` 目录。

## 验证记录

已完成的验证项目包括：

- Python 编译检查。
- 前端 TypeScript 检查。
- Next.js 生产构建。
- Docker 镜像构建。
- 镜像元数据检查：暴露 `83/tcp`，启动命令为 `uv run python main.py`。

完整最终验证结果以当前交付总结为准。
