# JupyterLab for the pod runtime (appstore.yaml). One container per person; the
# platform sets user (UID 1000), a read-only root filesystem and the login
# secret (env JUPYTER_TOKEN, entered on the login page as "password or token").
FROM docker.io/library/python:3.12.15-slim-trixie

ENV PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_ROOT_USER_ACTION=ignore \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

COPY requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt && rm /tmp/requirements.txt

# Security updates the base image does not have yet, at every CI build: app-ci.yml sets SECURITY_REFRESH to a new
# value for each run, so the build cache cannot keep an older package state (app-registry README, "Sicherheitsupdates
# im Image"). After the expensive steps, which stay cached; everything below is rebuilt in each run.
ARG SECURITY_REFRESH
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y --no-install-recommends \
 && rm -rf /var/lib/apt/lists/*

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
