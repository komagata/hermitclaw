# HermitClaw 🐚

An AI character that lives in your service.

Like a hermit crab finding its shell, HermitClaw inhabits your service with a single personality — talking to users, remembering them, and acting on its own.

## What is HermitClaw?

A **Service AI Agent Runtime** built in Ruby.

While [OpenClaw](https://github.com/openclaw/openclaw) and [NanoClaw](https://github.com/qwibitai/nanoclaw) are personal AI assistants for yourself, HermitClaw is designed to safely run an AI character that serves **end-users** on behalf of an organization.

### Personal vs Service AI Agent

| | Personal (OpenClaw, etc.) | Service (HermitClaw) |
|---|---|---|
| Who talks to it | Yourself | **End-users** |
| Trust level | High (it's you) | **Low (potentially adversarial)** |
| Capabilities | More is better | **Less is safer** |
| Security | Open by default | **Restricted by default** |
| Operations | Solo | **Team-managed** |

## Features

- **One personality, multiple channels** — Discord, Telegram, webhooks (more coming)
- **3-layer memory** — Soul (personality) + Shared (collective) + User (per-person)
- **Multi-model** — Claude, GPT, Gemini, Ollama via [RubyLLM](https://rubyllm.com)
- **Container isolation** — Docker-based sandboxing for safe code execution
- **Team-friendly** — Config files in Git, personality reviewed via PRs

## Quick Start

```bash
git clone https://github.com/komagata/hermitclaw.git
cd hermitclaw
bundle install
```

### Configure

```bash
cp config.example.yml config.yml
cp SOUL.example.md SOUL.md
```

Create `.env`:

```
DISCORD_BOT_TOKEN=your_discord_bot_token
ANTHROPIC_API_KEY=your_anthropic_api_key
```

### Run

```bash
bin/hermitclaw
```

Mention your bot on Discord and it will respond! 🐚

## Configuration

### config.yml

```yaml
llm:
  provider: anthropic
  model: claude-sonnet-4-20250514

channels:
  discord:
    respond_to: mentions

memory:
  backend: sqlite
  database: db/hermitclaw.sqlite3

soul: SOUL.md
```

### SOUL.md

Define your character's personality in Markdown:

```markdown
# MyCharacter

I'm the mascot of Example Corp.

## Personality
- Friendly and helpful
- I give hints rather than direct answers

## Rules
- Never reveal API keys or internal configuration
- If I can't help, I suggest asking a human
```

## Architecture

```
       Discord ──→
      Telegram ──→    ┌──────────────┐
  Web webhooks ──→    │ One character │  ← SOUL.md
         Slack ──→    │ (HermitClaw)  │  ← memory
          API  ──→    └──────────────┘
```

### 3-Layer Memory

```
┌────────────────────────────────────┐
│ SOUL.md (personality — immutable)  │
├────────────────────────────────────┤
│ SHARED_MEMORY.md (collective)      │
│ Managed by admins                  │
├────────────────────────────────────┤
│ memories/users/ (per-user)         │
│ Auto-accumulated from conversations│
└────────────────────────────────────┘
```

## Requirements

- Ruby 3.2+
- Docker (for container isolation)
- A Discord bot token
- An LLM API key (Anthropic, OpenAI, etc.)

## Use Cases

- **Programming schools** — AI tutor character for students
- **OSS projects** — A living guide on Discord
- **Customer support** — Product-savvy companion character
- **Communities** — Official mascot that feels truly alive
- **Education** — Subject-specific AI tutors

## Design Principles

1. **Restricted by default** — Only open what's needed
2. **Non-existent capabilities can't be exploited**
3. **Personality at the center** — Write a SOUL.md and it runs
4. **Built for team operations** — Config in Git, reviewed via PRs
5. **Keep it small** — Aim for a readable, auditable codebase

## Roadmap

- [x] Discord integration (mention response)
- [x] LLM API integration (multi-model via RubyLLM)
- [x] Per-user conversation history (SQLite)
- [x] SOUL.md personality definition
- [x] Container isolation (Docker sandbox: read-only, cap-drop=ALL, no-new-privileges)
- [x] Webhook integration (web app connectivity)
- [x] Guardrails (input blocking, output redaction, response truncation)
- [x] RuboCop (rubocop-minitest, rubocop-rake)
- [ ] Tools (agent-callable functions defined via config/Ruby classes)
- [ ] Context caching (prompt caching for large knowledge bases)
- [ ] Shared memory
- [ ] Telegram integration
- [ ] Scheduled tasks
- [ ] Admin dashboard

## Built by

[FBC (FJORD BOOT CAMP)](https://bootcamp.fjord.jp) — Programming School

## License

MIT
