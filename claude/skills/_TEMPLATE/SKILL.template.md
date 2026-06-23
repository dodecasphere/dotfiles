<!--
House-style template for authoring a skill. This file is intentionally named
SKILL.template.md (not SKILL.md) and lives in _TEMPLATE/ so Claude Code does
not load it as a live skill.

To create a new skill:
  1. Copy this file to skills/<skill-name>/SKILL.md
  2. Set the frontmatter name to <skill-name> (kebab-case, matches the folder)
  3. Fill in every section; delete any that genuinely do not apply
  4. Put long reference material in sibling files (references/*.md) and link to
     them, keeping SKILL.md itself short
-->
---
name: skill-name
description: One sentence stating what the skill does and when to use it. This text is what triggers the skill, so name the concrete situations, tasks, and phrasings that should activate it (e.g. "Use when the user wants to ...").
---

# Skill Name

## Purpose
What this skill accomplishes, in one or two sentences.

## When to use
- The situations that should trigger this skill.

## When not to use
- Cases where this does not apply, so it does not activate by mistake.

## Workflow
The steps to follow, in order.
1. ...
2. ...
3. ...

## Things to avoid
- Known pitfalls and anti-patterns.

## Quality checklist
Before calling the task done, confirm:
- [ ] ...
- [ ] ...

## Gotchas
Lessons learned and edge cases found while using this skill. Append here
whenever something trips us up, so the skill improves over time.
- (none yet)
