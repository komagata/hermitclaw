# HermitClaw 🐚

> An AI character that lives in your service.
> Like a hermit crab finding its shell, HermitClaw inhabits your service with a single personality — talking to users, remembering them, and acting on its own.

## What is HermitClaw?

A **Service AI Agent Runtime** built in Ruby.

While OpenClaw and NanoClaw are "personal AI assistants for yourself," HermitClaw is designed to **safely run an AI character that serves end-users on behalf of an organization**.

## Personal AI Agent vs Service AI Agent

| | Personal (OpenClaw, etc.) | Service (HermitClaw) |
|---|---|---|
| Who talks to it | Yourself | **End-users** |
| Trust level | High (it's you) | **Low (potentially adversarial input)** |
| Capabilities | More is better | **Less is safer** |
| Secrets | You know them, so it's fine | **Must never leak** |
| Operations | Solo | **Team-managed** |
| Security | Open by default → restrict | **Restricted by default → open as needed** |

## Core Concepts

### One Personality, Multiple Channels

```
         Discord ──→
        Telegram ──→    ┌──────────────┐
  Website notifications ──→ │              │
  Comment replies ──→    │  One personality │  ← soul.md
  Scheduled checks ──→  │  (HermitClaw)    │  ← memory
         Slack ──→    │              │
          API  ──→    └──────────────┘
```

No matter how many entry points exist, there's only one character inside.
Whether users talk on Discord or on your website, they meet the same personality.

### 3-Layer Memory Model

```
┌─────────────────────────────────────┐
│  soul.md (personality — immutable)  │
│  "I'm Pjoroid, the mascot of FBC…" │
└─────────────────────────────────────┘
                 ▼
┌─────────────────────────────────────┐
│  shared memory (collective)         │
│  "Graduation ceremony in March 2026"│
│  "Rails questions trending lately"  │
│  ※ Managed manually by admins       │
│    (fail-safe by design)            │
└─────────────────────────────────────┘
                 ▼
┌─────────────────────────────────────┐
│  user memory (per-user)             │
│  "komagata is good at Ruby"         │
│  "tanaka struggled with Git"        │
└─────────────────────────────────────┘
```

### Container Isolation (Shell = Security)

Agents run inside Docker containers.
The design principle: **capabilities that don't exist can't be exploited**.

## Differentiation

| | OpenClaw | NanoClaw | HermitClaw |
|---|---|---|---|
| Purpose | Personal assistant | Personal assistant | **Service character** |
| Language | TypeScript | TypeScript | **Ruby** |
| Target user | Self | Self | **End-users** |
| Security | Config-based restrictions | Container isolation | **Container isolation + least privilege** |
| Memory | Single layer | Per-group | **3-layer (soul / shared / user)** |
| Configuration | Config files | Code changes | **Config files (team-friendly)** |
| Models | Multi-model | Claude only | **Multi-model (RubyLLM)** |

## Use Cases

- **Programming schools** — AI tutor character that answers student questions
- **OSS projects** — A living guide on Discord that onboards newcomers
- **Customer support** — A product-savvy companion character
- **Internal knowledge** — A "3rd-year employee" living in Slack
- **Communities** — Official mascot that feels truly "alive"
- **Education** — Subject-specific AI tutor characters
- **Language learning** — Conversation practice with a native-speaker character

## Tech Stack

### Dependencies

- `ruby_llm` — Multi-model LLM API (Claude, GPT, Gemini, Ollama, etc.)
- `discordrb` — Discord Bot
- `telegram-bot-ruby` — Telegram Bot
- `sqlite3` — Memory & conversation history
- `rufus-scheduler` — Scheduled tasks

### Architecture

```
hermitclaw/
├── lib/
│   ├── hermitclaw/
│   │   ├── engine.rb           # Main loop
│   │   ├── channels/
│   │   │   ├── base.rb         # Channel abstraction
│   │   │   ├── discord.rb      # Discord
│   │   │   ├── telegram.rb     # Telegram
│   │   │   └── webhook.rb      # Webhook (web app integration)
│   │   ├── agent.rb            # LLM calls + tool execution
│   │   ├── memory/
│   │   │   ├── soul.rb         # soul.md loader
│   │   │   ├── shared.rb       # Shared memory
│   │   │   └── user.rb         # Per-user memory
│   │   ├── sandbox/
│   │   │   ├── docker.rb       # Docker isolation
│   │   │   └── process.rb      # Process isolation (lightweight)
│   │   ├── scheduler.rb        # Scheduled tasks
│   │   └── config.rb           # Config loader
│   └── hermitclaw.rb
├── config.example.yml
├── soul.example.md
├── Gemfile
└── bin/
    └── hermitclaw
```

### Example Configuration

```yaml
# config.yml
llm:
  provider: openai
  model: gpt-4o
  # provider: anthropic
  # model: claude-sonnet-4-20250514

channels:
  discord:
    token: ${DISCORD_TOKEN}

soul: soul.md

memory:
  backend: sqlite
  shared: shared_memory.md    # Managed manually by admins
  user_dir: memories/users/   # Auto-accumulated

sandbox:
  backend: docker

schedule:
  check_notifications:
    every: 3m
    action: check_bootcamp_notifications

integrations:
  bootcamp:
    notifications_url: https://bootcamp.example.com/api/notifications
    comments_url: https://bootcamp.example.com/api/comments
    token: ${BOOTCAMP_API_TOKEN}
```

## Requirements

- **Recommended**: Linux (GCE, VPS, home server, etc.)
- Also works on macOS
- Docker required (for container isolation)
- Ruby 3.2+

## Design Principles

1. **Restricted by default** — Only open what's needed
2. **Non-existent capabilities can't be exploited** — No unnecessary tools in the codebase
3. **Personality at the center** — Write a soul.md and it runs
4. **Built for team operations** — Config files in Git, reviewed via PRs
5. **Keep it small** — Aim for NanoClaw-level codebase size

## Roadmap

### v0.1 (MVP)
- [ ] Discord integration (mention response)
- [ ] LLM API integration (multi-model via RubyLLM)
- [ ] 3-layer memory (soul.md / shared / user)
- [ ] Conversation history (SQLite)
- [ ] Docker isolation
- [ ] Scheduled tasks
- [ ] Config file (config.yml)

### v0.2
- [ ] Telegram integration
- [ ] Webhook integration (web app connectivity)
- [ ] Guardrails (topic restrictions, escalation)
- [ ] Admin dashboard (logs, costs)

### v0.3
- [ ] Slack integration
- [ ] Skills system
- [ ] Semi-automated shared memory updates (with admin approval)

## Built by

FBC (FJORD BOOT CAMP) — Programming School
https://bootcamp.fjord.jp

## License

MIT
