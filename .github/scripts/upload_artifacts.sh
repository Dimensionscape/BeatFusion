#!/bin/bash

# Upload Windows Build
if [ -d "$WINDOWS_BUILD_PATH" ]; then
  echo "Uploading Windows Build..."
  actions/upload-artifact@v3 --name "Windows (32-Bit) Build" --path "$WINDOWS_BUILD_PATH"
else
  echo "Windows build path not found"
fi

# Upload HTML5 Build
if [ -d "$HTML5_BUILD_PATH" ]; then
  echo "Uploading HTML5 Build..."
  actions/upload-artifact@v3 --name "HTML5 Build" --path "$HTML5_BUILD_PATH"
else
  echo "HTML5 build path not found"
fi