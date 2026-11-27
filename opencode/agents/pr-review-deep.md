---
description: "Read-only reviewer for the pr-review skill: finding and validating bugs and code quality issues. Launch only from that skill."
mode: subagent
model: "claude-agent/opus#xhigh"
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
