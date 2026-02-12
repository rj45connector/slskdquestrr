
# 𓅪 slskdquestrr

A sleek, self-hosted web UI for requesting music downloads through
[slskd](https://github.com/slskd/slskd) (Soulseek).  
Search by **album** or **track**, and slskdquestrr automatically picks
the best-quality source (prefers FLAC) and queues the download — no
need to touch the slskd interface.

![screenshot](https://img.shields.io/badge/status-stable-green)
![docker](https://img.shields.io/badge/docker-ready-blue)

---

## Features

| | |
|---|---|
| 🎵 **Album & Track modes** | Full-album folders or single best-quality files |
| 🏆 **Smart scoring**       | Ranks results by format, bitrate, relevance, queue length |
| 🔒 **No CORS headaches**   | Built-in nginx reverse-proxy to the slskd API |
| ⚡ **Lightweight**          | ~7 MB image (nginx:alpine) |
| 🎨 **Gruvbox theme**       | Beautiful dark UI with JetBrains Mono |

---

## Prerequisites

| Requirement | Notes |
|---|---|
| **Docker** & **Docker Compose** | v2+ recommended |
| **slskd** | Running instance with an API key configured |

### slskd API Key

In your slskd config (`slskd.yml`), ensure you have an API key:

```yaml
web:
  authentication:
    api_keys:
      webapp:
        key: "YOUR_API_KEY_HERE"
        role: readwrite
```

---

## Environment Variables

| Variable | Required | Default | Description |
|---|---|---|---|
| `SLSKD_BASE_URL` | ✅ | `http://slskd:5030` | Internal URL of your slskd instance |
| `SLSKD_API_KEY` | ✅ | `changeme` | API key for slskd authentication |

> **Note:** `SLSKD_BASE_URL` should be the Docker-internal URL (no trailing slash).  
> If slskd uses `network_mode: service:gluetun`, use `http://gluetun:5030`.

---

## Deployment

### Option A — Add to an existing Docker Compose stack

Add this service to your `docker-compose.yml`:

```yaml
services:
  slskdquestrr:
    image: ghcr.io/rj45connector/slskdquestrr:latest
    container_name: slskdquestrr
    ports:
      - "8082:80"
    environment:
      - SLSKD_BASE_URL=http://gluetun:5030      # or http://slskd:5030
      - SLSKD_API_KEY=your-api-key-here
    restart: unless-stopped
```

Then:

```bash
docker compose up -d slskdquestrr
```

### Option B — Build from source

```bash
git clone https://github.com/rj45connector/slskdquestrr.git
cd slskdquestrr

# Edit docker-compose.yml with your SLSKD_API_KEY

docker compose up -d --build
```

### Access

Open **http://YOUR_SERVER_IP:8082** in your browser.

---

All API calls from the browser go to `/api/v0/...` on the same origin.
Nginx proxies them to slskd internally — zero CORS configuration needed.

---

## Customisation

### Tuning the search algorithm

Edit `public/index.html` and adjust the `CFG` object:

| Parameter | Default | Effect |
|---|---|---|
| `POLLS` | 24 | How many times to check for search results |
| `DELAY` | 2500 | Milliseconds between polls |
| `MIN_TRACKS` | 4 | Minimum files for a folder to qualify as "album" |
| `REL_GATE` | 0.45 | Minimum relevance score (0–1) |
| `W_FLAC` | 100 | Bonus points for FLAC sources |

### Theming

All colours use CSS custom properties (Gruvbox palette).  
Edit the `:root` block in `public/index.html` to reskin.

---

## Health Check

```bash
curl http://localhost:8082/health
# OK
```

---

## License

MIT — do whatever you want.
```

---

## Quick Start — Build & Run

```bash
# 1. Clone / create the repo
mkdir slskdquestrr && cd slskdquestrr

# 2. Create the folder structure
mkdir -p public nginx

# 3. Place the files:
#    public/index.html          ← modified HTML (above)
#    nginx/default.conf.template ← nginx template (above)
#    entrypoint.sh              ← startup script (above)
#    Dockerfile                 ← Dockerfile (above)

# 4. Make entrypoint executable
chmod +x entrypoint.sh

# 5. Build the image
docker build -t slskdquestrr:latest .

# 6. Test it standalone
docker run --rm -p 8082:80 \
  -e SLSKD_BASE_URL=http://host.docker.internal:5030 \
  -e SLSKD_API_KEY=YourKeyHere \
  slskdquestrr:latest

# 7. Open http://localhost:8082
```
---
## How It All Fits Together

| Piece | Purpose |
|---|---|
| `Dockerfile` | Builds a ~7 MB `nginx:alpine` image with the frontend baked in |
| `entrypoint.sh` | At startup: generates `/config.js` from env vars, processes the nginx template, starts nginx |
| `config.js` (generated) | Passes `SLSKD_API_KEY` and `API_BASE` to the browser JS at runtime — no rebuild needed to change config |
| `default.conf.template` | Nginx serves the HTML at `/` and proxies `/api/v0/*` → slskd — eliminates CORS entirely |
| `index.html` | Reads connection info from `window.SLSKD_CONFIG` (loaded via `config.js`) instead of hard-coding it |

> **Security note:** The API key is visible in the browser's `/config.js`. This is acceptable for a private, self-hosted tool behind your LAN/VPN. Do **not** expose port 8082 to the public internet without additional authentication (e.g., Authelia, Authentik, or HTTP basic auth in nginx).
