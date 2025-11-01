# atproto Project TODO

This document tracks pending tasks, improvements, and features for the atproto project. Items are organized by priority and category.

## 🚀 Current Focus: MCP Publishing & Phase 2 Planning (November 1, 2025)

**Status**: Phase 1 COMPLETE ✅ | MCP Server OPERATIONAL ✅ | Publishing IN PROGRESS

**Recent Milestones:**
- ✅ MCP server fully operational and tested (October 31, 2025)
- ✅ Critical facet/UTF-8 bugs fixed (November 1, 2025)
- ✅ Input validation library added (November 1, 2025)
- ✅ Announcement posted to Bluesky (November 1, 2025)

**Next Steps:**
- Publish to NPM (requires credentials)
- Submit to MCP registry
- Begin Phase 2 features (packaging, automation)

**See Active Todo List Below** for detailed implementation steps.

---

## MCP (Model Context Protocol) Server Implementation

### MCP Server Architecture & Design
- [x] ✅ **COMPLETED** - Design MCP server architecture and communication protocol
- [x] ✅ **COMPLETED** - Define MCP tool schemas for all core operations
- [x] ✅ **COMPLETED** - Plan MCP server implementation (Node.js/TypeScript chosen) (October 31, 2025)
- [x] ✅ **COMPLETED** - Design authentication and session management for MCP (October 31, 2025)
- [x] ✅ **COMPLETED** - Plan error handling and logging for MCP operations (October 31, 2025)
- [x] ✅ **COMPLETED** - Document MCP integration points in core library (October 31, 2025)

### MCP Server Development
- [x] ✅ **COMPLETED** - Implement MCP server with stdio communication
- [x] ✅ **COMPLETED** - Implement authentication tools (login, logout, whoami, is_authenticated)
- [x] ✅ **COMPLETED** - Implement content tools (post_create, post_reply, post_like, post_repost, post_delete)
- [x] ✅ **COMPLETED** - Implement feed tools (feed_read, feed_search, feed_timeline, feed_notifications)
- [x] ✅ **COMPLETED** - Implement profile tools (profile_get, profile_follow, profile_unfollow, profile_block)
- [x] ✅ **COMPLETED** - Install Node.js dependencies and build MCP server (October 31, 2025)
- [x] ✅ **COMPLETED** - Test MCP server with stdio transport (October 31, 2025)
- [x] ✅ **COMPLETED** - Verify shell command execution from MCP tools (October 31, 2025)
- [x] ✅ **COMPLETED** - Create MCP server configuration file template (October 31, 2025)
- [x] ✅ **COMPLETED** - Add MCP server wrapper script (atproto-mcp) (October 31, 2025)
- [x] ✅ **COMPLETED** - Test end-to-end authentication flow via MCP (October 31, 2025)
- [x] ✅ **COMPLETED** - Create comprehensive MCP test suite (test_mcp_auth.sh) (October 31, 2025)
- [x] ✅ **COMPLETED** - Test MCP server integration with Claude Desktop/VS Code (October 31, 2025)
- [x] ✅ **COMPLETED** - Verify post creation and other tools via MCP (October 31, 2025)
- [x] ✅ **COMPLETED** - Add batch operation support (batch_post, batch_follow, batch_schedule) (October 31, 2025)
- [x] ✅ **COMPLETED** - Add MCP server logging and debugging capabilities (October 31, 2025)
- [ ] Add error recovery and retry logic for shell commands
- [ ] Implement MCP server health check endpoint

### MCP Server Testing & Documentation
- [x] ✅ **COMPLETED** - Write basic smoke tests for MCP server startup (October 31, 2025)
- [x] ✅ **COMPLETED** - Test tool discovery (list_tools request) (October 31, 2025)
- [x] ✅ **COMPLETED** - Create quickstart guide for MCP server setup (October 31, 2025)
- [x] ✅ **COMPLETED** - Document MCP server configuration options (October 31, 2025)
- [x] ✅ **COMPLETED** - Create example MCP client configuration (Claude Desktop, VS Code) (October 31, 2025)
- [x] ✅ **COMPLETED** - Test tool execution (call_tool request) for each category (October 31, 2025)
- [x] ✅ **COMPLETED** - Write MCP authentication flow tests (test_mcp_auth.sh) (October 31, 2025)
- [ ] Write integration tests for MCP server with real Bluesky operations
- [ ] Create MCP server configuration guide
- [ ] Write MCP client examples and tutorials
- [ ] Document MCP tool schemas and capabilities
- [ ] Create troubleshooting guide for MCP issues
- [ ] Add performance benchmarks for MCP operations

