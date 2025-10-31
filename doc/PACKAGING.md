# Packaging and Distribution Guide

This document describes how atproto can be packaged and distributed for various platforms.

## Current Distribution Methods

### Direct Installation (Recommended for Users)

The simplest method for end users:

```bash
git clone https://github.com/p3nGu1nZz/atproto.git
cd atproto
./install.sh
```

### Manual Installation

For custom installations:

```bash
git clone https://github.com/p3nGu1nZz/atproto.git
cd atproto
make install PREFIX=/your/custom/path
```

## Future Packaging Options

### Debian/Ubuntu Package (.deb)

To create a Debian package in the future:

1. Create a `debian/` directory with control files
2. Use `dpkg-deb` to build the package
3. Users can install with: `sudo dpkg -i atproto_0.1.0_all.deb`

### Homebrew (macOS/Linux)

Create a Homebrew formula:

```ruby
class AtBot < Formula
  desc "Simple CLI tool for Bluesky AT Protocol automation"
  homepage "https://github.com/p3nGu1nZz/atproto"
  url "https://github.com/p3nGu1nZz/atproto/archive/v0.1.0.tar.gz"
  sha256 "..."

  def install
    bin.install "bin/atproto"
    lib.install "lib/atproto.sh" => "atproto/atproto.sh"
    doc.install "README.md", "LICENSE"
  end
end
```

### Snap Package

For universal Linux distribution:

1. Create a `snapcraft.yaml`
2. Build with `snapcraft`
3. Publish to Snap Store

### Docker Image

Create a Docker image for containerized usage:

```dockerfile
FROM ubuntu:latest
RUN apt-get update && apt-get install -y curl bash
COPY bin/ /usr/local/bin/
COPY lib/ /usr/local/lib/atproto/
RUN chmod +x /usr/local/bin/atproto
ENTRYPOINT ["/usr/local/bin/atproto"]
```

## Release Process

1. Update version in `bin/atproto`
2. Update CHANGELOG.md
3. Tag release: `git tag -a v0.1.0 -m "Release v0.1.0"`
4. Push tag: `git push origin v0.1.0`
5. Create GitHub Release
6. Attach pre-built packages if available

## Installation Verification

After installation, users should verify:

```bash
atproto --version
atproto help
```

## Dependencies

atproto requires:
- Bash 4.0+
- curl
- grep
- Standard POSIX utilities (sed, awk, etc.)

These are typically pre-installed on most Linux distributions.

## Platform Support

Currently tested on:
- Ubuntu 20.04+
- Debian 10+
- WSL (Windows Subsystem for Linux)
- macOS 10.15+

## Security Considerations

- Session files are created with mode 600
- Passwords are never stored, only tokens
- All communication uses HTTPS
- Recommend using app passwords instead of account passwords
