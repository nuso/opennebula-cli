# opennebula-cli

## Features:

 * Builds OpenNebula CLI Docker image based on `install.sh -c` from https://github.com/OpenNebula/one

## Usage:

 * Example usage for listing all VMs, showing VM info, resizing root disk, and grabbing root disk size
   ```
   docker run --rm ghcr.io/nuso/opennebula-cli:master onevm list --user <username> --password <password> --endpoint <XML-RPC-URL> 2>/dev/null
   docker run --rm ghcr.io/nuso/opennebula-cli:master onevm show <vmid> --json --user <username> --password <password> --endpoint <XML-RPC-URL> 2>/dev/null
   docker run --rm ghcr.io/nuso/opennebula-cli:master onevm disk-resize <vmid> 0 10G --json --user <username> --password <password> --endpoint <XML-RPC-URL> 2>/dev/null
   docker run --rm ghcr.io/nuso/opennebula-cli:master onevm show <vmid> --json --user <username> --password <password> --endpoint <XML-RPC-URL> 2>/dev/null | jq -r '.VM.TEMPLATE.DISK.SIZE'
   ```
