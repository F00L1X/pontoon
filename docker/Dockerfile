FROM python:3.11-bookworm AS server

ARG USER_ID=1000
ARG GROUP_ID=1000

ENV DEBIAN_FRONTEND=noninteractive
ENV HGPYTHON3=1

# Python environment variables
ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONPATH /app

# Install required software.
RUN apt-get update \
    # Install basic dependencies first
    && apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
    # Add NodeSource repository for Node.js
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    # Install remaining packages
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        libmemcached-dev \
        nodejs \
        postgresql-client \
        postgresql-server-dev-15 \
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install uv (version should match the one used in Python GitHub workflows)
COPY --from=ghcr.io/astral-sh/uv:0.7.16 /uv /bin/uv

WORKDIR /app

# Install Pontoon Python requirements
COPY requirements/* /app/requirements/
RUN uv pip install --system -r requirements/default.txt -r requirements/dev.txt -r requirements/test.txt -r requirements/lint.txt

# Create the app user
RUN groupadd -r --gid=${GROUP_ID} pontoon && useradd --uid=${USER_ID} --no-log-init -r -m -g pontoon pontoon
RUN chown -R pontoon:pontoon /app
USER pontoon

# Install the server's Node.js requirements
ENV YUGLIFY_BINARY /app/node_modules/.bin/yuglify
ENV TERSER_BINARY /app/node_modules/.bin/terser

COPY --chown=pontoon:pontoon pontoon/package.json .
COPY --chown=pontoon:pontoon package*.json ./
COPY --chown=pontoon:pontoon pontoon/package*.json ./pontoon/
COPY --chown=pontoon:pontoon translate/package*.json ./translate/
RUN npm install

COPY --chown=pontoon:pontoon .env .env
COPY --chown=pontoon:pontoon . /app/

# Build frontend assets
RUN cd /app/translate && npm install && npm run build

# Verify build output and collect static files
RUN ls -la /app/translate/dist/ && \
    python manage.py collectstatic --noinput

STOPSIGNAL SIGINT
CMD ["/app/docker/server_run.sh"]
