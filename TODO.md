# AT-bot Project TODO

This document tracks pending tasks, improvements, and features for the AT-bot project. Items are organized by priority and category.

## MCP (Model Context Protocol) Server Implementation

### MCP Server Architecture & Design
- [ ] Design MCP server architecture and communication protocol
- [ ] Define MCP tool schemas for all core operations
- [ ] Plan MCP server implementation (Python/Node.js/Go wrapper)
- [ ] Design authentication and session management for MCP
- [ ] Plan error handling and logging for MCP operations
- [ ] Document MCP integration points in core library

### MCP Server Development
- [ ] Implement MCP server with stdio communication
- [ ] Implement authentication tools (login, logout, whoami, is_authenticated)
- [ ] Implement content tools (post_create, post_reply, post_like, post_repost, post_delete)
- [ ] Implement feed tools (feed_read, feed_search, feed_timeline, feed_notifications)
- [ ] Implement profile tools (profile_get, profile_follow, profile_unfollow, profile_block)
- [ ] Add batch operation support (batch_post, batch_follow, batch_schedule)
- [ ] Add MCP server configuration and startup system
- [ ] Add MCP server logging and debugging capabilities

### MCP Server Testing & Documentation
- [ ] Write integration tests for MCP server
- [ ] Create MCP server configuration guide
- [ ] Write MCP client examples and tutorials
- [ ] Document MCP tool schemas and capabilities
- [ ] Create troubleshooting guide for MCP issues
- [ ] Add performance benchmarks for MCP operations

### MCP Ecosystem Integration
- [ ] Publish MCP server to package registries
- [ ] Create VS Code Copilot integration guide
- [ ] Submit to Claude Projects for discovery
- [ ] Create GitHub-hosted MCP registry entry
- [ ] Build MCP server examples for common use cases
- [ ] Establish MCP server security best practices guide

## Core Functionality

### Authentication & Session Management
- [x] ✅ **COMPLETED** - Add secure token storage using AES-256-CBC encryption (upgraded from base64)
- [x] ✅ **COMPLETED** - Implement debug mode for development (DEBUG=1 shows plaintext)
- [x] ✅ **COMPLETED** - Add backward compatibility for old base64 credentials
- [ ] Add session refresh capability for expired tokens
- [ ] Implement secure token storage using system keyring (optional enhancement)
- [ ] Add session validation before API calls
- [ ] Support multiple user sessions/profiles
- [ ] Add logout confirmation prompt
- [ ] Implement session timeout handling

### AT Protocol Integration
- [x] ✅ **COMPLETED** - Add post creation functionality (`at-bot post "message"`)
- [x] ✅ **COMPLETED** - Implement timeline/feed reading capabilities
- [ ] Add follow/unfollow user commands
- [ ] Support for image/media uploads in posts
- [ ] Add reply functionality for posts
- [ ] Implement search functionality
- [ ] Add support for custom feeds
- [ ] Support for blocks and mutes management

### Error Handling & Resilience  
- [ ] Improve network error handling and retry logic
- [ ] Add better validation for user inputs
- [ ] Implement graceful handling of API rate limits
- [ ] Add connection timeout configuration
- [ ] Better error messages for common failure scenarios
- [ ] Add debug mode for troubleshooting (`--debug` flag)

## User Experience

### CLI Interface
- [ ] Add bash/zsh completion scripts
- [ ] Implement interactive mode for complex operations
- [ ] Add configuration file support for user preferences
- [ ] Support for output formatting options (JSON, table, etc.)
- [ ] Add progress indicators for long-running operations
- [ ] Implement `--quiet` and `--verbose` flags
- [ ] Add color output configuration options

### Documentation & Help
- [x] ✅ **COMPLETED** - Documentation compilation system (`lib/doc.sh`)
- [x] ✅ **COMPLETED** - Generate combined markdown from all project docs
- [x] ✅ **COMPLETED** - Create `make docs` and `at-bot-docs` commands
- [x] ✅ **COMPLETED** - Make doc.sh dynamic with auto-discovery and pattern-based exclusions
- [x] ✅ **COMPLETED** - Exclude session documentation from compilation workflow
- [ ] Debug pandoc HTML/PDF conversion (YAML parsing issue)
- [ ] Add man page generation
- [ ] Create comprehensive usage examples
- [ ] Add troubleshooting guide to documentation
- [ ] Create video tutorials for common workflows
- [ ] Add FAQ section to README
- [ ] Document all environment variables

## Development & Code Quality

### Testing
- [x] ✅ **COMPLETED** - Expand test coverage for edge cases (encryption test suite added)
- [ ] Add integration tests with mock AT Protocol server
- [ ] Implement automated testing in CI/CD pipeline
- [ ] Add performance benchmarks and tests
- [ ] Create test fixtures for different scenarios
- [ ] Add security-focused tests (credential handling, permissions)

### Code Organization
- [ ] Refactor library functions into separate modules
- [ ] Create utility functions module for common operations
- [ ] Implement configuration management module
- [ ] Add logging framework for better debugging
- [ ] Create plugin/extension architecture
- [ ] Standardize function naming and organization

### Code Quality
- [ ] Add shellcheck integration to pre-commit hooks
- [ ] Implement code formatting standards (shfmt)
- [ ] Add comprehensive inline documentation
- [ ] Create API documentation for library functions
- [ ] Add type hints/documentation for function parameters
- [ ] Implement consistent error codes across modules

## Packaging & Distribution

