#!/usr/bin/env bash
# Railway entrypoint: API + worker + web in one container so they share the single /data volume.
# ponytail: one container, three processes; split into services when a remote sandbox provider
# (e2b/daytona/box) is configured and DATA_DIR no longer needs to be shared.
set -euo pipefail
cd /app

pnpm --filter @rakazo/db exec prisma migrate deploy

export API_HOST="${API_HOST:-127.0.0.1}"
export API_PROXY_TARGET="http://127.0.0.1:${API_PORT:-3100}"
export WEB_PORT="${PORT:-5173}"

pnpm --filter @rakazo/api start &
pnpm --filter @rakazo/worker start &
pnpm --filter @rakazo/web preview --host 0.0.0.0 --port "$WEB_PORT" &

# Exit when any child dies so Railway restarts the whole unit.
wait -n
exit 1
