# Contributing to AT-bot

Thank you for your interest in contributing to AT-bot! This document provides guidelines and information for contributors.

## Development Setup

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/atproto.git
   cd AT-bot
   ```

3. Create a development branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Project Structure

```
AT-bot/
├── bin/          # Executable scripts
│   └── at-bot    # Main CLI tool
├── lib/          # Library functions
│   └── atproto.sh # AT Protocol implementation
├── tests/        # Test suite
│   ├── run_tests.sh
│   ├── test_cli_basic.sh
│   └── test_library.sh
├── doc/          # Documentation
│   ├── QUICKSTART.md
│   └── CONTRIBUTING.md
├── Makefile      # Build/install automation
├── install.sh    # Installation script
└── README.md     # Main documentation
```

## Coding Standards

- Use POSIX-compliant bash syntax where possible
- Follow existing code style and formatting
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused

## Testing

Always add tests for new functionality:

1. Create a new test file in `tests/` following the naming convention `test_*.sh`
2. Run tests before submitting:
   ```bash
   make test
   # or
   bash tests/run_tests.sh
   ```

## Adding New Commands

To add a new command to the CLI:

1. Add the command handler in `bin/at-bot`
2. Implement the functionality in `lib/atproto.sh` (if AT Protocol related)
3. Update the help text in `show_help()` function
4. Add tests for the new command
5. Update README.md with usage examples

## Submitting Changes

1. Ensure all tests pass
2. Update documentation as needed
3. Commit your changes with clear commit messages:
   ```bash
   git commit -m "Add feature: brief description"
   ```

4. Push to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

5. Create a Pull Request with:
   - Clear description of changes
   - Any related issue numbers
   - Test results

## Code Review Process

- All submissions require review
- Address any feedback from reviewers
- Maintainers will merge once approved

## Reporting Issues

When reporting issues, please include:

- AT-bot version (`at-bot --version`)
- Operating system and version
- Steps to reproduce
- Expected vs actual behavior
- Any error messages

## Security

If you discover a security vulnerability, please email the maintainers directly instead of opening a public issue.

## Questions?

Feel free to open an issue for questions or discussion.

Thank you for contributing to AT-bot!
