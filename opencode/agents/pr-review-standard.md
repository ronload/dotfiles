---
description: "Read-only reviewer for the pr-review skill: PR summaries, AGENTS.md compliance checks, and validating rule findings. Launch only from that skill."
mode: subagent
model: "claude-agent/sonnet#high"
permissions:
  - { "action": "edit", "resource": "*", "effect": "deny" }
  - { "action": "subagent", "resource": "*", "effect": "deny" }
  - { "action": "question", "resource": "*", "effect": "deny" }
  - { "action": "shell", "resource": "*", "effect": "deny" }
  - { "action": "shell", "resource": "git diff *", "effect": "allow" }
  - { "action": "shell", "resource": "git show *", "effect": "allow" }
  - { "action": "shell", "resource": "git log *", "effect": "allow" }
  - { "action": "shell", "resource": "git blame *", "effect": "allow" }
  - { "action": "shell", "resource": "git grep *", "effect": "allow" }
  - { "action": "shell", "resource": "git ls-tree *", "effect": "allow" }
---
