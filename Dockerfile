FROM node:22-bookworm-slim

RUN apt-get update \
  && apt-get install -y --no-install-recommends tor ca-certificates \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY toorock-source.tar.gz ./
RUN tar -xzf toorock-source.tar.gz --strip-components=1 && rm toorock-source.tar.gz
RUN corepack enable && pnpm install --frozen-lockfile
RUN pnpm build

COPY deploy/torrc /etc/tor/torrc
ENV NODE_ENV=production
ENV TOR_SOCKS_HOST=127.0.0.1
ENV TOR_SOCKS_PORT=9050
EXPOSE 3000

CMD ["sh", "-c", "tor -f /etc/tor/torrc & exec pnpm start"]
