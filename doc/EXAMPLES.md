# AT-bot Usage Examples

Practical examples and code snippets for common AT-bot use cases.

## Table of Contents

- [Basic Usage](#basic-usage)
- [Automation Scripts](#automation-scripts)
- [CI/CD Integration](#cicd-integration)
- [Social Media Workflows](#social-media-workflows)
- [Content Creation](#content-creation)
- [Data Operations](#data-operations)
- [Advanced Patterns](#advanced-patterns)

## Basic Usage

### Login and Check Status

```bash
# Interactive login
at-bot login

# Check who you're logged in as
at-bot whoami

# Logout
at-bot logout
```

### Create a Simple Post

```bash
# Single line post
at-bot post "Hello, Bluesky! 👋"

# Multi-line post
at-bot post "First line
Second line
Third line"

# Post with variables
message="Posted at $(date)"
at-bot post "$message"
```

### Read Your Feed

```bash
# Show last 10 posts (default)
at-bot feed

# Show last 20 posts
at-bot feed 20

# Show last 50 posts
at-bot feed 50
```

### Search and Follow

```bash
# Search for posts
at-bot search "AT Protocol"

# Search for specific user
at-bot search "@user.bsky.social"

# Follow a user
at-bot follow user.bsky.social

# Unfollow a user
at-bot unfollow user.bsky.social
```

## Automation Scripts

### Daily Status Update

```bash
#!/bin/bash
# daily-status.sh - Post daily status updates

set -e

# Configuration
BLUESKY_HANDLE="${BLUESKY_HANDLE:-automation.bot}"
export BLUESKY_HANDLE

# Login
at-bot login

# Gather information
UPTIME=$(uptime | awk -F'up' '{print $2}' | cut -d',' -f1)
DATE=$(date '+%A, %B %d, %Y')
TIME=$(date '+%H:%M:%S')

# Create message
MESSAGE="📊 Daily Status Report

Date: $DATE
Time: $TIME
System Uptime: $UPTIME

Status: ✅ All systems operational

#DailyReport #Automation #Monitoring"

# Post to Bluesky
at-bot post "$MESSAGE"

echo "Status posted successfully!"
```

Run with:
```bash
chmod +x daily-status.sh
./daily-status.sh
```

Or schedule with cron:
```bash
# Edit crontab
crontab -e

# Add this line (runs daily at 9 AM)
0 9 * * * /path/to/daily-status.sh
```

### Project Update Bot

```bash
#!/bin/bash
# project-update.sh - Post project updates from git commits

set -e

# Configuration
REPO_NAME="AT-bot"
REPO_URL="https://github.com/p3nGu1nZz/AT-bot"

# Get recent commits
COMMITS=$(git log -5 --oneline)
COMMIT_COUNT=$(git rev-list --count HEAD ^HEAD~7)

# Get contributor count
CONTRIBUTORS=$(git shortlog -sn HEAD | wc -l)

# Create message
MESSAGE="🚀 $REPO_NAME Update

Recent Commits: $COMMIT_COUNT
Active Contributors: $CONTRIBUTORS

Latest Work:
$(echo "$COMMITS" | head -3 | sed 's/^/  • /')

Interested? Check us out: $REPO_URL

#OpenSource #GitHub #Development"

# Post update
at-bot login
at-bot post "$MESSAGE"
```

### Weekly Digest

```bash
#!/bin/bash
# weekly-digest.sh - Create weekly summary

set -e

# Configuration
WEEK_NUMBER=$(date +%V)
YEAR=$(date +%Y)

# Gather metrics
COMMITS=$(git rev-list --count HEAD ~$(date +%u) ^HEAD)
FILES_CHANGED=$(git diff --name-only HEAD~7 HEAD | wc -l)
BRANCHES=$(git branch -a | wc -l)

# Create digest
MESSAGE="📰 Weekly Digest - Week $WEEK_NUMBER, $YEAR

📝 Development Summary:
  • Commits: $COMMITS
  • Files Changed: $FILES_CHANGED
  • Active Branches: $BRANCHES

🎯 Highlights:
  • Feature implementation
  • Bug fixes
  • Documentation updates

✨ Next Week:
  • Continue development
  • Expand test coverage
  • Improve docs

#WeeklyDigest #Development"

at-bot login
at-bot post "$MESSAGE"
```

## CI/CD Integration

### GitHub Actions Workflow

```yaml
# .github/workflows/post-release.yml

name: Post Release to Bluesky

on:
  release:
    types: [published]

jobs:
  post:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install AT-bot
        run: |
          git clone https://github.com/p3nGu1nZz/AT-bot.git
          cd AT-bot
          ./install.sh

      - name: Post release announcement
        env:
          BLUESKY_HANDLE: ${{ secrets.BLUESKY_HANDLE }}
          BLUESKY_PASSWORD: ${{ secrets.BLUESKY_PASSWORD }}
        run: |
          VERSION="${{ github.event.release.tag_name }}"
          BODY="${{ github.event.release.body }}"
          
          at-bot login
          
          MESSAGE="🎉 Release: $VERSION

$BODY

📦 Download: ${{ github.event.release.html_url }}

#Release #NewVersion"
          
          at-bot post "$MESSAGE"
```

### Test Results Reporter

```yaml
# .github/workflows/test-report.yml

name: Test Report

on:
  pull_request:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run tests
        run: |
          make test > test-results.txt 2>&1 || true

      - name: Install AT-bot
        run: |
          git clone https://github.com/p3nGu1nZz/AT-bot.git
          cd AT-bot
          ./install.sh

      - name: Post test results
        if: always()
        env:
          BLUESKY_HANDLE: ${{ secrets.TEST_BOT_HANDLE }}
          BLUESKY_PASSWORD: ${{ secrets.TEST_BOT_PASSWORD }}
        run: |
          TESTS=$(grep -c "PASS" test-results.txt || echo "0")
          FAILURES=$(grep -c "FAIL" test-results.txt || echo "0")
          
          if [ "$FAILURES" -eq 0 ]; then
            STATUS="✅"
            EMOJI="🎉"
          else
            STATUS="⚠️"
            EMOJI="🚨"
          fi
          
          at-bot login
          
          MESSAGE="$EMOJI Test Run Results
          
Tests Passed: $TESTS
Tests Failed: $FAILURES
Status: $STATUS

Branch: ${{ github.ref }}
Commit: ${{ github.sha }}"
          
          at-bot post "$MESSAGE"
```

## Social Media Workflows

### Content Calendar Posting

```bash
#!/bin/bash
# content-calendar.sh - Post from a content calendar

set -e

# Load posts from JSON file
CALENDAR_FILE="posts.json"

at-bot login

# Process each post in calendar
jq -r '.[] | select(.date == "'$(date +%Y-%m-%d)'") | .content' "$CALENDAR_FILE" | while read -r post; do
    echo "Posting: $post"
    at-bot post "$post"
    sleep 5  # Wait between posts
done
```

Example `posts.json`:
```json
[
  {
    "date": "2025-10-28",
    "content": "Monday motivation! 💪"
  },
  {
    "date": "2025-10-29",
    "content": "Tip Tuesday: Always use app passwords! 🔐"
  },
  {
    "date": "2025-10-30",
    "content": "Wednesday wisdom about open source 🚀"
  }
]
```

### Reply to Mentions

```bash
#!/bin/bash
# reply-to-mentions.sh - Reply to mentions (when implemented)

set -e

at-bot login

# Get recent notifications
MENTIONS=$(at-bot feed | grep "@your.handle")

while IFS= read -r mention; do
    # Extract post URI
    URI=$(echo "$mention" | grep -oP 'uri: \K[^,]+')
    
    if [ -n "$URI" ]; then
        REPLY="Thanks for the mention! 👋"
        echo "Replying to: $URI"
        # at-bot reply "$URI" "$REPLY"  # When implemented
    fi
done <<< "$MENTIONS"
```

### Follow New Followers

```bash
#!/bin/bash
# follow-followers.sh - Auto-follow new followers

set -e

at-bot login

# Get followers list
FOLLOWERS=$(at-bot followers | jq -r '.[].handle')

# Get following list
FOLLOWING=$(at-bot following | jq -r '.[].handle')

while read -r follower; do
    if ! echo "$FOLLOWING" | grep -q "$follower"; then
        echo "Following back: $follower"
        at-bot follow "$follower"
        sleep 2  # Rate limiting
    fi
done <<< "$FOLLOWERS"
```

## Content Creation

### Generate Daily Quotes

```bash
#!/bin/bash
# daily-quote.sh - Post daily quotes

set -e

QUOTES=(
    "The only way to do great work is to love what you do. - Steve Jobs"
    "Innovation distinguishes between a leader and a follower. - Steve Jobs"
    "Life is what happens when you're busy making other plans. - John Lennon"
    "The future belongs to those who believe in the beauty of their dreams. - Eleanor Roosevelt"
)

# Pick random quote
RANDOM_INDEX=$((RANDOM % ${#QUOTES[@]}))
QUOTE="${QUOTES[$RANDOM_INDEX]}"

at-bot login
at-bot post "📖 Quote of the Day

\"$QUOTE\"

#DailyQuote #Inspiration"
```

### News Aggregation

```bash
#!/bin/bash
# news-aggregator.sh - Aggregate and share news

set -e

at-bot login

# Fetch news from RSS feed (requires rss parser)
ARTICLES=$(curl -s "https://news.ycombinator.com/rss" | \
    grep -oP '(?<=<title>)[^<]+' | head -5)

MESSAGE="📰 Top 5 Stories Today

"

while read -r article; do
    MESSAGE="$MESSAGE• $article
"
done <<< "$ARTICLES"

MESSAGE="$MESSAGE
#News #TopStories #Aggregation"

at-bot post "$MESSAGE"
```

## Data Operations

### Export Your Feed

```bash
#!/bin/bash
# export-feed.sh - Export your feed to JSON

set -e

at-bot login

# Get feed (limit to 100)
FEED=$(at-bot feed 100)

# Save to file with timestamp
FILENAME="feed-$(date +%Y%m%d-%H%M%S).json"

echo "$FEED" > "$FILENAME"
echo "Feed exported to: $FILENAME"
```

### Backup Posts

```bash
#!/bin/bash
# backup-posts.sh - Backup recent posts

set -e

BACKUP_DIR="./backups"
mkdir -p "$BACKUP_DIR"

at-bot login

# Get recent posts
POSTS=$(at-bot feed 50)

# Save with metadata
BACKUP_FILE="$BACKUP_DIR/posts-$(date +%Y%m%d-%H%M%S).json"

echo "{" > "$BACKUP_FILE"
echo "  \"backup_date\": \"$(date -Iseconds)\"," >> "$BACKUP_FILE"
echo "  \"posts\": $POSTS" >> "$BACKUP_FILE"
echo "}" >> "$BACKUP_FILE"

echo "Backed up to: $BACKUP_FILE"
```

## Advanced Patterns

### Error Handling and Retry

```bash
#!/bin/bash
# robust-posting.sh - Robust posting with error handling

set -e

MAX_RETRIES=3
RETRY_DELAY=5

# Function to post with retry
post_with_retry() {
    local message="$1"
    local attempt=1
    
    while [ $attempt -le $MAX_RETRIES ]; do
        echo "Attempt $attempt..."
        
        if at-bot post "$message"; then
            echo "✅ Post successful"
            return 0
        fi
        
        if [ $attempt -lt $MAX_RETRIES ]; then
            echo "❌ Post failed, retrying in ${RETRY_DELAY}s..."
            sleep $RETRY_DELAY
        fi
        
        ((attempt++))
    done
    
    echo "❌ Post failed after $MAX_RETRIES attempts"
    return 1
}

# Usage
at-bot login
post_with_retry "Important announcement with retry logic"
```

### Multi-Account Management

```bash
#!/bin/bash
# multi-account.sh - Manage multiple accounts

set -e

# Define accounts
declare -A ACCOUNTS=(
    [personal]="personal.bsky.social"
    [work]="work.bsky.social"
    [automation]="automation.bsky.social"
)

# Function to post from account
post_from_account() {
    local account_key="$1"
    local message="$2"
    
    local handle="${ACCOUNTS[$account_key]}"
    
    if [ -z "$handle" ]; then
        echo "Unknown account: $account_key"
        return 1
    fi
    
    export BLUESKY_SESSION_FILE=~/.config/at-bot/"${account_key}-session.json"
    
    echo "Posting from: $handle"
    at-bot login
    at-bot post "$message"
}

# Usage
post_from_account personal "Personal post"
post_from_account work "Work update"
post_from_account automation "Automated notification"
```

### Scheduled Operations

```bash
#!/bin/bash
# scheduled-operations.sh - Handle scheduled tasks

set -e

# Function to run operation at specific time
run_at_time() {
    local target_time="$1"  # Format: HH:MM
    local message="$2"
    
    while true; do
        current_time=$(date +%H:%M)
        
        if [ "$current_time" = "$target_time" ]; then
            echo "Executing scheduled operation: $target_time"
            at-bot login
            at-bot post "$message"
            break
        fi
        
        sleep 30  # Check every 30 seconds
    done
}

# Usage
run_at_time "09:00" "Good morning! ☀️"
```

Or use system scheduler (cron):
```bash
# Edit crontab: crontab -e

# Post at 9 AM every day
0 9 * * * /path/to/at-bot login && /path/to/at-bot post "Morning!"

# Post every 6 hours
0 */6 * * * /path/to/at-bot login && /path/to/at-bot post "Check-in!"

# Post every Monday at 8 AM
0 8 * * 1 /path/to/at-bot login && /path/to/at-bot post "Monday motivation!"
```

### Monitoring and Alerts

```bash
#!/bin/bash
# monitoring-alerts.sh - Post alerts to Bluesky

set -e

# Function to send alert
send_alert() {
    local severity="$1"
    local title="$2"
    local details="$3"
    
    local emoji="❌"
    if [ "$severity" = "warning" ]; then
        emoji="⚠️"
    elif [ "$severity" = "info" ]; then
        emoji="ℹ️"
    fi
    
    local message="$emoji Alert: $title

Details: $details

Time: $(date '+%Y-%m-%d %H:%M:%S')

#Monitoring #Alert"
    
    at-bot login
    at-bot post "$message"
}

# Usage examples
# send_alert "error" "Database Connection Failed" "Unable to connect to primary DB"
# send_alert "warning" "High Memory Usage" "Memory usage at 85%"
# send_alert "info" "Backup Complete" "Daily backup finished successfully"
```

---

## Tips and Best Practices

✅ **DO**:
- Store scripts in version control
- Test scripts before scheduling
- Use meaningful variable names
- Add error handling and logging
- Rate limit requests (wait between posts)
- Document your automation

❌ **DON'T**:
- Hardcode credentials in scripts
- Share automation scripts with credentials
- Spam the network with automated posts
- Violate Bluesky's terms of service
- Post without proper attribution
- Use automation for manipulation

---

*Last updated: October 28, 2025*
