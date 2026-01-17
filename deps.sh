#!/bin/sh
set -e

echo "Setting up dependencies for local development..."

mkdir -p external/

echo "Downloading simdjson.."
curl -L -o external/simdjson.h https://github.com/simdjson/simdjson/releases/download/v3.11.6/simdjson.h
curl -L -o external/simdjson.cpp https://github.com/simdjson/simdjson/releases/download/v3.11.6/simdjson.cpp

echo "Downloading CLI11..."
curl -sL https://github.com/CLIUtils/CLI11/archive/refs/tags/v2.4.2.tar.gz | tar xz -C external
mkdir external/CLI11/
mv external/CLI11-2.4.2/include/CLI/* external/CLI11/
rm -rf external/CLI11-2.4.2

echo "Downloading cpp-httplib"
curl -L -o external/httplib.h https://raw.githubusercontent.com/yhirose/cpp-httplib/v0.18.3/httplib.h

echo "Completed!"
sleep 2
exit
