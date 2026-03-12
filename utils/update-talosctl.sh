#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./install-talosctl.sh              Install the latest version
#   ./install-talosctl.sh v1.7.0       Install a specific version

VERSION="${1:-latest}"

if [[ "$VERSION" == "latest" ]]; then
  URL="https://github.com/siderolabs/talos/releases/latest/download/talosctl-linux-amd64"
else
  URL="https://github.com/siderolabs/talos/releases/download/${VERSION}/talosctl-linux-amd64"
fi
INSTALL_DIR="$HOME/.local/bin"
BINARY_NAME="talosctl"
INSTALL_PATH="$INSTALL_DIR/$BINARY_NAME"

echo "Installing talosctl ($VERSION) to $INSTALL_PATH..."

# Create install directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Download the binary
curl -fsSL "$URL" -o "$INSTALL_PATH"

# Make it executable
chmod +x "$INSTALL_PATH"

echo "talosctl installed successfully to $INSTALL_PATH"

# Warn if ~/.local/bin is not in PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
  echo ""
  echo "WARNING: $INSTALL_DIR is not in your PATH."
  echo "Add the following line to your ~/.bashrc or ~/.zshrc:"
  echo ""
  echo '  export PATH="$HOME/.local/bin:$PATH"'
  echo ""
  echo "Then reload your shell with: source ~/.bashrc"
fi
