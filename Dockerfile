FROM python:3.13-slim

# Pinned at build time. The CI workflow passes the current PyPI latest as a
# build-arg and tags the image with it; a local build uses this default.
ARG PIRATEFACE_VERSION=0.2.24
RUN pip install --no-cache-dir "pirateface==${PIRATEFACE_VERSION}"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
