# Multi-stage build for OpenNebula onevm utility
# Build stage
FROM debian:bookworm-slim AS builder

# Install build dependencies in a single layer
RUN apt-get update && apt-get install -y \
    ruby-nokogiri \
    ruby-treetop \
    ruby-parse-cron \
    ruby-activesupport \
    git \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Clone OpenNebula source
RUN git clone --depth 1 --branch release-6.8.0 https://github.com/OpenNebula/one.git /one

# Install OpenNebula
WORKDIR /one
RUN mkdir -p /var/lib/one/sunstone /usr/lib/one/sunstone/public/dist/ && \
    ./install.sh -c

# Runtime stage - minimal final image
FROM debian:bookworm-slim

# Install only runtime Ruby dependencies
RUN apt-get update && apt-get install -y \
    ruby-nokogiri \
    ruby-treetop \
    ruby-parse-cron \
    ruby-activesupport \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# Create necessary directories
RUN mkdir -p /var/lib/one/sunstone /usr/lib/one/sunstone/public/dist/

# Copy only the installed OpenNebula components from builder
COPY --from=builder /usr/bin/onevm /usr/bin/onevm
COPY --from=builder /usr/lib/one/ /usr/lib/one/
COPY --from=builder /var/lib/one/ /var/lib/one/

# Create a non-root user for security
RUN groupadd -r oneadmin && useradd -r -g oneadmin oneadmin
USER oneadmin

CMD ["onevm"]
