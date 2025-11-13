#!/usr/bin/env bash
set -e

BUILD_DIR="build"

echo ">>> Removing old build directory..."
rm -rf "$BUILD_DIR"

echo ">>> Creating new build directory..."
mkdir "$BUILD_DIR"
cd "$BUILD_DIR"

echo ">>> Running CMake configure..."
cmake .. \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
  -DUSE_WAYLAND_WSI=OFF

echo ">>> Building..."
cmake --build . -- -j"$(nproc)"

# Optionally copy compile_commands.json to project root
if [ -f compile_commands.json ]; then
    echo ">>> Copying compile_commands.json to project root..."
    cp compile_commands.json ..
fi

echo ">>> Done."

