# opennebula-cli

A containerized OpenNebula CLI utility built from the official OpenNebula source using multi-stage Docker builds for minimal image size.

## Features

* Builds OpenNebula CLI Docker image based on `install.sh -c` from https://github.com/OpenNebula/one
* Multi-stage build for minimal final image size
* Uses latest Debian slim base image
* Non-root user for security
* Multi-architecture support (AMD64, ARM64)
* Signed container images with Cosign

## Available Tags

### Stable Releases (Recommended for Production)
- `ghcr.io/nuso/opennebula-cli:6.4.0` - OpenNebula 6.4.0 (exact version)
- `ghcr.io/nuso/opennebula-cli:6.4` - Latest 6.4.x patch version
- `ghcr.io/nuso/opennebula-cli:6` - Latest 6.x.x version

### Development
- `ghcr.io/nuso/opennebula-cli:master` - Built from OpenNebula master branch
- `ghcr.io/nuso/opennebula-cli:latest` - Alias for master

## Usage

### Basic Commands
```bash
# List all VMs
docker run --rm ghcr.io/nuso/opennebula-cli:6.4.0 onevm list \
  --user <username> --password <password> --endpoint <XML-RPC-URL>

# Show VM details
docker run --rm ghcr.io/nuso/opennebula-cli:6.4.0 onevm show <vmid> --json \
  --user <username> --password <password> --endpoint <XML-RPC-URL>

# Resize VM disk
docker run --rm ghcr.io/nuso/opennebula-cli:6.4.0 onevm disk-resize <vmid> 0 10G \
  --user <username> --password <password> --endpoint <XML-RPC-URL>
```

### Using Environment Variables
```bash
# Set credentials as environment variables
export ONE_AUTH="username:password"
export ONE_XMLRPC="http://your-opennebula-server:2633/RPC2"

# Simplified commands
docker run --rm -e ONE_AUTH -e ONE_XMLRPC ghcr.io/nuso/opennebula-cli:6.4.0 onevm list
```

### Advanced Usage with jq
```bash
# Get root disk size
docker run --rm ghcr.io/nuso/opennebula-cli:6.4.0 onevm show <vmid> --json \
  --user <username> --password <password> --endpoint <XML-RPC-URL> \
  | jq -r '.VM.TEMPLATE.DISK.SIZE'

# List VMs with custom formatting
docker run --rm ghcr.io/nuso/opennebula-cli:6.4.0 onevm list --json \
  --user <username> --password <password> --endpoint <XML-RPC-URL> \
  | jq -r '.VM_POOL.VM[] | "\(.ID): \(.NAME) (\(.STATE_STR))"'
```

## Version Compatibility

| Image Tag | OpenNebula Version | Recommended For |
|-----------|-------------------|-----------------|
| `6.4.0`, `6.4` | 6.4.x | Production with 6.4.x servers |
| `6.10.2`, `6.10` | 6.10.x | Production with 6.10.x servers |
| `master`, `latest` | Development | Testing new features |

**Note**: For production use, always pin to exact versions (e.g., `6.4.0`) to ensure reproducible builds.

## Security

- Images are built with non-root user (`oneadmin`)
- All container images are signed with [Cosign](https://github.com/sigstore/cosign)
- Multi-stage builds minimize attack surface
- No unnecessary packages in final image

## Building Custom Versions

See [BUILDING.md](BUILDING.md) for instructions on building custom versions and contributing to this project.

## License

This project follows the same license as OpenNebula. See the [OpenNebula repository](https://github.com/OpenNebula/one) for license details.
