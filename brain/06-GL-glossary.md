# [GL] Glossary

Project-specific terms an AI won't know from general knowledge. One sentence per term.

- **config layer**: the `claude/` subtree, the version-controlled source for `~/.claude`.
- **whitelist**: the specific files/dirs `install.sh` symlinks into `~/.claude` (junk excluded by construction).
- **verify.sh gate**: a per-project `.claude/verify.sh` run by the verify-done Stop hook to enforce tests + coverage.
- **brain-loader**: the SessionStart hook that auto-injects a project's Project Brain.
- **two-letter codes**: the OV/GO/AR/DC/ST/GL/OQ section tags of a Project Brain.
- **Claude Usage app**: third-party macOS menubar app that syncs the Claude Code CLI login (an `sk-ant-oat01` OAuth token) into the Keychain and feeds the statusline usage gauge; not part of this repo.
