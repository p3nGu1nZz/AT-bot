# Makefile for atproto installation
# Simple installation script for atproto CLI tool

PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
LIBDIR = $(PREFIX)/lib/atproto
DOCDIR = $(PREFIX)/share/doc/atproto
MANDIR = $(PREFIX)/share/man/man1

.PHONY: all install uninstall test test-unit test-manual test-e2e clean docs help

all: help

help:
	@echo "atproto - Makefile targets:"
	@echo ""
	@echo "  make install      Install atproto (interactive, optionally includes MCP)"
	@echo "  make uninstall    Remove atproto from $(PREFIX)"
	@echo "  make test         Run all tests (unit + e2e)"
	@echo "  make test-unit    Run unit test suite (12 tests, ~5 seconds)"
	@echo "  make test-manual  Run interactive manual test suite"
	@echo "  make test-e2e     Run automated end-to-end integration tests"
	@echo "  make docs         Generate complete documentation (PDF/HTML)"
	@echo "  make clean        Clean temporary files"
	@echo "  make help         Show this help message"
	@echo ""
	@echo "Install options:"
	@echo "  make install               # Interactive installation"
	@echo "  ./install.sh --mcp         # Install with MCP server"
	@echo "  PREFIX=/custom ./install.sh  # Custom install location"
	@echo ""
	@echo "Test options (via scripts/test-unit.sh):"
	@echo "  make test-unit               # Run all unit tests"
	@echo "  ATPROTO_TEST_VERBOSE=1 make test-unit  # Verbose output"
	@echo "  ATPROTO_TEST_TIMEOUT=30 make test-unit # Custom timeout"

install:
	@bash install.sh

uninstall:
	@echo "Uninstalling atproto..."
	rm -f $(BINDIR)/atproto
	# MCP server is now integrated into main atproto binary
	rm -rf $(LIBDIR)
	rm -rf $(DOCDIR)
	@echo "atproto uninstalled successfully."

test:
	@echo "Running all tests..."
	@bash tests/run_tests.sh

test-unit:
	@echo "Running unit test suite..."
	@bash scripts/test-unit.sh

test-manual:
	@echo "Starting interactive manual test suite..."
	@bash tests/manual_test.sh

test-e2e:
	@echo "Running automated end-to-end integration tests..."
	@bash tests/atp_test.sh

docs:
	@echo "Generating documentation..."
	@bash lib/doc.sh
	@echo ""
	@echo "Documentation available in dist/docs/"

clean:
	@echo "Cleaning temporary files..."
	@find . -name '*~' -delete
	@find . -name '*.swp' -delete
	@rm -rf dist/docs
	@echo "Clean complete."
