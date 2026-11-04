#!/bin/bash
set -e

# Install mutable developer tools into the persistent home volume.
skytools ensure --only "${SKYTOOLS_PACKAGES:-all}"

# Node.js (bun)
if [ -f "package.json" ]; then
    if command -v bun >/dev/null 2>&1; then
        echo "Installing Node.js dependencies with bun..."
        bun install
    else
        echo "Skipping Node.js dependencies: bun is not installed."
    fi
fi

# Python (uv)
if [ -f "pyproject.toml" ] || [ -f "requirements.txt" ]; then
    if command -v uv >/dev/null 2>&1; then
        echo "Installing Python dependencies with uv..."
        if [ -f "pyproject.toml" ]; then
            uv sync
        else
            uv pip install -r requirements.txt
        fi
    else
        echo "Skipping Python dependencies: uv is not installed."
    fi
fi

# Rust
if [ -f "Cargo.toml" ]; then
    if command -v cargo >/dev/null 2>&1; then
        echo "Fetching Rust dependencies..."
        cargo fetch
    else
        echo "Skipping Rust dependencies: cargo is not installed."
    fi
fi

# .NET
if compgen -G '*.csproj' >/dev/null || compgen -G '*.fsproj' >/dev/null || compgen -G '*.sln' >/dev/null; then
    if command -v dotnet >/dev/null 2>&1; then
        echo "Restoring .NET dependencies..."
        dotnet restore
    else
        echo "Skipping .NET dependencies: dotnet is not installed."
    fi
fi
