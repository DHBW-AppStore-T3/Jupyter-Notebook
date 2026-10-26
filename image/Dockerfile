# JupyterLab for the pod runtime (appstore.yaml). One container per person; the
# platform sets user (UID 1000), a read-only root filesystem and the login
# secret (env JUPYTER_TOKEN, entered on the login page as "password or token").
FROM docker.io/library/python:3.12.15-slim-bookworm

# Security fixes the base image does not have yet (weekly Trivy scan, 2026-10-26):
# openssl/libssl3 CVE-2026-84782, fixed in 3.0.22-1~deb12u2. --only-upgrade takes the
# newest fix from bookworm-security; the version check fails the build instead of
# shipping without it. Edit this line for the next fix: an unchanged line lets the
# build cache reuse the old layer, and the upgrade would not run again.
# hadolint ignore=DL3008
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --only-upgrade openssl libssl3 \
 && dpkg --compare-versions "$(dpkg-query -W -f='${Version}' libssl3)" ge 3.0.22-1~deb12u2 \
 && rm -rf /var/lib/apt/lists/*

ENV PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_ROOT_USER_ACTION=ignore \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

COPY requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt && rm /tmp/requirements.txt

# HOME is the storage volume (mounted by the platform): notebooks, ~/.jupyter,
# ~/.local (pip install --user) and the matplotlib cache all live there.
# SHELL is set because the UID has no passwd entry (terminal in JupyterLab).
ENV HOME=/home/jovyan \
    SHELL=/bin/bash

# The cluster is IPv6-primary: listen on all families, not on 127.0.0.1.
# No entrypoint script: it may try sudo, which the platform forbids.
EXPOSE 8080
ENTRYPOINT ["jupyter", "lab"]
CMD ["--ip=::", "--port=8080", "--no-browser", \
     "--ServerApp.root_dir=/home/jovyan", \
     "--ServerApp.trust_xheaders=True"]
