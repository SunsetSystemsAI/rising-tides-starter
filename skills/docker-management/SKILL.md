---
name: docker-management
description: "Use when managing Docker containers, images, networks, or volumes. Invoke for container lifecycle, Docker Compose workflows, image building, and Docker troubleshooting."
---

# Docker Management

## When to Use MCP vs CLI

| Task | Use MCP | Use CLI |
|------|---------|---------|
| List/inspect containers | MCP `list_containers`, `get_container_info` | `docker ps` |
| Start/stop/restart | MCP `start_container`, `stop_container` | `docker start/stop` |
| View logs | MCP `get_container_logs` | `docker logs` |
| Build images | CLI preferred (streaming output) | `docker build` |
| Docker Compose up/down | CLI preferred (interactive) | `docker compose up` |
| Network/volume management | MCP for inspection, CLI for creation | Both work |
| Pull images | CLI preferred | `docker pull` |

**Rule of thumb:** Use MCP for inspection and simple lifecycle operations. Use CLI for builds, Compose workflows, and anything with streaming output.

## Container Lifecycle

### Start a new container
1. Check if image exists locally via MCP `list_images`
2. If not, pull with CLI: `docker pull <image>`
3. Create and start via MCP `create_container` or CLI `docker run`
4. Verify running via MCP `list_containers`

### Stop and remove
1. Stop via MCP `stop_container` (graceful shutdown)
2. Remove via MCP `remove_container`
3. For force removal: CLI `docker rm -f <container>`

### View logs and debug
1. Get recent logs via MCP `get_container_logs`
2. For live tailing: CLI `docker logs -f <container>`
3. Exec into container: CLI `docker exec -it <container> /bin/sh`

## Image Management

### Build an image
```bash
docker build -t <name>:<tag> .
```
- Always tag images explicitly; avoid relying on `latest`
- Use multi-stage builds to reduce image size
- Add `.dockerignore` to exclude node_modules, .git, etc.

### List and clean up
- List via MCP `list_images` or `docker images`
- Remove unused: `docker image prune`
- Remove all unused (including tagged): `docker image prune -a`

## Networking

### Common patterns
- **Bridge** (default) — Containers on same host communicate by name
- **Host** — Container shares host network stack
- **None** — No networking

### Create and connect
```bash
docker network create my-network
docker run --network my-network --name app my-image
```
- Containers on the same user-defined network can resolve each other by container name
- Inspect networks via MCP or `docker network inspect`

## Volumes

### Persistent data
```bash
docker volume create my-data
docker run -v my-data:/app/data my-image
```

### Bind mounts (development)
```bash
docker run -v $(pwd)/src:/app/src my-image
```
- Use bind mounts for live code reloading in development
- Use named volumes for databases and persistent state

## Docker Compose Patterns

### Development setup
```yaml
services:
  app:
    build: .
    ports:
      - "3000:3000"
    volumes:
      - ./src:/app/src
    depends_on:
      - db
  db:
    image: postgres:16
    environment:
      POSTGRES_PASSWORD: dev
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:
```

### Common commands
```bash
docker compose up -d          # Start in background
docker compose logs -f app    # Follow app logs
docker compose down           # Stop and remove
docker compose down -v        # Stop and remove volumes too
docker compose build --no-cache  # Rebuild from scratch
```

## Troubleshooting

### Container won't start
1. Check logs: MCP `get_container_logs` or `docker logs <container>`
2. Check exit code: MCP `get_container_info`
3. Common causes: missing env vars, port conflicts, missing files

### Port conflicts
```bash
docker ps --format "{{.Ports}}"   # See all port mappings
lsof -i :<port>                   # Check what's using a port
```

### Disk space
```bash
docker system df               # Show disk usage
docker system prune            # Remove all unused data
docker system prune --volumes  # Include volumes
```

### Container networking issues
1. Verify containers are on the same network
2. Use container names (not localhost) for inter-container communication
3. Inspect with `docker network inspect <network>`
