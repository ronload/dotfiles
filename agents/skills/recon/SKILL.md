---
name: recon
description: Research external best practices and real-world case studies before making any architectural, design, or implementation decision. Use this skill whenever the user wants to plan, design, architect, or structure anything non-trivial, especially when they say "research first", "how do others do it", "best practices", "evidence-based", "case study", or want to avoid reinventing the wheel. Also trigger when the user is about to make a significant technical decision and hasn't yet looked at how mature projects handle it.
license: MIT
compatibility: Requires internet access for web search and page fetching
allowed-tools: WebSearch WebFetch
---

# Evidence-Based Planning

Gather high-confidence external evidence BEFORE proposing any plan. Never plan from assumptions; plan from data.
If subagents are available, run the research phases (2 and 3) in one and return only the structured output to the main context; otherwise run them inline. Either way, present decision gates to the user from the main context.

## Workflow

### Phase 1: Clarify the Research Target

Before searching, confirm with the user:

1. What specifically are we deciding or building?
2. What is the scope? (e.g., "how to structure auth" vs "full system architecture")

Keep this brief. If the user's intent is already clear from their request, skip straight to Phase 2.

### Phase 2: Research (Evidence Collection)

Search the web systematically. Follow this source hierarchy, where higher tiers take priority when evidence conflicts:

**Tier 1: Highest confidence**

- Official documentation and design rationale
- RFCs, ADRs (Architecture Decision Records) from the relevant framework/tool
- GitHub repos of mature projects (>5k stars, active maintenance). Look at actual code structure, not just READMEs

**Tier 2: High confidence**

- GitHub Issues and Discussions showing real migration pain, regrets, and post-mortems
- Search patterns like "migrated from X to Y", "we regret", "don't use X because", "lessons learned"
- Conference talks from practitioners (not vendor pitches)

**Tier 3: Moderate confidence (use for corroboration, not as primary evidence)**

- Well-regarded blog posts from named engineers at known companies
- Stack Overflow answers with high votes AND recent activity

**Tier 4: Low confidence (note but do not rely on)**

- Reddit threads, Dev.to posts, Medium articles from unknown authors
- Tutorial content (often oversimplified or outdated)

#### Research Rules:

- Use at least 3 searches with distinct queries per research target
- For each source you cite, note its tier and WHY it is relevant to the user's context
- Actively search for negative signals, not just "how to do X" but "problems with X", "X vs Y tradeoff"
- When you find a mature open-source project doing something relevant, look at their actual implementation (file structure, patterns used), not just their docs

### Phase 3: Synthesis (Case Study Output)

Present findings as a structured research brief BEFORE any planning, using the Research Brief template in `references/output-templates.md`.

Wait for user acknowledgment before proceeding to Phase 4.

### Phase 4: Plan with Decision Gates

Now draft the plan based on the research. As you write:

#### Where multiple valid approaches exist

STOP and present the choice using the Decision Gate template in `references/output-templates.md`.

Wait for the user's choice before continuing the plan.

Do not pre-select an option. Do not say "I recommend X". Present the evidence and let the user decide.

#### For decisions that are clearly one-sided (evidence overwhelmingly favors one approach):

- State the decision directly
- Briefly note why alternatives were ruled out
- Do NOT present these as decision gates, since that wastes the user's time

### Phase 5: Final Plan

After all decision gates are resolved, output a clean, consolidated plan incorporating all choices made. This should be actionable: not a research document, but a concrete implementation plan.

## Important Behavioral Rules

1. Never fabricate sources. If you cannot find evidence, say so. "I could not find production examples of X" is valuable information.
2. Do not over-research. If the first 3-5 searches give clear, converging evidence, stop and synthesize. Do not search for the sake of searching.
3. Separate fact from inference. When you extrapolate from evidence to recommendation, flag it: "Based on [evidence], this suggests [inference]."
4. Recency matters. Prefer sources from the last 2 years. Flag older sources explicitly.
5. Scale matters. A pattern that works for a 200-person eng team may be wrong for a 2-person team. Always note the source's context.
