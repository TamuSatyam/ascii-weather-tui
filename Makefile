VCPKG_ROOT ?= $(HOME)/vcpkg
TOOLCHAIN := -DCMAKE_TOOLCHAIN_FILE=$(VCPKG_ROOT)/scripts/buildsystems/vcpkg.cmake

BUILD_DEBUG := build/debug
BUILD_RELEASE := build/release
BUILD_RELWITHDEBINFO := build/relwithdebinfo

.PHONY: all
all: release

.PHONY: debug
debug:
	@echo "Building debug configuration..."
	@cmake -B $(BUILD_DEBUG) $(TOOLCHAIN) -DCMAKE_BUILD_TYPE=Debug
	@cmake --build $(BUILD_DEBUG)

.PHONY: release
release:
	@echo "Building release configuration..."
	@cmake -B $(BUILD_RELEASE) $(TOOLCHAIN) -DCMAKE_BUILD_TYPE=Release
	@cmake --build $(BUILD_RELEASE)

.PHONY: relwithdebinfo
relwithdebinfo:
	@echo "Building RelWithDebInfo configuration..."
	@cmake -B $(BUILD_RELWITHDEBINFO) $(TOOLCHAIN) -DCMAKE_BUILD_TYPE=RelWithDebInfo
	@cmake --build $(BUILD_RELWITHDEBINFO)

.PHONY: clean
clean:
	@echo "Cleaning build directories..."
	@rm -rf build/

.PHONY: run-debug
run-debug: debug
	@./$(BUILD_DEBUG)/foolsafe

.PHONY: run-release
run-release: release
	@./$(BUILD_RELEASE)/foolsafe

.PHONY: install
install: release
	@cmake --install $(BUILD_RELEASE)

.PHONY: format
format:
	@echo "Formatting code..."
	@find src include -iname '*.cpp' -o -iname '*.h' | xargs clang-format -i

.PHONY: help
help:
	@echo "FoolSafe Build Targets:"
	@echo "  make              - Build release version (default)"
	@echo "  make debug        - Build debug version with sanitizers"
	@echo "  make release      - Build optimized release version"
	@echo "  make relwithdebinfo - Build optimized with debug symbols"
	@echo "  make clean        - Remove all build artifacts"
	@echo "  make run-debug    - Build and run debug version"
	@echo "  make run-release  - Build and run release version"
	@echo "  make format       - Format code with clang-format"
	@echo "  make help         - Show this help message"
