#!/bin/bash
# Demo: Configuration System and JSON Output
# Shows how config system enables flexible automation

echo "================================"
echo "AT-bot Configuration Demo"
echo "================================"
echo ""

# Show current configuration
echo "1. Current Configuration:"
echo "------------------------"
./bin/at-bot config list
echo ""

# Demo: Text output (default)
echo "2. Text Output Format (default):"
echo "--------------------------------"
./bin/at-bot config get output_format
echo ""

# Demo: Set JSON output format
echo "3. Setting JSON Output Format:"
echo "------------------------------"
./bin/at-bot config set output_format json
echo ""

# Demo: Environment variable override
echo "4. Environment Variable Override:"
echo "---------------------------------"
echo "Config file has: $(./bin/at-bot config get feed_limit)"
echo "Override with env var: ATP_FEED_LIMIT=100"
echo ""

# Demo: Reset configuration
echo "5. Reset to Defaults:"
echo "--------------------"
./bin/at-bot config reset
echo ""

# Demo: Automation patterns
echo "6. Automation Patterns:"
echo "----------------------"
echo ""
echo "Example 1: JSON output for scripting"
echo "  ATP_OUTPUT_FORMAT=json at-bot whoami | jq '.handle'"
echo ""
echo "Example 2: Temporary config override"
echo "  ATP_FEED_LIMIT=50 at-bot feed"
echo ""
echo "Example 3: CI/CD friendly"
echo "  export ATP_OUTPUT_FORMAT=json"
echo "  export ATP_COLOR_OUTPUT=never"
echo "  at-bot post 'Build successful' | jq '.uri'"
echo ""

echo "================================"
echo "Configuration Demo Complete!"
echo "================================"
echo ""
echo "Try these commands yourself:"
echo "  at-bot config list"
echo "  at-bot config set feed_limit 50"
echo "  ATP_OUTPUT_FORMAT=json at-bot whoami"
echo ""
