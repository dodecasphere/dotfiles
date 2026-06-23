---
description: Delete local branches whose remote tracking branch is gone
allowed-tools: Bash(git fetch:*), Bash(git branch:*), Bash(git for-each-ref:*)
---
Prune local branches that no longer exist on the remote:

1. Run `git fetch --prune`.
2. Find local branches whose upstream is marked "gone".
3. List them for me, then delete the merged ones with `git branch -d`. Use
   `git branch -D` only for clearly-abandoned branches, and tell me which you
   force-deleted.

Never delete the current branch or the default branch (main/master).
