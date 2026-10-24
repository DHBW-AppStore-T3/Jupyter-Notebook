#!/usr/bin/env bash
# Smoke test: JupyterLab answers and the libraries import in the platform's security context. Run by the central pipeline
# (DHBW-AppStore-T3/app-registry) against the locally built image, before the Trivy scan and before any push.
# IMAGE and PLATFORM_RUN_FLAGS (--user 1000:1000 --read-only --cap-drop ALL --security-opt no-new-privileges
# --network host) come from the pipeline; the pipeline removes the container afterwards.
set -euo pipefail

# shellcheck disable=SC2086  # PLATFORM_RUN_FLAGS is meant to split into words
docker run -d --name jl $PLATFORM_RUN_FLAGS \
  --tmpfs /tmp --tmpfs /home/jovyan:uid=1000,gid=1000 \
  -e JUPYTER_TOKEN=ci-smoke-test \
  "$IMAGE"

ok=0
for _ in $(seq 1 30); do
  if curl -fsS -H "Authorization: token ci-smoke-test" "http://[::1]:8080/api/status"; then ok=1; break; fi
  sleep 2
done
docker logs jl
[ "$ok" = 1 ]

docker exec jl python -c "import numpy, pandas, matplotlib; matplotlib.use('Agg'); import matplotlib.pyplot as plt; plt.plot([1, 2]); plt.savefig('/tmp/x.png'); print('libs ok')"
