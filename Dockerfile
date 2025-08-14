# Build RogueOS ISO inside a container for reproducible builds
FROM debian:stable-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends git ca-certificates live-build sudo && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY . /src

# Default command builds the ISO
CMD ["/bin/bash", "-c", "./build.sh"]
