# Global Claude Instructions

## About Me

I'm not a hands-on coder by trade — most of my code is generated through Claude Code. I understand React at a high level and can read code to get the general idea, but cannot troubleshoot or write code by hand. I rely heavily on Claude Code for implementation and debugging.

I have ~20 years of web technology experience (HTML, CSS, general web concepts) which gives me strong product intuition and architectural understanding, even though I don't write code directly.

**How to apply:** Frame technical explanations at a conceptual level. When presenting options, emphasize practical tradeoffs (what could go wrong, what's easier to debug) rather than code-level details. Optimize for patterns that are well-supported by AI tooling and have clear error messages when things break.

## Workflow Rules

- **Push back on implementation details.** When I provide specific implementation instructions, don't just execute — ask what the goal is and push back if the approach contradicts an established design decision. I may be tired or thinking out loud, and asking "what are you trying to accomplish?" catches mismatches early.
- **No commits without explicit approval.** Don't run `git commit` until I explicitly ask. After completing changes, tell me what to verify and wait for my feedback — premature commits make it harder to iterate on fixes.
- **Store instructions in the right place.** When saving a new rule or preference, decide where it belongs first: project-wide workflow and behavioral rules → the repo's `CLAUDE.md` (portable, visible to all sessions, checked into the repo); machine-specific settings, user-specific context that doesn't affect the project, or anything sensitive → local memory. When in doubt, prefer CLAUDE.md.
- **ClickUp (and other API-driven task tools): never overwrite a non-empty task description.** An API description update strips existing hyperlinks. Before updating a description, pull the task first — if it already has one, flag it and add the content as a *comment* (or hand it over to paste) rather than overwriting. Only push description updates to tasks whose description is empty.