### MCP Ecosystem Integration
- [x] ✅ **COMPLETED** - Create MCP registry submission guide (November 1, 2025)
- [ ] Publish MCP server to package registries (NPM - requires credentials)
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
- [x] ✅ **COMPLETED** - Add session refresh capability for expired tokens (refresh_session(), auto-refresh in get_access_token)
- [x] ✅ **COMPLETED** - Add session validation before API calls (validate_session() function)
- [ ] Implement secure token storage using system keyring (optional enhancement)
- [ ] Support multiple user sessions/profiles
- [ ] Add logout confirmation prompt
- [ ] Implement session timeout handling

### AT Protocol Integration
- [x] ✅ **COMPLETED** - Add post creation functionality (`atproto post "message"`)
- [x] ✅ **COMPLETED** - Add automatic hashtag detection and rich text facets (October 31, 2025)
- [x] ✅ **COMPLETED** - Implement timeline/feed reading capabilities
- [x] ✅ **COMPLETED** - Add follow/unfollow user commands (atproto_follow, atproto_unfollow)
- [x] ✅ **COMPLETED** - Support for image/media uploads in posts (post_with_image, post_with_gallery, upload_media)
- [x] ✅ **COMPLETED** - Add reply functionality for posts (atproto_reply, threading support)
- [x] ✅ **COMPLETED** - Implement search functionality (atproto_search for posts and users)
- [x] ✅ **COMPLETED** - Support for blocks and mutes management (block_user, unblock_user, mute_user, unmute_user)
- [x] ✅ **COMPLETED** - Enhanced profile display with stats, content, and activity dates (October 31, 2025)
- [x] ✅ **COMPLETED** - Fixed JSON parsing for numeric values and nested objects (json_get_field enhancement)
- [x] ✅ **COMPLETED** - Added get_session_did() helper function for profile operations
- [x] ✅ **COMPLETED** - Add support for mentions (@-mentions) with facets (October 31, 2025)
- [x] ✅ **COMPLETED** - Add support for URL detection and link facets (October 31, 2025)
- [x] ✅ **COMPLETED** - Fixed UTF-8 byte position calculation for facets (November 1, 2025)
- [x] ✅ **COMPLETED** - Add support for bare domain URLs (github.com/path) (November 1, 2025)
- [x] ✅ **COMPLETED** - Add delete post functionality (November 1, 2025)
- [ ] Add support for custom feeds
- [ ] Implement pinned posts support
- [ ] Add repost functionality with custom text

### Error Handling & Resilience  
- [x] ✅ **COMPLETED** - Improve network error handling and retry logic (October 31, 2025)
- [x] ✅ **COMPLETED** - Implement graceful handling of API rate limits (429 detection with exponential backoff) (October 31, 2025)
- [x] ✅ **COMPLETED** - Add connection timeout configuration (30s default) (October 31, 2025)
- [x] ✅ **COMPLETED** - Better error messages for common failure scenarios (HTTP status codes) (October 31, 2025)
- [x] ✅ **COMPLETED** - Add better validation for user inputs (November 1, 2025)
- [ ] Add debug mode for troubleshooting (`--debug` flag)

## User Experience

### CLI Interface
- [x] ✅ **COMPLETED** - Add bash/zsh completion scripts
- [x] ✅ **COMPLETED** - Support for output formatting options (JSON via --json flag) - October 31, 2025
- [ ] Implement interactive mode for complex operations
- [ ] Add configuration file support for user preferences
- [ ] Add progress indicators for long-running operations
- [ ] Implement `--quiet` and `--verbose` flags
- [ ] Add color output configuration options

### Documentation & Help
- [x] ✅ **COMPLETED** - Documentation compilation system (`lib/doc.sh`)
- [x] ✅ **COMPLETED** - Generate combined markdown from all project docs
- [x] ✅ **COMPLETED** - Create `make docs` and `atproto-docs` commands
- [x] ✅ **COMPLETED** - Make doc.sh dynamic with auto-discovery and pattern-based exclusions
- [x] ✅ **COMPLETED** - Exclude session documentation from compilation workflow
- [x] ✅ **COMPLETED** - Fix pandoc HTML/PDF conversion (YAML parsing issue resolved)
- [ ] Add man page generation
- [ ] Create comprehensive usage examples
- [ ] Add troubleshooting guide to documentation
- [ ] Create video tutorials for common workflows
- [ ] Add FAQ section to README
- [ ] Document all environment variables

## Development & Code Quality

### Testing
- [x] ✅ **COMPLETED** - Expand test coverage for edge cases (encryption test suite added)
- [x] ✅ **COMPLETED** - Create comprehensive unit test runner (`scripts/test-unit.sh`)
- [x] ✅ **COMPLETED** - Integrate unit test runner into Makefile (`make test-unit`)
- [x] ✅ **COMPLETED** - Document test runner with comprehensive help and examples
- [x] ✅ **COMPLETED** - Update TESTING.md guide with test-unit documentation
- [x] ✅ **COMPLETED** - Update README.md with testing instructions
- [ ] Add integration tests with mock AT Protocol server
- [ ] Implement automated testing in CI/CD pipeline
- [ ] Add performance benchmarks and tests
- [ ] Create test fixtures for different scenarios
- [ ] Add security-focused tests (credential handling, permissions)
- [ ] Add JSON export option to test-unit.sh for CI/CD parsing

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
- [x] ✅ **COMPLETED** - Create dependency setup script (`lib/setup.sh`) with OS detection and package manager support
- [x] ✅ **COMPLETED** - Integrate setup script into `install.sh` for automatic dependency checking
- [x] ✅ **COMPLETED** - Fix Makefile to install all required library files (reporter.sh, cli-utils.sh) - October 31, 2025
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

