# Makefile for AT-bot installation
# Simple installation script for AT-bot CLI tool

PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
LIBDIR = $(PREFIX)/lib/at-bot
DOCDIR = $(PREFIX)/share/doc/at-bot
MANDIR = $(PREFIX)/share/man/man1

.PHONY: all install uninstall test clean help

all: help

help:
	@echo "AT-bot - Makefile targets:"
	@echo ""
	@echo "  make install      Install AT-bot to $(PREFIX)"
	@echo "  make uninstall    Remove AT-bot from $(PREFIX)"
	@echo "  make test         Run tests"
	@echo "  make clean        Clean temporary files"
	@echo "  make help         Show this help message"
	@echo ""
	@echo "Install to custom location:"
	@echo "  make install PREFIX=/custom/path"

install:
	@echo "Installing AT-bot..."
	install -d $(BINDIR)
	install -d $(LIBDIR)
	install -d $(DOCDIR)
	install -m 755 bin/at-bot $(BINDIR)/at-bot
	install -m 644 lib/atproto.sh $(LIBDIR)/atproto.sh
	install -m 644 README.md $(DOCDIR)/README.md
	install -m 644 LICENSE $(DOCDIR)/LICENSE
	@echo "AT-bot installed successfully!"
	@echo ""
	@echo "Run 'at-bot help' to get started."

uninstall:
	@echo "Uninstalling AT-bot..."
	rm -f $(BINDIR)/at-bot
	rm -rf $(LIBDIR)
	rm -rf $(DOCDIR)
	@echo "AT-bot uninstalled successfully."

test:
	@echo "Running tests..."
	@bash tests/run_tests.sh

clean:
	@echo "Cleaning temporary files..."
	@find . -name '*~' -delete
	@find . -name '*.swp' -delete
	@echo "Clean complete."
