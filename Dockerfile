ARG BUILDPLATFORM
ARG TARGETPLATFORM
ARG TARGETARCH

FROM --platform=$BUILDPLATFORM node:22-alpine AS web-build

WORKDIR /app/web

COPY web/package.json web/bun.lock ./
RUN set -eux; \
    npm config set fetch-retries 5; \
    npm config set fetch-retry-mintimeout 10000; \
    npm config set fetch-retry-maxtimeout 60000; \
    for attempt in 1 2 3 4 5; do \
        npm install && \
        break; \
        if [ "$attempt" -eq 5 ]; then \
            exit 1; \
        fi; \
        echo "npm install failed, retrying (${attempt}/5)..." >&2; \
        npm cache clean --force; \
        sleep 5; \
    done

COPY VERSION /app/VERSION
COPY web ./
RUN NEXT_PUBLIC_APP_VERSION="$(cat /app/VERSION)" npm run build


FROM --platform=$TARGETPLATFORM python:3.13-slim AS app

ARG TARGETPLATFORM
ARG TARGETARCH

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_LINK_MODE=copy

WORKDIR /app

# 安装系统依赖
# - git: Git 存储后端需要
# - libpq-dev: PostgreSQL 客户端库
# - gcc: 编译 psycopg2-binary 需要
RUN set -eux; \
    for attempt in 1 2 3 4 5; do \
        apt-get update -o Acquire::Retries=5 && \
        apt-get install -y -o Acquire::Retries=5 --no-install-recommends \
            git \
            libpq-dev \
            gcc \
            openssl && \
        break; \
        if [ "$attempt" -eq 5 ]; then \
            exit 1; \
        fi; \
        echo "apt install failed, retrying (${attempt}/5)..." >&2; \
        sleep 5; \
    done; \
    rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir uv

COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev --no-install-project

COPY main.py ./
COPY config.example.json ./config.json
COPY VERSION ./
COPY api ./api
COPY services ./services
COPY utils ./utils
COPY scripts ./scripts
COPY --from=web-build /app/web/out ./web_dist

EXPOSE 83

CMD ["uv", "run", "python", "main.py"]