### Installation
- [ ] Create Debian package (.deb)
- [ ] Add Homebrew formula for macOS
- [ ] Create Snap package for Linux
- [ ] Add Windows Subsystem for Linux (WSL) specific instructions
- [ ] Create Docker image for containerized usage
- [ ] Add Arch Linux AUR package

### Release Management
- [ ] Implement semantic versioning
- [ ] Create automated release pipeline
- [ ] Add changelog generation from git commits
- [ ] Create release notes template
- [ ] Add GPG signing for releases
- [ ] Implement automatic version bumping

## Security & Privacy

### Security Enhancements
- [ ] Implement proper credential rotation workflow
- [ ] Add support for hardware security keys (if supported by AT Protocol)
- [ ] Implement audit logging for security events
- [ ] Add permission system for different operations
- [ ] Create security scanning automation
- [ ] Add rate limiting protection for local usage

### Privacy Features
- [ ] Add data export functionality
- [ ] Implement local data cleanup commands
- [ ] Add privacy-focused configuration options
- [ ] Create GDPR compliance documentation
- [ ] Add telemetry opt-out mechanisms (if telemetry added)

## Performance & Scalability

### Performance
- [ ] Optimize JSON parsing for large responses
- [ ] Implement caching for frequently accessed data
- [ ] Add connection pooling for API requests
- [ ] Optimize startup time and memory usage
- [ ] Add performance profiling tools
- [ ] Implement lazy loading for large datasets

### Scalability
- [ ] Add support for batch operations
- [ ] Implement parallel processing for bulk actions
- [ ] Add queue system for rate-limited operations
- [ ] Create async operation support
- [ ] Add support for large-scale data exports

## Advanced Features

### Automation & Agents
- [ ] Implement webhook handler for external triggers
- [ ] Add scheduled task support (cron-like functionality)
- [ ] Create agent framework for automated workflows
- [ ] Add event-driven automation system
- [ ] Implement notification system for important events
- [ ] Add support for custom automation scripts

### Integration & Ecosystem
- [ ] Create GitHub Actions integration
- [ ] Add Slack/Discord bot capabilities
- [ ] Implement RSS feed generation from Bluesky content
- [ ] Add cross-platform social media posting
- [ ] Create API for third-party integrations
- [ ] Add support for custom AT Protocol implementations

### Advanced AT Protocol Features
- [ ] Implement AT-URI handling and resolution
- [ ] Add support for custom lexicons
- [ ] Implement federated data sync
- [ ] Add support for custom PDS (Personal Data Servers)
- [ ] Implement advanced query capabilities
- [ ] Add support for AT Protocol streaming APIs

## Infrastructure & DevOps

### Development Environment
- [ ] Create development container (devcontainer)
- [ ] Add GitHub Codespaces configuration
- [ ] Implement local development setup automation
- [ ] Create development dependency management
- [ ] Add code coverage reporting
- [ ] Implement automated dependency updates

### CI/CD Pipeline
- [ ] Add multi-platform testing (Linux, macOS, Windows/WSL)
- [ ] Implement automated security scanning
- [ ] Add performance regression testing
- [ ] Create automated deployment pipeline
- [ ] Add integration testing with real AT Protocol services
- [ ] Implement canary deployment strategy

### Monitoring & Observability
- [ ] Add basic telemetry (with privacy controls)
- [ ] Implement error reporting system
- [ ] Add usage analytics (opt-in)
- [ ] Create health check endpoints for service monitoring
- [ ] Add performance metrics collection
- [ ] Implement alerting for critical issues

## Community & Contribution

### Community Building
- [ ] Create contributor onboarding guide
- [ ] Add code of conduct
- [ ] Implement issue templates
- [ ] Create discussion forums/channels
- [ ] Add contributor recognition system
- [ ] Create roadmap voting system

### Documentation & Education
- [ ] Create comprehensive API documentation
- [ ] Add code architecture documentation
- [ ] Create video tutorial series
- [ ] Add blog post series about AT Protocol
- [ ] Create example use cases and recipes
- [ ] Add internationalization support for documentation

## Compliance & Legal

### Legal & Compliance
- [ ] Review and update license terms
- [ ] Add privacy policy if collecting any data
- [ ] Create terms of service for hosted services (if any)
- [ ] Add DMCA compliance documentation
- [ ] Review export control regulations compliance
- [ ] Add accessibility compliance (WCAG guidelines for any web interfaces)

## Future Considerations

### Long-term Vision
- [ ] Evaluate GUI application development
- [ ] Consider mobile app companion
- [ ] Explore browser extension possibilities
- [ ] Investigate IoT device integration
- [ ] Consider enterprise features and support
- [ ] Evaluate federation with other protocols

### Technology Evolution
- [ ] Stay updated with AT Protocol specification changes
- [ ] Monitor Bluesky platform evolution
- [ ] Evaluate new shell/scripting technologies
- [ ] Consider language migration if needed (Rust, Go, etc.)
- [ ] Monitor decentralized web technology trends

---

## Priority Legend

- **High Priority**: Critical for v1.0 release
- **Medium Priority**: Important for user experience
- **Low Priority**: Nice to have, future considerations

## How to Contribute

1. Pick an item from this TODO list
2. Create an issue to discuss the implementation approach
3. Fork the repository and create a feature branch
4. Implement the feature following the [STYLE.md](STYLE.md) guidelines
5. Add tests for your changes
6. Submit a pull request

For more details, see [CONTRIBUTING.md](doc/CONTRIBUTING.md).

---

*Last updated: October 28, 2025*
*This is a living document - items may be added, removed, or reprioritized based on community feedback and project evolution.*