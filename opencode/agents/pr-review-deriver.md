---
description: "Approach deriver for the pr-review skill: designs the simplest change from the goal and the code before the change, without access to the change itself. Launch only from that skill."
mode: "subagent"
model: "claude-agent/opus#xhigh"
permissions:
  - { "action": "*", "resource": "*", "effect": "deny" }
  - { "action": "external_directory", "resource": "*", "effect": "allow" }
  - { "action": "read", "resource": "*/pr-review-base-*", "effect": "allow" }
  - { "action": "glob", "resource": "*", "effect": "allow" }
  - { "action": "grep", "resource": "*", "effect": "allow" }
---
