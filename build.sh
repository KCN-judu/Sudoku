#!/bin/sh
# Builds the native CLI into build/sudoku.
set -eu
moon build --target native --release
mkdir -p build
cp _build/native/release/build/Sudoku.exe build/sudoku
chmod 755 build/sudoku
