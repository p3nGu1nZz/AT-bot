# Session Summary: Hashtag Support Implementation

**Date**: October 31, 2025  
**Focus**: Adding automatic hashtag detection and rich text facets to posts

## Issue Identified

User noticed that hashtags in posts were not becoming clickable links like they do in the Bluesky web UI. This is because the AT Protocol requires hashtags to be annotated with "facets" (rich text metadata) to be recognized as clickable elements.

## Solution Implemented

### 1. Created `create_hashtag_facets()` Function

Added a new function in `lib/atproto.sh` that:
- Detects all hashtags in post text using pattern matching (`#[a-zA-Z0-9_-]+`)
- Calculates byte positions for each hashtag occurrence
- Generates proper AT Protocol facet JSON with:
  - `byteStart` and `byteEnd` positions
  - `app.bsky.richtext.facet#tag` type annotation
  - Tag name without the `#` symbol

### 2. Updated `atproto_post()` Function

Modified the post creation function to:
- Call `create_hashtag_facets()` to detect hashtags in the text
- Include the facets in the post record JSON
- Handle both reply and non-reply posts with facets

### 3. Testing

Created `tests/test_hashtags.sh` to verify:
- Single hashtag detection
- Multiple hashtags
- Hashtags with underscores and hyphens
- Complex posts with many hashtags
- Posts with no hashtags (returns empty array)

### 4. Documentation Updates

Updated documentation to reflect the new feature:
- **README.md**: Added hashtag example and updated features list
- **TODO.md**: Marked hashtag support as completed, added future items for mentions and URLs

## Technical Details

### Facet Structure

```json
{
  "index": {
    "byteStart": 6,
    "byteEnd": 12
  },
  "features": [
    {
      "$type": "app.bsky.richtext.facet#tag",
      "tag": "world"
    }
  ]
}
```

### Post Record with Facets

```json
{
  "repo": "did:plc:...",
  "collection": "app.bsky.feed.post",
  "record": {
    "$type": "app.bsky.feed.post",
    "text": "Hello #world",
    "createdAt": "2025-10-31T...",
    "facets": [
      {
        "index": {"byteStart": 6, "byteEnd": 12},
        "features": [{"$type": "app.bsky.richtext.facet#tag", "tag": "world"}]
      }
    ]
  }
}
```

## Test Results

Successfully tested with a real post containing multiple hashtags. All hashtags were detected and properly formatted with facets.

Test post:
```
Testing hashtag support! Now our #hashtags should be clickable links. #ATProtocol #Bluesky #OpenSource
```

Post URI: `at://did:plc:o2wtqnptvdywuqhnhlmpskki/app.bsky.feed.post/3m4jxtcbagg2u`

## Future Enhancements

The same facet mechanism can be extended to support:
1. **Mentions** (`@user.bsky.social`) - using `app.bsky.richtext.facet#mention`
2. **URLs** (https://example.com) - using `app.bsky.richtext.facet#link`
3. **Custom rich text formatting** - bold, italic, etc.

## Files Modified

- `lib/atproto.sh` - Added `create_hashtag_facets()` function and updated `atproto_post()`
- `tests/test_hashtags.sh` - New test file for hashtag detection
- `README.md` - Updated features and usage examples
- `TODO.md` - Marked completion and added future items

## References

- [AT Protocol Rich Text Specification](https://atproto.com/specs/lexicon#rich-text)
- [Bluesky Facets Documentation](https://docs.bsky.app/docs/advanced-guides/post-richtext)

---

*This implementation ensures that all posts created via atproto CLI will have properly formatted, clickable hashtags, matching the behavior of the Bluesky web interface.*
