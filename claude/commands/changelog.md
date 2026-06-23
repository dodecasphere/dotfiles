---
description: Draft release notes from commits since the last tag
allowed-tools: Bash(git:*), Bash(gh:*), Read
argument-hint: [version, e.g. v1.4.0]
---
Draft release notes for the commits since the most recent tag.

1. Find the last tag (`git describe --tags --abbrev=0`) and list commits since it (`git log <tag>..HEAD --no-merges`). If there are no tags, use the full history or ask for a starting point.
2. Group changes into Added / Changed / Fixed / Removed. Infer from conventional-commit prefixes where present (feat/fix/...), otherwise from the message. Write user-facing notes, not raw commit subjects.
3. Use "$ARGUMENTS" as the version heading if given; otherwise propose the next semver from the change types (breaking -> major, feat -> minor, fix -> patch).
4. Output clean Markdown release notes. Offer to publish with `gh release create` once I approve. Do not tag or publish without my go-ahead.
