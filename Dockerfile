# Multi-stage build for OpenNebula onevm utility
# Build stage
FROM debian:bookworm-slim AS builder

# Build argument for OpenNebula version - defaults to master
ARG OPENNEBULA_VERSION=master
ENV OPENNEBULA_VERSION=${OPENNEBULA_VERSION}

# Install build dependencies in a single layer
RUN apt-get update && apt-get install -y \
    ruby-nokogiri \
    ruby-treetop \
    ruby-parse-cron \
    ruby-activesupport \
    git \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Clone OpenNebula source using build arg
RUN if [ "$OPENNEBULA_VERSION" = "master" ]; then \
      git clone --depth 1 https://github.com/OpenNebula/one.git /one; \
    else \
      git clone --depth 1 --branch release-${OPENNEBULA_VERSION} https://github.com/OpenNebula/one.git /one; \
    fi

# Install OpenNebula
WORKDIR /one
RUN mkdir -p /var/lib/one/sunstone /usr/lib/one/sunstone/public/dist/ && \
    ./install.sh -c

# Runtime stage - minimal final image
FROM debian:bookworm-slim

# Install only runtime Ruby dependencies.
# ruby-ipaddress is required by oneflow_client.rb, which oneflow and
# oneflow-template load at startup — without it both exit with a LoadError.
RUN apt-get update && apt-get install -y \
    ruby-nokogiri \
    ruby-treetop \
    ruby-parse-cron \
    ruby-activesupport \
    ruby-ipaddress \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# Create necessary directories
RUN mkdir -p /var/lib/one/sunstone /usr/lib/one/sunstone/public/dist/

# Copy the installed OpenNebula components from builder. `install.sh -c`
# installs all 25 CLI entry points; each is a self-contained command definition
# that loads the shared helpers from /usr/lib/one/ruby/cli, which the next line
# already copies in full. Copying only onevm shipped an image where oneflow,
# onehook, oneimage, onevnet and the rest were missing despite their helpers
# being present — including commands this image's own README documents.
COPY --from=builder /usr/bin/one* /usr/bin/
COPY --from=builder /usr/lib/one/ /usr/lib/one/
# oneflow and oneflow-template `require 'cloud/CloudClient'`, but `install.sh -c`
# installs that file AS /usr/lib/one/ruby/cloud — a plain file where the require
# needs a directory, so the load can never resolve. (The Debian packages get
# this right: opennebula-libs ships /usr/lib/one/ruby/cloud/CloudClient.rb.)
# Reinstate the directory layout the require expects.
RUN mv /usr/lib/one/ruby/cloud /tmp/CloudClient.rb && \
    mkdir -p /usr/lib/one/ruby/cloud && \
    mv /tmp/CloudClient.rb /usr/lib/one/ruby/cloud/CloudClient.rb
# onezone needs CommandManager, which `install.sh -c` also leaves in the source
# tree. Two entry points remain unusable and are deliberately out of scope here:
# oneflow-template needs the Flow server's models/, which then fail to load
# without OpenNebula's version metadata, and oneirb is an interactive debug
# shell needing the `ox` gem.
COPY --from=builder /one/src/mad/ruby/CommandManager.rb /usr/lib/one/ruby/CommandManager.rb
COPY --from=builder /var/lib/one/ /var/lib/one/

# Create a non-root user for security
RUN groupadd -r oneadmin && useradd -r -g oneadmin oneadmin
USER oneadmin

CMD ["onevm"]
