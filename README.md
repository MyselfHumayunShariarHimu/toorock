# TooRocK

TooRocK is a monochrome, responsive Tor gateway interface backed by a Render Docker service. The original TorWebDoor implementation depended on a third-party `.onion` rewrite service; this project removes that dependency and routes valid v3 onion destinations through a local Tor SOCKS5 daemon.

## Architecture

The Render web service runs the Node.js application and Tor client in one container. The browser talks to `/gateway/proxy?url=...`; the server validates the destination, routes the request through `socks5h://127.0.0.1:9050`, streams bounded responses, and rewrites common HTML resource URLs back through the gateway.

Render is intentionally the only hosting service in this configuration. GitHub can be connected to Render for automatic deploys, but Vercel and Railway are not required.

## Local development

```bash
pnpm install
pnpm dev
```

The local UI is available at `http://localhost:3000`. To exercise the real gateway locally, run Tor separately and set `TOR_SOCKS_HOST` and `TOR_SOCKS_PORT`.

## Render deployment

1. Push this repository to GitHub.
2. Create a Render Web Service from the repository and choose Docker.
3. Keep the health check at `/health`.
4. Keep `TOR_SOCKS_HOST=127.0.0.1` and `TOR_SOCKS_PORT=9050` for the bundled Tor process.
5. Use a paid persistent instance for dependable Tor availability; free instances may sleep or be unsuitable for long-lived gateway sessions.

## Security boundary

Only HTTP/HTTPS v3 onion hostnames are accepted. The route rejects arbitrary clear-web URLs, unsupported ports, oversized targets, and responses over 10 MB. This is not an anonymity guarantee. Operators should publish an abuse policy, monitor resource consumption, and review the gateway before public launch.

## Checks

```bash
pnpm check
pnpm build
pnpm test
```
