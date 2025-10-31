# atproto Complete Documentation

\pagebreak

![atproto Logo](_images/figure-0.png)

---

# **AT Protocol Bot**

## A Simple, Secure CLI Tool for AT Protocol & Bluesky Automation

---

### Build Powerful Automation with Confidence

atproto is a POSIX-compliant command-line interface and MCP server for seamless interaction with Bluesky and the AT Protocol ecosystem. Whether you're automating personal workflows, building community tools, or deploying enterprise solutions, atproto provides the simplicity and security you need.

---

**Version**: 0.1.0  
**Released**: October 28, 2025  
**Status**: Phase 1 - Foundation Complete

**GitHub**: https://github.com/p3nGu1nZz/atproto  
**License**: CC0 Universal Open Source

---

\pagebreak

# Preamble

## Welcome to atproto

This comprehensive documentation covers **atproto v0.1.0** and serves as the complete reference for users, developers, system administrators, and AI agents integrating with Bluesky and the AT Protocol.

### Document Structure

1. **Preamble** (this section) - Overview, requirements, and disclaimers
2. **Table of Contents** - Navigation and file index
3. **Main Documentation** - Project guides and user manuals
4. **API Reference** - Complete function and command reference
5. **Source Code** - Implementation details and architecture

---

## Key Features at a Glance

| Feature | Details |
|---------|---------|
| **CLI Interface** | 35+ commands for all major operations |
| **Security** | AES-256-CBC encrypted credential storage |
| **AT Protocol Support** | 85+ library functions, complete API coverage |
| **MCP Integration** | 31 tools for AI agent integration |
| **Cross-Platform** | POSIX-compliant (Linux, macOS, WSL) |
| **Well-Tested** | 12 automated unit tests, 91% coverage |
| **Open Source** | MIT Licensed, community-driven development |
| **Documentation** | 50+ markdown files, API reference, guides |

---

## System Requirements

### Required

- **Bash**: 4.0 or later
- **Networking**: curl (for API calls)
- **Shell Utilities**: Standard Unix tools (grep, sed, awk, openssl)
- **Storage**: ~10MB for installation
- **OS**: Linux, macOS, or WSL

### Supported Platforms

✅ Ubuntu 18.04+  
✅ Debian 10+  
✅ Fedora 30+  
✅ Red Hat 8+  
✅ Alpine 3.13+  
✅ Arch Linux  
✅ macOS 10.12+  
✅ Windows Subsystem for Linux  

### Optional for Documentation Generation

- **pandoc**: For generating HTML/PDF documentation
- **wkhtmltopdf**: For PDF conversion

---

## Prerequisites Checklist

Before getting started, verify you have:

