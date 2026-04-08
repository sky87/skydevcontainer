#!/bin/bash
set -e

# Node.js (bun)
if [ -f "package.json" ]; then
    echo "Installing Node.js dependencies with bun..."
    bun install
fi

# Python (uv)
if [ -f "pyproject.toml" ] || [ -f "requirements.txt" ]; then
    echo "Installing Python dependencies with uv..."
    if [ -f "pyproject.toml" ]; then
        uv sync
    else
        uv pip install -r requirements.txt
    fi
fi

# Rust
if [ -f "Cargo.toml" ]; then
    echo "Fetching Rust dependencies..."
    cargo fetch
fi

# .NET
if ls *.csproj 1> /dev/null 2>&1 || ls *.fsproj 1> /dev/null 2>&1 || [ -f "*.sln" ]; then
    echo "Restoring .NET dependencies..."
    dotnet restore
fi
