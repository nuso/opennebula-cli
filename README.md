# opennebula-cli

## Features:

 * Builds OpenNebula CLI Docker image based on `install.sh -c` from https://github.com/OpenNebula/one

## Usage:

 * Example usage for listing all VMs
   ```
   docker run --rm ghcr.io/nuso/opennebula-cli:master onevm list --user <username> --password <password> --endpoint <XML-RPC-URL>
   docker run --rm ghcr.io/nuso/opennebula-cli:master onevm show <vmid> --json --user <username> --password <password> --endpoint <XML-RPC-URL>
   ```
