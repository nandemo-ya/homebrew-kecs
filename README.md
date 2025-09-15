# Homebrew Tap for KECS

This is the official Homebrew tap for [KECS (Kubernetes-based ECS Compatible Service)](https://github.com/nandemo-ya/kecs).

## Installation

### Stable Version
```bash
# Add the tap
brew tap nandemo-ya/kecs

# Install stable KECS
brew install kecs
```

### Development/Alpha Version
```bash
# Install development version (when available)
brew install kecs-dev
```

### Latest from Main Branch (HEAD)
```bash
# Install latest development build from main branch
brew install kecs --HEAD
```

### Direct Installation
```bash
# Install without adding the tap
brew install nandemo-ya/kecs/kecs

# Install dev version without adding the tap
brew install nandemo-ya/kecs/kecs-dev
```

## Quick Start

After installation, you can start using KECS:

```bash
# Start KECS with a new k3d cluster
kecs start

# Check status
kecs status

# Open interactive TUI
kecs tui

# Configure AWS CLI to use KECS
export AWS_ENDPOINT_URL=http://localhost:5373
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_REGION=us-east-1

# Use AWS CLI with KECS
aws ecs list-clusters
aws ecs create-cluster --cluster-name my-cluster
```

## Requirements

KECS requires the following to be installed:
- Docker
- k3d (installed automatically as a dependency)

## Updating

To update KECS to the latest version:

```bash
brew update
brew upgrade kecs
```

## Uninstallation

To uninstall KECS:

```bash
brew uninstall kecs
```

To remove the tap:

```bash
brew untap nandemo-ya/kecs
```

## Formula Details

The Homebrew formula:
- Installs the KECS binary to `/usr/local/bin/kecs` (Intel Mac) or `/opt/homebrew/bin/kecs` (Apple Silicon)
- Creates a data directory at `/usr/local/var/kecs` or `/opt/homebrew/var/kecs`
- Optionally installs shell completions for bash, zsh, and fish
- Provides a service that can be managed with `brew services`

### Managing KECS as a Service

You can run KECS as a background service:

```bash
# Start KECS service
brew services start kecs

# Stop KECS service
brew services stop kecs

# Restart KECS service
brew services restart kecs

# Check service status
brew services list
```

## Supported Platforms

- macOS (Intel and Apple Silicon)
- Linux (x86_64 and ARM64)

## Troubleshooting

If you encounter issues:

1. **Check Docker is running:**
   ```bash
   docker ps
   ```

2. **Check k3d is installed:**
   ```bash
   k3d version
   ```

3. **View KECS logs:**
   ```bash
   kecs logs -f
   ```

4. **Check service logs (if using brew services):**
   ```bash
   tail -f /usr/local/var/log/kecs.log  # Intel Mac
   tail -f /opt/homebrew/var/log/kecs.log  # Apple Silicon
   ```

## Development

This tap is automatically updated when new KECS releases are published. The formula is maintained at:
https://github.com/nandemo-ya/homebrew-kecs

## License

KECS is licensed under the Apache License 2.0. See the [LICENSE](https://github.com/nandemo-ya/kecs/blob/main/LICENSE) file for details.

## Version Management

### Version Naming Conventions
- **Stable releases**: `v0.1.0`, `v1.0.0`, etc.
- **Pre-releases**: `v0.0.1-alpha`, `v0.1.0-beta.1`, `v1.0.0-rc.1`
- **Development builds**: Use `--HEAD` option for latest main branch

### Switching Between Versions
```bash
# Install specific version
brew install kecs           # Latest stable
brew install kecs-dev        # Latest development/alpha
brew install kecs --HEAD     # Build from main branch

# Switch between installed versions
brew unlink kecs && brew link kecs-dev  # Switch to dev version
brew unlink kecs-dev && brew link kecs  # Switch back to stable
```

## Support

For issues with KECS itself:
- [KECS Issues](https://github.com/nandemo-ya/kecs/issues)
- [KECS Discussions](https://github.com/nandemo-ya/kecs/discussions)

For issues with the Homebrew formula:
- [Homebrew Tap Issues](https://github.com/nandemo-ya/homebrew-kecs/issues)