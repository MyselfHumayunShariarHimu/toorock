FROM node:22-bookworm-slim

RUN apt-get update \
  && apt-get install -y --no-install-recommends tor ca-certificates netcat-openbsd \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY toorock-source.tar.gz ./
RUN tar -xzf toorock-source.tar.gz --strip-components=1 && rm toorock-source.tar.gz
RUN corepack enable && pnpm install --frozen-lockfile
RUN pnpm build

RUN mkdir -p /etc/tor /var/lib/tor \
  && cp deploy/torrc /etc/tor/torrc \
  && chown -R debian-tor:debian-tor /var/lib/tor \
  && chmod 700 /var/lib/tor
ENV NODE_ENV=production
ENV TOR_SOCKS_HOST=127.0.0.1
ENV TOR_SOCKS_PORT=9050
EXPOSE 3000

CMD ["sh", "-c", "su -s /bin/sh debian-tor -c 'exec tor -f /etc/tor/torrc --RunAsDaemon 0' & TOR_PID=$!; for i in $(seq 1 90); do nc -z 127.0.0.1 9050 && break; kill -0 $TOR_PID 2>/dev/null || { wait $TOR_PID; exit 1; }; sleep 1; done; nc -z 127.0.0.1 9050 || { echo 'Tor SOCKS port did not become ready'; kill $TOR_PID; exit 1; }; exec pnpm start"]
