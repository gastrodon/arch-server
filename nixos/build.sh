#!/usr/bin/env bash
# Build script for NixOS configuration
# This script helps validate and build the NixOS configuration

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

function check_syntax() {
    echo "Checking Nix syntax..."
    for file in *.nix; do
        echo "  Checking $file..."
        nix-instantiate --parse "$file" > /dev/null && echo "    ✓ $file syntax OK" || echo "    ✗ $file has syntax errors"
    done
}

function build_system() {
    echo "Building NixOS system configuration..."
    if [ -f flake.nix ]; then
        echo "Using flakes..."
        nix build .#nixosConfigurations.arch-server.config.system.build.toplevel
    else
        echo "Building without flakes..."
        nixos-rebuild build -I nixos-config=./configuration.nix
    fi
}

function dry_build() {
    echo "Performing dry build..."
    nixos-rebuild dry-build -I nixos-config=./configuration.nix
}

function show_help() {
    cat << EOF
Usage: $0 [command]

Commands:
    check       Check syntax of all .nix files
    build       Build the NixOS configuration
    dry-build   Perform a dry build to check for errors
    help        Show this help message

If no command is provided, 'check' will be run.
EOF
}

case "${1:-check}" in
    check)
        check_syntax
        ;;
    build)
        build_system
        ;;
    dry-build)
        dry_build
        ;;
    help)
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
