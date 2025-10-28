# Makefile for AT-bot installation
# Simple installation script for AT-bot CLI tool

PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
LIBDIR = $(PREFIX)/lib/at-bot
DOCDIR = $(PREFIX)/share/doc/at-bot
MANDIR = $(PREFIX)/share/man/man1

.PHONY: all install uninstall test test-unit test-manual test-e2e clean docs help

all: help

help:
	@echo "AT-bot - Makefile targets:"
	@echo ""
	@echo "  make install      Install AT-bot to $(PREFIX)"
	@echo "  make uninstall    Remove AT-bot from $(PREFIX)"
	@echo "  make test         Run all tests (unit + e2e)"
	@echo "  make test-unit    Run unit test suite (12 tests, ~5 seconds)"
	@echo "  make test-manual  Run interactive manual test suite"
	@echo "  make test-e2e     Run automated end-to-end integration tests"
	@echo "  make docs         Generate complete documentation (PDF/HTML)"
	@echo "  make clean        Clean temporary files"
	@echo "  make help         Show this help message"
	@echo ""
	@echo "Install to custom location:"
	@echo "  make install PREFIX=/custom/path"
	@echo ""
	@echo "Test options (via scripts/test-unit.sh):"
	@echo "  make test-unit               # Run all unit tests"
	@echo "  AT_BOT_TEST_VERBOSE=1 make test-unit  # Verbose output"
	@echo "  AT_BOT_TEST_TIMEOUT=30 make test-unit # Custom timeout"

install:
	@echo "Installing AT-bot..."
	install -d $(BINDIR)
	install -d $(LIBDIR)
	install -d $(DOCDIR)
	install -m 755 bin/at-bot $(BINDIR)/at-bot
	install -m 644 lib/atproto.sh $(LIBDIR)/atproto.sh
	install -m 644 lib/config.sh $(LIBDIR)/config.sh
	install -m 644 lib/crypt.sh $(LIBDIR)/crypt.sh
	install -m 755 lib/doc.sh $(LIBDIR)/doc.sh
	install -m 644 README.md $(DOCDIR)/README.md
	install -m 644 LICENSE $(DOCDIR)/LICENSE
	@echo "AT-bot installed successfully!"
	@echo ""
	@echo "Run 'at-bot help' to get started."
	@echo "Run 'make docs' to generate documentation."

uninstall:
	@echo "Uninstalling AT-bot..."
	rm -f $(BINDIR)/at-bot
	rm -rf $(LIBDIR)
	rm -rf $(DOCDIR)
	@echo "AT-bot uninstalled successfully."

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