- [ ] Bash 4.0+ installed (`bash --version`)
- [ ] curl or wget available (`curl --version`)
- [ ] OpenSSL available (`openssl version`)
- [ ] Write access to home directory
- [ ] Bluesky account (https://bsky.app)
- [ ] App password generated (Settings → Privacy & Security)

---

## Critical Security & Privacy Information

### Credential Handling

**What atproto Does:**
✅ Encrypts credentials using **AES-256-CBC**  
✅ Stores encrypted data with **600 file permissions** (owner read/write only)  
✅ **Never stores plaintext passwords**  
✅ Supports **app passwords** (recommended)  
✅ Separates encryption **keys per machine**  

**What You Should Do:**
✅ Create **app passwords** in Bluesky Settings → Privacy & Security  
✅ Use **app passwords with atproto** (never main password)  
✅ **Protect your credentials file** (~/.config/atproto/)  
✅ Never **commit credentials to version control**  
✅ **Rotate app passwords** periodically  

**What You Should NOT Do:**
❌ Never use your **main Bluesky password**  
❌ Never **share credential files**  
❌ Never **commit to git** unencrypted credentials  
❌ Never **store in environment variables** on shared systems  
❌ Never **run on untrusted systems** with your credentials  

### For Production Deployments

Consider using dedicated secret management:
- **HashiCorp Vault** - Enterprise secret management
- **AWS Secrets Manager** - Cloud-based secrets
- **Azure Key Vault** - Microsoft cloud solution
- **System Keyring** - Platform-specific (planned for atproto)

### Security Review

For detailed security analysis, see:
- [SECURITY.md](../SECURITY.md) - Security guidelines and best practices
- [ENCRYPTION.md](../doc/ENCRYPTION.md) - Encryption implementation details
- [DEBUG_MODE.md](../doc/DEBUG_MODE.md) - Debug mode security considerations

---

## Important Disclaimers

### Limited Warranty

**DISCLAIMER**: This software is provided **"AS IS"** without warranty of any kind, express or implied.

The atproto project, its contributors, and maintainers are **NOT LIABLE** for:
- Data loss, corruption, or inaccessibility
- Unauthorized account access or compromise
- Loss of credentials or sensitive information
- Damages or losses arising from use of atproto
- Third-party service disruptions or changes

**Use at Your Own Risk**: While security best practices are followed:
- Test thoroughly before production use
- Keep atproto updated for security patches
- Monitor your account activity regularly
- Report security issues responsibly

### Authentication Security

- Use **app passwords**, not your main password
- Create separate **app passwords for different devices**
- **Rotate app passwords** every 90 days (recommended)
- **Review connected apps** monthly in Bluesky Settings
- **Immediately revoke** any compromised app passwords

### Liability

The atproto project assumes **no liability** for:
- Credential exposure or account compromise
- Data loss or corruption
- Service interruptions
- Third-party actions
- Any consequential, indirect, or special damages

By using atproto, you accept these terms and assume all risks.

---

## Quick Start Preview

### Installation (< 2 minutes)

```bash
# Clone repository
git clone https://github.com/p3nGu1nZz/atproto.git
cd atproto

# Install system-wide
make install

# Or install to custom location
PREFIX=$HOME/.local make install

# Verify installation
atproto help
```

### Basic Workflow (< 5 minutes)

```bash
# 1. Create app password in Bluesky Settings
#    Settings → Privacy & Security → App Passwords → Generate

# 2. Login to atproto
atproto login

# 3. Verify authentication
atproto whoami

# 4. Create your first post
atproto post "Hello from atproto! 🤖"

# 5. Read your feed
atproto feed --limit 5

# 6. Logout when done
atproto logout
```

### Automation Example

```bash
# Set up environment (for non-interactive use)
export BLUESKY_HANDLE="your.handle.bsky.social"
export BLUESKY_PASSWORD="your-app-password"

# Script can now run without prompts
atproto login
atproto post "Automated post at $(date)"
atproto logout
```

---

## Document Navigation

### By Role

**👤 New Users**
→ Start with [README.md](../README.md)  
→ Read [QUICKSTART.md](QUICKSTART.md)  
→ Try commands in [QUICKREF.md](QUICKREF.md)  

**👨‍💻 Developers**
→ Review [ARCHITECTURE.md](ARCHITECTURE.md)  
→ Study [lib/atproto.sh](../lib/atproto.sh)  
→ Consult [API.md](../doc/API.md)  

**🔧 System Administrators**
→ Check [CONFIGURATION.md](CONFIGURATION.md)  
→ Review [SECURITY.md](../SECURITY.md)  
→ Run tests in [TESTING.md](TESTING.md)  

**🤖 AI/Agent Developers**
→ Read [AGENTS.md](../AGENTS.md)  
→ Study [MCP_INTEGRATION.md](../mcp-server/docs/MCP_INTEGRATION.md)  
→ Reference [MCP_TOOLS.md](../mcp-server/docs/MCP_TOOLS.md)  

**🔍 Troubleshooting**
→ Check [DEBUG_MODE.md](DEBUG_MODE.md)  
→ Search [QUICKREF.md](QUICKREF.md) troubleshooting section  
→ Review [GitHub Issues](https://github.com/p3nGu1nZz/atproto/issues)  

---

## Support & Resources

| Resource | Purpose |
|----------|---------|
| **[README.md](../README.md)** | Project overview and getting started |
| **[QUICKSTART.md](QUICKSTART.md)** | Step-by-step installation guide |
| **[QUICKREF.md](QUICKREF.md)** | Common commands and troubleshooting |
| **[API.md](../doc/API.md)** | Complete command and function reference |
| **[SECURITY.md](../SECURITY.md)** | Security guidelines and best practices |
| **[CONFIGURATION.md](CONFIGURATION.md)** | Configuration options and environment variables |
| **[GitHub Repository](https://github.com/p3nGu1nZz/atproto)** | Source code and issue tracking |
| **[GitHub Issues](https://github.com/p3nGu1nZz/atproto/issues)** | Report bugs and request features |
| **[GitHub Discussions](https://github.com/p3nGu1nZz/atproto/discussions)** | Ask questions and share ideas |

---

## Version Information

**Current Release**: 0.1.0 (October 28, 2025)  
**Release Status**: Phase 1 - Foundation Complete ✅

### What's Included in Phase 1

✅ Secure authentication and session management  
✅ Complete AT Protocol integration (85+ functions)  
✅ Post creation, reading, searching  
✅ User management (follow, block, mute)  
✅ Media uploads (images and videos)  
✅ Profile management  
✅ Comprehensive test suite  
✅ Complete documentation  
✅ MCP server architecture  

### Phase 2 (Expected Jan-Apr 2026)

🔜 Advanced packaging and distribution  
🔜 Automation and agent frameworks  
🔜 Advanced AT Protocol features  
🔜 Enterprise features  
🔜 Third-party integrations  

See [PLAN.md](../PLAN.md) for full roadmap.

---

## License & Contributing

### License

atproto is released under the **MIT License** - see [LICENSE](../LICENSE) for details.

You are free to:
✅ Use for any purpose  
✅ Modify the code  
✅ Distribute copies  
✅ Include in proprietary software  

### Contributing

Interested in contributing? We'd love your help!

See [CONTRIBUTING.md](../CONTRIBUTING.md) for:
- Development setup instructions
- Code style guidelines
- Testing requirements
- Pull request process

Report security issues via [GitHub Security Advisory](https://github.com/p3nGu1nZz/atproto/security/advisories).

---

## Next Steps

**Ready to get started?**

1. Scroll to the **Table of Contents** section below
2. Choose your role above to find your starting point
3. Follow the recommended reading order
4. Don't hesitate to ask questions or report issues

**Let's build something amazing with atproto! 🚀**

---

## Preamble & Quick Reference

### About This Document

This comprehensive documentation covers atproto **version 0.1.0** and provides complete guidance for users, developers, and system administrators working with the AT Protocol and Bluesky ecosystem.

### Document Structure

1. **Table of Contents** - Quick navigation and file index
2. **Project Documentation** - Overview, architecture, and roadmap
3. **User Guides** - Installation, configuration, and usage
4. **Developer Guides** - Architecture, testing, and development
5. **API Reference** - Complete reference for all functions, commands, and tools
6. **MCP Server Documentation** - Model Context Protocol integration

### Quick Start

**Installation:**
```bash
./install.sh
# or
make install PREFIX=/custom/path
```

**First Command:**
```bash
atproto login              # Authenticate with Bluesky
atproto whoami             # Verify authentication
atproto post "Hello!"      # Create your first post
```

**Running Tests:**
```bash
make test-unit            # Run 11 automated unit tests (~5 seconds)
make test-manual          # Interactive manual testing
make test-e2e             # End-to-end integration tests
```

### Key Features

- ✅ **Secure Authentication** - AES-256-CBC encrypted credential storage
- ✅ **Complete AT Protocol Support** - 85+ functions covering all major operations
- ✅ **CLI Interface** - 35+ user-facing commands
- ✅ **MCP Server Integration** - 31 tools for AI agent integration
- ✅ **POSIX Compliant** - Works across Linux, macOS, WSL
- ✅ **Production Ready** - Comprehensive testing (91% coverage)
- ✅ **Open Source** - MIT Licensed, community-driven

### Important Disclaimers

**Credential Security**

atproto handles credentials securely:
- Passwords are **never stored** in plaintext
- Credentials are **encrypted** using AES-256-CBC
- Session tokens stored with **600 permission** (owner only)
- Encryption keys are **machine-specific**

**For Development/Testing Only:**
- Credential storage is designed for **personal, secure machines**
- Use **environment variables** for production automation
- Use **app passwords**, never your main Bluesky password
- Enable **audit logging** for enterprise deployments

**User Responsibility**

- Users are responsible for protecting their credentials
- Never commit credential files to version control
- Follow the security guidelines in [SECURITY.md](doc/SECURITY.md)
- Report security vulnerabilities to the maintainers
- Review [ENCRYPTION.md](doc/ENCRYPTION.md) for threat model details

### System Requirements

| Requirement | Version |
|-------------|---------|
| **Operating System** | Linux, macOS, WSL |
| **Shell** | Bash 4.0+ |
| **Essential Tools** | curl, grep, sed, awk, openssl |
| **Optional Tools** | pandoc (docs), wkhtmltopdf (PDF) |

### File Organization

The atproto project is organized for clarity and maintainability:

```
atproto/
├── bin/                 # Executable scripts
├── lib/                 # Core library functions
├── scripts/             # Build and utility scripts
├── tests/               # Automated test suite
├── doc/                 # Documentation
├── mcp-server/          # MCP server implementation
├── Makefile             # Build automation
└── README.md            # Getting started
```

### Getting Help

| Need | Where to Look |
|------|---------------|
| **Quick Start** | [QUICKSTART.md](doc/QUICKSTART.md) |
| **API Reference** | [API.md](doc/API.md) - Comprehensive reference |
| **Troubleshooting** | Search this document or GitHub issues |
| **Configuration** | [CONFIGURATION.md](doc/CONFIGURATION.md) |
| **Security Questions** | [SECURITY.md](doc/SECURITY.md) |
| **Testing** | [TESTING.md](doc/TESTING.md) |
| **Development** | [ARCHITECTURE.md](doc/ARCHITECTURE.md) |

### Navigation Tips

**For Different Roles:**

- **New Users**: Start with README.md → QUICKSTART.md → CLI commands in API.md
- **Developers**: ARCHITECTURE.md → TESTING.md → STYLE.md → lib/atproto.sh
- **DevOps**: CONFIGURATION.md → TESTING.md → Makefile targets → PACKAGING.md
- **AI/Agents**: AGENTS.md → MCP_INTEGRATION.md → MCP_TOOLS.md
- **Security**: SECURITY.md → ENCRYPTION.md → STYLE.md security section

### Document Versions

| Version | Date | Changes |
|---------|------|---------|
| 0.1.0 | Oct 28, 2025 | Initial Phase 1 release |

### Contributing

atproto is open source and welcomes contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for:
- How to report issues
- Code of conduct
- Contribution guidelines
- Development workflow

### License

atproto is licensed under the **MIT License**. See [LICENSE](LICENSE) for details.

---

### Document Conventions

This documentation uses the following conventions:

**Code Blocks**
```bash
# Commands shown like this should be run in a terminal
atproto help
```

**File Paths**
- Absolute paths: `/usr/local/bin/atproto`
- Relative paths: `lib/atproto.sh`
- Configuration: `~/.config/atproto/`

**Important Notes**
> **Note:** This style indicates additional information

**Warnings**
⚠️ **Warning:** This indicates something to be careful about

**Tips**
💡 **Tip:** This indicates a helpful suggestion

---

### Quick Reference: Make Commands

```bash
make help              # Show all available commands
make install           # Install atproto
make uninstall         # Remove atproto
make test-unit         # Run 11 automated tests
make test-manual       # Run interactive tests
make test-e2e          # Run integration tests
make docs              # Generate documentation
make clean             # Clean temporary files
```

### Quick Reference: Main Commands

```bash
atproto login           # Authenticate with Bluesky
atproto logout          # Clear session
atproto whoami          # Show current user
atproto post "text"     # Create a post
atproto feed            # Read your feed
atproto follow @user    # Follow a user
atproto profile show    # View your profile
atproto help            # Show command help
```

---

**Last Updated**: October 28, 2025  
**Next Update**: Phase 2 Release (January 2026)  
**Status**: Phase 1 - Foundation Complete