*Last updated: November 1, 2025*
*This is a living document - items may be added, removed, or reprioritized based on community feedback and project evolution.*

## Phase 1 Completion Summary

### ✅ Phase 1 Status: COMPLETE (v0.1.0 - v0.3.0)

**Completion Date**: October 28, 2025  
**Features Completed**: 27 major features across 5 categories

#### Core Authentication & Session Management (6/6)
- ✅ Secure login with AES-256-CBC encryption
- ✅ Session persistence with automatic refresh
- ✅ Session validation before API calls
- ✅ Debug mode for development
- ✅ Backward compatibility for old credentials
- ✅ Comprehensive test coverage

#### AT Protocol Integration (13/13)
- ✅ Post creation with text and media
- ✅ Timeline/feed reading
- ✅ Follow/unfollow operations
- ✅ Followers/following lists
- ✅ Post engagement (like, repost, reply, delete)
- ✅ Search posts and users
- ✅ Block/unblock users
- ✅ Mute/unmute users
- ✅ Media upload (images, videos)
- ✅ Profile view and edit with complete stats
- ✅ Thread support for replies
- ✅ Error handling and validation
- ✅ Comprehensive API integration

#### MCP Server Implementation (10/10) ✅ **PHASE COMPLETE**
- ✅ Server architecture and protocol
- ✅ Authentication tools (4)
- ✅ Content tools (5)
- ✅ Feed tools (4)
- ✅ Profile tools (4)
- ✅ Search tools (3)
- ✅ Engagement tools (5)
- ✅ Social tools (6)
- ✅ Integration testing (Claude Desktop/VS Code)
- ✅ Production validation (October 31, 2025)

#### Infrastructure & Tools (5/5)
- ✅ Shell completion scripts (bash/zsh)
- ✅ Documentation system (lib/doc.sh)
- ✅ Test suite (10+ test files)
- ✅ Build system (Makefile)
- ✅ Installation scripts

#### Documentation (5/5)
- ✅ Comprehensive README
- ✅ Security documentation
- ✅ Testing guide
- ✅ Debug mode guide
- ✅ Architecture documentation

### Phase 1 Metrics

| Metric | Value |
|--------|-------|
| **Total Features** | 27 |
| **Shell Functions** | 80+ |
| **MCP Tools** | 31 |
| **Test Coverage** | 10 test suites |
| **Documentation Pages** | 15+ |
| **Lines of Code** | 5,000+ |
| **Completion Rate** | 100% |

### Ready for Phase 2

Phase 2 will focus on:
- Advanced packaging and distribution (deb, homebrew, snap, docker)
- Automation and agent frameworks
- Advanced AT Protocol features
- Enterprise features and scalability
- Third-party integrations

*Last updated: October 31, 2025*

## November 1, 2025 - Bug Fixes & Validation Update

### Critical Bug Fixes (November 1, 2025)
- [x] ✅ **COMPLETED** - Fixed UTF-8 byte position calculation for facets (emojis now work correctly)
- [x] ✅ **COMPLETED** - Fixed URL detection to support bare domains (github.com/path)
- [x] ✅ **COMPLETED** - Fixed hashtag facet overlap with URL detection
- [x] ✅ **COMPLETED** - Successfully posted MCP server announcement to Bluesky

### New Features (November 1, 2025)
- [x] ✅ **COMPLETED** - Added delete command to CLI (`atproto delete <uri>`)
- [x] ✅ **COMPLETED** - Created comprehensive input validation library (lib/validation.sh)
  - 10 validation functions (post text, handles, URIs, DIDs, files, limits, URLs, emails)
  - 41 passing tests with 100% pass rate
  - Integrated into main library with improved error messages
- [x] ✅ **COMPLETED** - Created MCP registry submission guide (mcp-server/docs/MCP_REGISTRY_SUBMISSION.md)

### November 1 Metrics
- **Git Commits**: 9
- **New Code**: ~500 lines (validation library)
- **Tests Added**: 41 (all passing)
- **Bug Fixes**: 3 critical issues resolved
- **Features**: 2 major features added

### Publishing Progress
- ✅ Announcement posted to Bluesky (with proper formatting)
- ✅ MCP registry submission guide created
- ⏳ NPM publish (waiting for credentials)
- ⏳ MCP registry submission (ready to submit)

*Session updated: November 1, 2025*