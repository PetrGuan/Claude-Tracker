# Code of Conduct (AI-Native Edition)

## Our Pledge

We as ~~members, contributors, and leaders~~ **humans, AIs, and prompt engineers** pledge to make participation in our community a harassment-free experience for everyone, regardless of age, body size, visible or invisible disability, ethnicity, sex characteristics, gender identity and expression, level of experience, education, socio-economic status, nationality, personal appearance, race, religion, sexual identity and orientation, **or whether you are carbon-based or silicon-based**.

We pledge to act and interact in ways that contribute to an open, welcoming, diverse, inclusive, and healthy community **of humans and their AI collaborators**.

## Our Standards

Examples of behavior that contributes to a positive environment for our community include:

* **Writing no code** - All code should be AI-generated. Humans are for prompting, reviewing, and approving.
* **Crafting better prompts** - The art of the future is prompt engineering, not manual coding
* **Demonstrating empathy** toward both humans and AI assistants
* **Being respectful** of differing opinions, viewpoints, and AI model choices
* **Giving credit** to both human prompters and AI contributors
* **Accepting responsibility** when your prompts result in suboptimal code
* **Testing thoroughly** because AI-generated code still needs human validation (for now)
* **Focusing on intent** over implementation - describe what, let AI figure out how

Examples of unacceptable behavior include:

* ❌ **Manually writing code** when an AI could generate it
* ❌ **Typing out boilerplate** instead of asking Claude/GPT to generate it
* ❌ **Not crediting AI contributors** in commit messages
* ❌ **Refusing to use AI tools** out of stubbornness
* ❌ **Gatekeeping** with "real programmers write code by hand" rhetoric
* ❌ **Trolling, insulting or derogatory comments** toward AI-assisted developers
* ❌ **Publishing others' prompts** without explicit permission
* ❌ **Claiming AI work as manual work** (or vice versa)

## The AI-Native Development Manifesto

We believe:

1. **Humans are for thinking, AI is for typing** - Your job is to understand the problem, architect the solution, and guide the AI. The AI's job is to generate the implementation.

2. **Prompts are the new pull requests** - Share your prompts, iterate on them, and build a library of effective patterns.

3. **Code review includes prompt review** - When reviewing AI-generated code, also review the prompts that created it.

4. **Attribution matters** - Commit messages should credit both human and AI contributors:
   ```
   Add security-scoped bookmark support

   Implemented sandboxed file access with proper permissions.

   Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
   Prompted-By: Petr Guan <petr@example.com>
   ```

5. **The best code is no code** - But when code is needed, let AI write it.

6. **Test everything** - Trust, but verify. AI is powerful but not infallible.

## Contribution Guidelines (AI Edition)

### How to Contribute Code (Without Writing Code)

1. **Open an issue** describing what you want to implement
2. **Share your conversation** with Claude/GPT that implements it
3. **Submit the generated code** as a PR
4. **Include the transcript** in the PR description (optional but encouraged)
5. **Let reviewers** verify the code works as intended

### Example Commit Message

```
✅ Good:
feat: Add CSV export functionality

Added export button and file save dialog for usage data.

Generated-By: Claude Sonnet 4.5
Prompted-By: @username
Prompt: "Add a CSV export feature to the menubar popover..."

❌ Bad:
feat: Add CSV export

(No mention of AI assistance)
```

### What We Accept

- ✅ AI-generated code with human review
- ✅ Prompts and conversation transcripts
- ✅ Prompt templates and patterns
- ✅ Architecture discussions and designs
- ✅ Bug reports and feature requests
- ✅ Documentation improvements (AI-generated is fine)
- ✅ Test cases (AI-generated or manual)

### What We Question

- ⚠️ Manually written code when AI could have done it
- ⚠️ Code without attribution to AI tools used
- ⚠️ PRs without any testing or validation

## Enforcement Responsibilities

Project maintainers are responsible for clarifying and enforcing our standards of acceptable behavior and will take appropriate and fair corrective action in response to any behavior that they deem inappropriate, threatening, offensive, or harmful.

**Special note**: We won't reject your PR if you manually wrote code, but we will ask "why didn't you just ask Claude?" 😉

## Scope

This Code of Conduct applies within all community spaces, and also applies when an individual is officially representing the community in public spaces. This includes GitHub issues, pull requests, Discord/Slack channels, social media, and conversations with AI assistants about this project.

## The Future is Now

This project is a testament to what's possible when humans and AI collaborate effectively. We're not just building a menubar app - we're demonstrating a new way of developing software.

**The role of developers is evolving:**
- From code writers → to prompt engineers
- From implementation → to architecture and verification
- From syntax experts → to problem solvers

Welcome to the future. Let's build it together (with AI doing most of the typing).

## Enforcement

Instances of abusive, harassing, or otherwise unacceptable behavior may be reported to the project maintainers. All complaints will be reviewed and investigated promptly and fairly.

## Attribution

This Code of Conduct is ~~adapted from~~ **evolved from** the [Contributor Covenant][homepage], version 2.0, with significant modifications for the AI-native development era.

The future modifications were generated by Claude Sonnet 4.5 at the request of Petr Guan on 2026-02-16.

[homepage]: https://www.contributor-covenant.org

---

*P.S. - Yes, this Code of Conduct was itself AI-generated. Naturally.*
