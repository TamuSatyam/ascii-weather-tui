VCPKG_ROOT ?= $(HOME)/vcpkg
TOOLCHAIN := -DCMAKE_TOOLCHAIN_FILE=$(VCPKG_ROOT)/scripts/buildsystems/vcpkg.cmake

BUILD_DEBUG := build/debug
BUILD_RELEASE := build/release
BUILD_STATIC := build/static

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
    PLATFORM := linux
    TRIPLET := x64-linux
else ifeq ($(UNAME_S),Darwin)
    PLATFORM := macos
    TRIPLET := x64-osx
else
    PLATFORM := windows
    TRIPLET := x64-windows-static
endif

.PHONY: all
all: release

.PHONY: debug
debug:
	@echo "Building debug configuration..."
	@cmake -B $(BUILD_DEBUG) $(TOOLCHAIN) \
		-DCMAKE_BUILD_TYPE=Debug \
		-DVCPKG_TARGET_TRIPLET=$(TRIPLET)
	@cmake --build $(BUILD_DEBUG)

.PHONY: release
release:
	@echo "Building release configuration..."
	@cmake -B $(BUILD_RELEASE) $(TOOLCHAIN) \
		-DCMAKE_BUILD_TYPE=Release \
		-DVCPKG_TARGET_TRIPLET=$(TRIPLET)
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
	@echo "Configuring..."
	@cmake -B $(BUILD_STATIC) $(TOOLCHAIN) \
		-G Ninja \
		-DCMAKE_BUILD_TYPE=Release \
		-DVCPKG_TARGET_TRIPLET=$(TRIPLET) \
		-DCMAKE_C_FLAGS="-static" \
		-DCMAKE_CXX_FLAGS="-static" \
		-DCMAKE_EXE_LINKER_FLAGS="-static -static-libgcc -static-libstdc++" \
		-DBUILD_SHARED_LIBS=OFF \
		-DOPENSSL_USE_STATIC_LIBS=ON
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
			curl zip unzip tar perl bash build-base \
			openssl-libs-static openssl-dev zlib-static zlib-dev > /dev/null 2>&1; \
		echo "===> Setting up vcpkg..."; \
		if [ ! -d "vcpkg" ]; then \
			git clone --depth 1 https://github.com/Microsoft/vcpkg.git > /dev/null 2>&1; \
		fi; \
		export VCPKG_FORCE_SYSTEM_BINARIES=1; \
		if [ ! -f "vcpkg/vcpkg" ]; then \
			cd vcpkg && ./bootstrap-vcpkg.sh -disableMetrics > /dev/null 2>&1 && cd ..; \
		fi; \
		echo "===> Installing C++ dependencies..."; \
		./vcpkg/vcpkg install simdjson cli11 cpp-httplib --triplet=x64-linux > /dev/null 2>&1; \
		echo "===> Building..."; \
		cmake -S . -B build/static \
			-G Ninja \
			-DCMAKE_BUILD_TYPE=Release \
			-DCMAKE_TOOLCHAIN_FILE=/work/vcpkg/scripts/buildsystems/vcpkg.cmake \
			-DVCPKG_TARGET_TRIPLET=x64-linux \
			-DCMAKE_C_FLAGS="-static" \
			-DCMAKE_CXX_FLAGS="-static" \
			-DCMAKE_EXE_LINKER_FLAGS="-static -static-libgcc -static-libstdc++" \
			-DBUILD_SHARED_LIBS=OFF \
			-DOPENSSL_USE_STATIC_LIBS=ON > /dev/null 2>&1; \
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
	@ls -lh release/ascii-weather-tui-$(PLATFORM)-x64-static.tar.gz | awk '{print "Size:", $5}'
	@echo ""
	@echo "This binary works on ANY Linux distribution!"

.PHONY: package-compressed
package-compressed: docker-static
	@echo "Creating compressed release package (requires UPX)..."
	@if ! command -v upx &> /dev/null; then \
		echo "Error: UPX not found. Install with:"; \
		echo "  Alpine: apk add upx"; \
		echo "  Ubuntu: sudo apt install upx-ucl"; \
		echo "  macOS: brew install upx"; \
		exit 1; \
	fi
	@mkdir -p release
	@cp $(BUILD_STATIC)/ascii-weather-tui release/
	@echo "Compressing with UPX..."
	@upx --best --lzma release/ascii-weather-tui
	@cd release && tar -czf ascii-weather-tui-$(PLATFORM)-x64-static-upx.tar.gz ascii-weather-tui
	@echo ""
	@echo "Created: release/ascii-weather-tui-$(PLATFORM)-x64-static-upx.tar.gz"
	@echo ""
	@ls -lh release/ascii-weather-tui-$(PLATFORM)-x64-static-upx.tar.gz | awk '{print "Compressed size:", $5}'
	@echo ""
	@echo "Note: UPX-compressed binaries have slower startup time"

.PHONY: help
help:
	@echo "ASCII Weather TUI Build System"
	@echo "==========================================="
	@echo ""
	@echo "Standard Builds:"
	@echo "  make                - Build standard release"
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
	@echo "  make run-debug      - Build and run debug"
	@echo "  make run-release    - Build and run release"
	@echo "  make run-static     - Build and run static"
	@echo "  make package        - Create release tarball (~9-10 MB)"
	@echo "  make package-compressed - Create UPX-compressed tarball (~3-4 MB)"
	@echo "  make format         - Format code"