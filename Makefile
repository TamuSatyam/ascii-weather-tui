BUILD_DEBUG := build/debug
BUILD_RELEASE := build/release
BUILD_STATIC := build/static

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
    PLATFORM := linux
else ifeq ($(UNAME_S),Darwin)
    PLATFORM := macos
else
    PLATFORM := windows
endif

.PHONY: all
all: deps release

.PHONY: deps
deps:
	@echo "Downloading dependencies..."
	@mkdir -p external/CLI11/include/CLI
	@echo "  - simdjson..."
	@curl -sL -o external/simdjson.h https://github.com/simdjson/simdjson/releases/download/v3.11.6/simdjson.h
	@curl -sL -o external/simdjson.cpp https://github.com/simdjson/simdjson/releases/download/v3.11.6/simdjson.cpp
	@echo "  - CLI11 (full tree)..."
	@curl -sL https://github.com/CLIUtils/CLI11/archive/refs/tags/v2.4.2.tar.gz | tar xz -C external
	@mkdir external/CLI11/
	@mv external/CLI11-2.4.2/include/CLI/* external/CLI11/
	@rm -rf external/CLI11-2.4.2
	@echo "  - cpp-httplib..."
	@curl -sL -o external/httplib.h https://raw.githubusercontent.com/yhirose/cpp-httplib/v0.18.3/httplib.h
	@echo "Dependencies ready"

.PHONY: debug
debug: deps
	@echo "Building debug configuration..."
	@cmake -B $(BUILD_DEBUG) \
		-DCMAKE_BUILD_TYPE=Debug
	@cmake --build $(BUILD_DEBUG)

.PHONY: release
release: deps
	@echo "Building release configuration..."
	@cmake -B $(BUILD_RELEASE) \
		-DCMAKE_BUILD_TYPE=Release
	@cmake --build $(BUILD_RELEASE)

.PHONY: static
static:
	@echo "==========================================="
	@echo "Building Universal Static Binary"
	@echo "==========================================="
	@if [ "$(PLATFORM)" != "linux" ]; then \
		echo "Error: Universal static builds require Alpine Linux"; \
		echo "Use: make docker-static"; \
		exit 1; \
	fi
	@$(MAKE) deps
	@echo "Configuring..."
	@cmake -B $(BUILD_STATIC) \
		-G Ninja \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_C_FLAGS="-static" \
		-DCMAKE_CXX_FLAGS="-static" \
		-DCMAKE_EXE_LINKER_FLAGS="-static" \
		-DBUILD_SHARED_LIBS=OFF
	@echo "Building..."
	@cmake --build $(BUILD_STATIC) --parallel $(shell nproc 2>/dev/null || echo 4)
	@echo "Stripping..."
	@strip $(BUILD_STATIC)/ascii-weather-tui
	@echo ""
	@$(MAKE) verify-static

.PHONY: docker-static
docker-static:
	@echo "==========================================="
	@echo "Building Universal Static Binary (Docker)"
	@echo "==========================================="
	@echo ""
	@if ! command -v docker &> /dev/null; then \
		echo "Error: Docker is required"; \
		echo "Install from: https://docs.docker.com/get-docker/"; \
		exit 1; \
	fi
	@docker run --rm -v $(PWD):/work -w /work alpine:latest sh -c ' \
		set -e; \
		echo "===> Installing dependencies..."; \
		apk add --no-cache git cmake ninja g++ pkgconfig linux-headers \
			curl bash build-base \
			openssl-libs-static openssl-dev zlib-static zlib-dev > /dev/null 2>&1; \
		echo "===> Downloading C++ dependencies..."; \
		mkdir -p external/CLI11/CLI11; \
		curl -sL -o external/simdjson.h https://github.com/simdjson/simdjson/releases/download/v3.11.6/simdjson.h; \
		curl -sL -o external/simdjson.cpp https://github.com/simdjson/simdjson/releases/download/v3.11.6/simdjson.cpp; \
		curl -sL https://github.com/CLIUtils/CLI11/archive/refs/tags/v2.4.2.tar.gz | tar xz -C external; \
		mv external/CLI11-2.4.2/include/CLI/* external/CLI11/CLI11/; \
		rm -rf external/CLI11-2.4.2; \
		curl -sL -o external/httplib.h https://raw.githubusercontent.com/yhirose/cpp-httplib/v0.18.3/httplib.h; \
		echo "===> Building..."; \
		cmake -S . -B build/static \
			-G Ninja \
			-DCMAKE_BUILD_TYPE=Release \
			-DCMAKE_C_FLAGS="-static" \
			-DCMAKE_CXX_FLAGS="-static" \
			-DCMAKE_EXE_LINKER_FLAGS="-static" \
			-DBUILD_SHARED_LIBS=OFF > /dev/null 2>&1; \
		cmake --build build/static --parallel $$(nproc) > /dev/null 2>&1; \
		strip build/static/ascii-weather-tui; \
		echo "===> Build complete!"; \
	'
	@echo ""
	@$(MAKE) verify-static
	@$(MAKE) test-static

.PHONY: verify-static
verify-static:
	@echo "==========================================="
	@echo "Binary Analysis"
	@echo "==========================================="
	@echo ""
	@echo "File info:"
	@file $(BUILD_STATIC)/ascii-weather-tui
	@echo ""
	@echo "Size:"
	@ls -lh $(BUILD_STATIC)/ascii-weather-tui | awk '{print $$5}'
	@echo ""
	@echo "Checking for dynamic dependencies:"
	@if ldd $(BUILD_STATIC)/ascii-weather-tui 2>&1 | grep -q "not a dynamic executable"; then \
		echo "✓ SUCCESS: Binary is fully static!"; \
	elif ldd $(BUILD_STATIC)/ascii-weather-tui 2>&1 | grep -q "statically linked"; then \
		echo "✓ SUCCESS: Binary is statically linked!"; \
	else \
		echo "✗ WARNING: Binary has dynamic dependencies:"; \
		ldd $(BUILD_STATIC)/ascii-weather-tui 2>&1; \
	fi
	@echo ""

.PHONY: test-static
test-static:
	@echo "==========================================="
	@echo "Testing Compatibility"
	@echo "==========================================="
	@echo ""
	@if ! command -v docker &> /dev/null; then \
		echo "Docker not available, skipping tests"; \
		exit 0; \
	fi
	@test_distro() { \
		printf "%-20s ... " "$$1"; \
		if docker run --rm -v $(PWD):/test "$$1" /test/$(BUILD_STATIC)/ascii-weather-tui --help > /dev/null 2>&1; then \
			echo "✓ Works"; \
		else \
			echo "✗ Failed"; \
		fi; \
	}; \
	test_distro ubuntu:18.04; \
	test_distro ubuntu:20.04; \
	test_distro ubuntu:22.04; \
	test_distro ubuntu:24.04; \
	test_distro debian:10; \
	test_distro debian:11; \
	test_distro debian:12; \
	test_distro fedora:38; \
	test_distro alpine:latest

.PHONY: clean
clean:
	@echo "Cleaning build directories..."
	@rm -rf build/

.PHONY: clean-all
clean-all: clean
	@echo "Cleaning dependencies..."
	@rm -rf external/

.PHONY: run-debug
run-debug: debug
	@./$(BUILD_DEBUG)/ascii-weather-tui

.PHONY: run-release
run-release: release
	@./$(BUILD_RELEASE)/ascii-weather-tui

.PHONY: run-static
run-static: docker-static
	@./$(BUILD_STATIC)/ascii-weather-tui

.PHONY: format
format:
	@echo "Formatting code..."
	@find src include -iname '*.cpp' -o -iname '*.h' | xargs clang-format -i

.PHONY: package
package: docker-static
	@echo "Creating release package..."
	@mkdir -p release
	@cp $(BUILD_STATIC)/ascii-weather-tui release/
	@cd release && tar -czf ascii-weather-tui-$(PLATFORM)-x64-static.tar.gz ascii-weather-tui
	@echo "Created: release/ascii-weather-tui-$(PLATFORM)-x64-static.tar.gz"
	@echo ""
	@ls -lh release/ascii-weather-tui-$(PLATFORM)-x64-static.tar.gz | awk '{print "Size:", $$5}'
	@echo ""
	@echo "This binary works on ANY Linux distribution!"

.PHONY: help
help:
	@echo "ASCII Weather TUI Build System (No vcpkg!)"
	@echo "==========================================="
	@echo ""
	@echo "Setup:"
	@echo "  make deps           - Download dependencies (simdjson, CLI11, httplib)"
	@echo ""
	@echo "Standard Builds:"
	@echo "  make                - Build release (downloads deps automatically)"
	@echo "  make debug          - Build debug version"
	@echo "  make release        - Build release version"
	@echo ""
	@echo "Universal Static Build (Recommended):"
	@echo "  make docker-static  - Build universal static binary (Alpine/Docker)"
	@echo "  make static         - Build static (requires Alpine Linux)"
	@echo ""
	@echo "Testing & Verification:"
	@echo "  make verify-static  - Verify static binary"
	@echo "  make test-static    - Test on multiple distros"
	@echo ""
	@echo "Utilities:"
	@echo "  make clean          - Remove build artifacts"
	@echo "  make clean-all      - Remove build artifacts AND dependencies"
	@echo "  make run-debug      - Build and run debug"
	@echo "  make run-release    - Build and run release"
	@echo "  make run-static     - Build and run static"
	@echo "  make package        - Create release tarball"
	@echo "  make format         - Format code"