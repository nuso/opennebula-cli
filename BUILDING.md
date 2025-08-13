# Building OpenNebula CLI Images

This document explains how the automated build system works and how to build custom versions.

## Automated Build System

### How It Works

The repository uses GitHub Actions to automatically build Docker images:

- **Master Branch Builds**: Push to `master` → Builds from OpenNebula's master branch
- **Tagged Builds**: Create git tag `v6.4.0` → Builds OpenNebula 6.4.0

### Build Triggers

#### Master Branch (Development)
```bash
git push origin master
```
**Creates:**
- `ghcr.io/nuso/opennebula-cli:master`
- `ghcr.io/nuso/opennebula-cli:latest`

**Contains:** Latest OpenNebula development code

#### Version Tags (Production)
```bash
git tag v6.4.0
git push origin v6.4.0
```
**Creates:**
- `ghcr.io/nuso/opennebula-cli:6.4.0` (exact version)
- `ghcr.io/nuso/opennebula-cli:6.4` (latest 6.4.x)
- `ghcr.io/nuso/opennebula-cli:6` (latest 6.x.x)

**Contains:** OpenNebula 6.4.0 release

## Building New Versions

### 1. For Any OpenNebula Release

Want to build a specific OpenNebula version? Just tag it:

```bash
# Build OpenNebula 6.10.2
git tag v6.10.2
git push origin v6.10.2

# Build future version 7.0.0
git tag v7.0.0  
git push origin v7.0.0

# Build patch release
git tag v6.4.7
git push origin v6.4.7
```

**No configuration changes needed!** The system automatically:
1. Extracts version from your git tag (`v6.10.2` → `6.10.2`)
2. Clones OpenNebula's `release-6.10.2` branch
3. Builds and publishes the image

### 2. Testing Compatibility

```bash
# Test if newer client works with your 6.4.0 servers
git tag v6.8.0
git push origin v6.8.0

# Deploy to staging
docker run ghcr.io/nuso/opennebula-cli:6.8.0 onevm list --endpoint your-6.4.0-server
```

### 3. Latest Development Features

```bash
# Get latest OpenNebula features
git push origin master

# Test bleeding edge
docker run ghcr.io/nuso/opennebula-cli:master onevm list
```

## Local Development

### Build Locally

```bash
# Build from OpenNebula master
docker build -t onevm:master .

# Build specific version
docker build --build-arg OPENNEBULA_VERSION=6.4.0 -t onevm:6.4.0 .

# Test your build
docker run --rm onevm:6.4.0 onevm --version
```

### Multi-Architecture Build

```bash
# Set up buildx (one time)
docker buildx create --use

# Build for multiple architectures
docker buildx build --platform linux/amd64,linux/arm64 \
  --build-arg OPENNEBULA_VERSION=6.4.0 \
  -t onevm:6.4.0 --push .
```

## Dockerfile Architecture

The build uses a multi-stage approach:

```dockerfile
# Stage 1: Builder - Install OpenNebula
FROM debian:bookworm-slim AS builder
ARG OPENNEBULA_VERSION=master  # Defaults to master
# ... install dependencies, clone source, run install.sh

# Stage 2: Runtime - Minimal final image  
FROM debian:bookworm-slim
# ... copy only necessary files from builder
# ... create non-root user
```

### Build Arguments

- `OPENNEBULA_VERSION`: OpenNebula version to build (default: `master`)
  - `master` → clones master branch
  - `6.4.0` → clones `release-6.4.0` branch

## GitHub Actions Workflow

### Master Branch Job
- **Trigger**: Push to master
- **Build**: Uses default `OPENNEBULA_VERSION=master`
- **Tags**: `master`, `latest`

### Tagged Release Job  
- **Trigger**: Push tag matching `v[0-9]+.[0-9]+.[0-9]+`
- **Build**: Passes version from tag as build arg
- **Tags**: Semantic versioning (`6.4.0`, `6.4`, `6`)

### Features
- Multi-architecture builds (AMD64, ARM64)
- Layer caching for faster builds
- Container signing with Cosign
- Automatic cleanup and optimization

## Migration Strategy

### Phase 1: Current Production (6.4.0 servers)
```bash
# Create stable image for current infrastructure
git tag v6.4.0
git push origin v6.4.0

# Use in production
image: ghcr.io/nuso/opennebula-cli:6.4.0
```

### Phase 2: Compatibility Testing
```bash
# Test newer client versions
git tag v6.6.0
git tag v6.8.0  
git tag v6.10.2
git push origin --tags

# Test in staging against 6.4.0 servers
docker run ghcr.io/nuso/opennebula-cli:6.10.2 onevm list
```

### Phase 3: Infrastructure Upgrade
```bash
# After upgrading servers to 6.10.x
# Switch production to matching client
image: ghcr.io/nuso/opennebula-cli:6.10.2
```

## Troubleshooting Builds

### Build Fails - OpenNebula Version Not Found
```bash
# Error: remote: Invalid refname 'refs/heads/release-6.99.0'
# Solution: Check if OpenNebula version exists
# Visit: https://github.com/OpenNebula/one/branches/all
```

### Build Fails - Ruby Dependencies
```bash
# Usually fixed by updating to newer Debian base image
# or adjusting Ruby package versions in Dockerfile
```

### Container Signing Fails
```bash
# Update cosign-installer action to latest version
# Remove version pinning from workflow
```

## Contributing

1. **Test Local Builds**: Always test locally before pushing
2. **Follow Semver**: Use proper version tags (`v6.4.0`, not `6.4.0`)
3. **Update Documentation**: Update README when adding new features
4. **Test Compatibility**: Verify new versions work with target servers

## Advanced Usage

### Custom Base Images
```dockerfile
# Use different base image
FROM alpine:latest AS builder  # Instead of debian:bookworm-slim
```

### Additional Tools
```dockerfile
# Add more OpenNebula tools
RUN ./install.sh -c -u oneadmin -g oneadmin -d /var/lib/one
# Copy additional binaries in final stage
COPY --from=builder /usr/bin/onehost /usr/bin/onehost
```

### Development Workflow
```bash
# Local development cycle
docker build -t test-onevm .
docker run --rm test-onevm onevm --help
# Make changes, rebuild, test
# When ready: git tag vX.Y.Z && git push origin vX.Y.Z
```
