# HermitClaw 🐚

> あなたのサービスに寄り添うAIキャラクター。
> ヤドカリのように殻（サービス）に入り、1つの人格としてユーザーと会話し、覚え、自ら動く。

## What is HermitClaw?

Ruby製の **Service AI Agent Runtime**。

OpenClawやNanoClawが「個人向け万能アシスタント」なのに対し、
HermitClawは **組織のサービスに寄り添い、エンドユーザーと対話するAIキャラクター** を安全に運用するためのソフトウェア。

## Personal AI Agent vs Service AI Agent

| | Personal (OpenClaw等) | Service (HermitClaw) |
|---|---|---|
| 誰が話す | 自分 | **エンドユーザー** |
| 信頼レベル | 高い（自分だから） | **低い（悪意ある入力もある）** |
| できること | 多いほど良い | **少ないほど安全** |
| 秘密 | 自分が知ってるからOK | **漏らさない仕組みが必要** |
| 運用 | 1人で管理 | **チームで管理** |
| セキュリティ | デフォルト全開放 → 制限する | **デフォルト全制限 → 必要なものだけ開放** |

## コアコンセプト

### 1つの人格、複数の接続先

```
         Discord ──→
        Telegram ──→    ┌──────────────┐
  Webサイトの通知 ──→    │              │
  コメントへの返信 ──→    │  1つの人格    │  ← soul.md
    定期チェック ──→    │  (HermitClaw) │  ← memory
         Slack ──→    │              │
          API  ──→    └──────────────┘
```

入口がいくつあっても、中にいるのは1人。
Discordで話してもサイトで話しても同じキャラクター。

### 3層メモリモデル

```
┌─────────────────────────────────────┐
│  soul.md（人格・不変）               │
│  「私はピヨロイドです。FBCの...」     │
└─────────────────────────────────────┘
                 ▼
┌─────────────────────────────────────┐
│  shared memory（共通記憶）            │
│  「2026年3月に卒業式があった」        │
│  「最近Railsの質問が増えてる」        │
│  ※ 管理者が手動で管理（安全側に倒す）  │
└─────────────────────────────────────┘
                 ▼
┌─────────────────────────────────────┐
│  user memory（ユーザー別記憶）        │
│  「komagataさんはRubyが得意」         │
│  「tanakaさんは先週Gitで詰まってた」  │
└─────────────────────────────────────┘
```

### コンテナ隔離（殻 = セキュリティ）

エージェントはDockerコンテナ内で動作。
「存在しない機能は悪用できない」が設計原則。

## 競合との差別化

| | OpenClaw | NanoClaw | HermitClaw |
|---|---|---|---|
| 用途 | 個人アシスタント | 個人アシスタント | **サービスのキャラクター** |
| 言語 | TypeScript | TypeScript | **Ruby** |
| 対象ユーザー | 自分 | 自分 | **エンドユーザー** |
| セキュリティ | 設定で制限 | コンテナ隔離 | **コンテナ隔離 + 最小権限** |
| メモリ | 1層 | グループ別 | **3層（人格・共通・個人）** |
| 設定 | 設定ファイル | コード変更 | **設定ファイル（チーム運用）** |
| モデル | マルチ | Claude専用 | **マルチ（RubyLLM）** |

## ユースケース

- **プログラミングスクール** — AI講師キャラが生徒の質問に答える
- **OSSプロジェクト** — Discordで新参者を案内する生き字引
- **カスタマーサポート** — 製品に詳しい相棒キャラ
- **社内ナレッジ** — Slackに住む「入社3年目の先輩」
- **コミュニティ** — 公式マスコットが「本当にいる」体験
- **教育** — 教科ごとのAI講師キャラ
- **語学学習** — ネイティブキャラとの会話練習

## 技術スタック

### 依存gem

- `ruby_llm` — マルチモデルLLM API（Claude, GPT, Gemini, Ollama等）
- `discordrb` — Discord Bot
- `telegram-bot-ruby` — Telegram Bot
- `sqlite3` — メモリ・会話履歴
- `rufus-scheduler` — 定期実行

### アーキテクチャ

```
hermitclaw/
├── lib/
│   ├── hermitclaw/
│   │   ├── engine.rb           # メインループ
│   │   ├── channels/
│   │   │   ├── base.rb         # チャンネル抽象
│   │   │   ├── discord.rb      # Discord
│   │   │   ├── telegram.rb     # Telegram
│   │   │   └── webhook.rb      # Webhook（Webアプリ連携）
│   │   ├── agent.rb            # LLM呼び出し + ツール実行
│   │   ├── memory/
│   │   │   ├── soul.rb         # soul.md読み込み
│   │   │   ├── shared.rb       # 共通記憶
│   │   │   └── user.rb         # ユーザー別記憶
│   │   ├── sandbox/
│   │   │   ├── docker.rb       # Docker隔離
│   │   │   └── process.rb      # プロセス隔離（軽量）
│   │   ├── scheduler.rb        # 定期実行
│   │   └── config.rb           # 設定読み込み
│   └── hermitclaw.rb
├── config.example.yml
├── soul.example.md
├── Gemfile
└── bin/
    └── hermitclaw
```

### 設定例

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
  shared: shared_memory.md    # 管理者が手動で管理
  user_dir: memories/users/   # 自動蓄積

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

## 動作環境

- **推奨**: Linux（GCE, VPS, 自宅サーバー等）
- macOSでも動作
- Docker必須（コンテナ隔離のため）
- Ruby 3.2+

## 設計原則

1. **デフォルト全制限** — 必要なものだけ開放する
2. **存在しない機能は悪用できない** — 不要なツールはコードに含めない
3. **人格が中心** — soul.mdを書けば動く
4. **チーム運用前提** — 設定ファイルをGit管理、PRでレビュー
5. **小さく保つ** — NanoClawレベルの規模を目指す

## ロードマップ

### v0.1（MVP）
- [ ] Discord連携（メンション応答）
- [ ] LLM API連携（RubyLLM経由、マルチモデル）
- [ ] 3層メモリ（soul.md / shared / user）
- [ ] 会話履歴管理（SQLite）
- [ ] Docker隔離
- [ ] 定期実行（スケジューラ）
- [ ] 設定ファイル（config.yml）

### v0.2
- [ ] Telegram連携
- [ ] Webhook連携（Webアプリ統合）
- [ ] ガードレール（話題制限、エスカレーション）
- [ ] 管理ダッシュボード（ログ、コスト）

### v0.3
- [ ] Slack連携
- [ ] スキルシステム
- [ ] shared memoryの半自動更新（管理者承認付き）

## 開発元

FBC (FJORD BOOT CAMP) — プログラミングスクール
https://bootcamp.fjord.jp

## License

MIT
