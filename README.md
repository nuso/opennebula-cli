# opennebula-cli

## Features:

 * Builds OpenNebula CLI Docker image based on `install.sh -c` from https://github.com/OpenNebula/one

## Usage:

 * Example usage for listing all VMs
   ```
   docker run ghcr.io/nuso/opennebula-cli onevm list --user <username> --password <password> --endpoint <XML-RPC-URL>
   ```
