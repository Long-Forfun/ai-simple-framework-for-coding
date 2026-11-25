# AI-Augmented Product Development — A Simple Skill

[![npm version](https://img.shields.io/npm/v/ai-simple.svg)](https://www.npmjs.com/package/ai-simple)

**TL;DR (30 giây):**
- **Cho ai?** Dev/team dùng AI coding agent (Claude Code, Cursor, Aider) trên project ≥ 30 file có business logic thật.
- **Giải lỗi gì?** AI hallucinate tên hàm/file, đọc lan man tốn token, doc lệch code rồi AI tin doc cũ, hỏi confirm lặt vặt, không ai biết restart con bot.
- **Cài thế nào?** `npx ai-simple init` — cài hook + doc-health + templates + workflow, tự set hooksPath, tự chạy self-test. Fallback không dùng CLI: copy 3 template (CLAUDE.md, app-map, hook) + `git config core.hooksPath .githooks`.
- **Được gì?** Session AI mới onboard < 1 phút; mọi doc gắn code có trạng thái VERIFIED/SUSPECT máy tính từ git — doc sai **không lọt vào suy luận của AI mà chưa qua đối chiếu**; commit đổi code mà quên doc bị chặn tại chỗ.
- **6 lớp:** Core (context + routing + sync) → Scale (enforcement + generated docs + contract) → Ops (runbook + registry) → Optimization & Learning (coupling map + 2 cổng verify + học từ accepted diffs + /audit) → Collaboration (lot MECE + claim + worktree + merge queue cho nhiều session song song) → Security (secret-scan + doc prompt-injection lint + declared-coverage, map OWASP LLM + web). Versions: xem [CHANGELOG.md](CHANGELOG.md).

> **VI**: Phương pháp đơn giản để tổ chức một dự án phần mềm khi đồng hành cùng AI coding agent (Claude Code, Cursor, Aider, …). Không phải framework, không phải tool — là **bộ nguyên tắc + template + script đã test** giúp AI hiểu codebase nhanh, không hallucination, không bloat context.
>
> **EN**: A simple skill for organizing a software project when pair-programming with an AI coding agent (Claude Code, Cursor, Aider, …). Not a framework, not a tool — a **set of principles + templates + tested scripts** that help the AI understand the codebase quickly, without hallucination, without context bloat.

---

## Tại sao cần / Why this exists

### VI
Khi dev với AI agent, 3 vấn đề phổ biến:
1. **Cold start tốn token** — session mới phải re-explain codebase từ đầu
2. **AI hallucinate** — đoán file/function/business rule không tồn tại
3. **Doc lệch code** — code đổi nhưng doc không đổi → AI đọc doc cũ → đề xuất sai

Phương pháp này giải 3 vấn đề trên bằng:
- **Hierarchical context** thay vì 1 file root khổng lồ
- **App-map docs** đánh số, mỗi file 1 chủ đề canonical
- **Context routing** qua slash command + sub-agent
- **Doc + Test sync invariant** — code change BẮT BUỘC pair với doc + test cùng commit
- **LOGIC vs REQUEST classification** — tách câu hỏi với câu yêu cầu

**Lớp Scale** (khi project phình to — vấn đề thứ 4: *phương pháp tự giác sẽ drift*):
- **Automated enforcement** — pre-commit hook chặn vi phạm thay vì dựa kỷ luật
- **Generated vs authored docs** — schema/route/inventory máy sinh, người chỉ viết "tại sao"
- **Cross-repo contract** — schema dùng chung giữa nhiều repo có contract đánh version

**Lớp Optimization & Learning** (vấn đề thứ 5: *hệ chỉ biết phát hiện mà không biết tự chữa thì điểm chỉ đi xuống theo thời gian*):
- **Evidence-driven self-evolution** — vòng A: coupling map (`covers`/`last_verified`/`ttl_days`) + 2 cổng: cổng GHI (hook chặn code-đổi-mà-doc-không-re-verify cùng commit) và cổng ĐỌC (doc SUSPECT phải được đối chiếu với code trước khi AI tin) + doc-lag/hotspot + `/audit` neo metric; vòng B: học từ **diff được user chấp nhận** (SHA là evidence — hết cảnh sửa AI cùng một kiểu mãi); vòng C: nâng skill qua branch + regression test + rollback

**Lớp Collaboration** (vấn đề thứ 6: *hai session song song giẫm chân nhau — merge conflict, lost work, không ai biết ai đang sửa gì*):
- **Git-native parallel sessions** — chia lot MECE theo business entity + DAG/waves, claim atomic có lease (CLI `ai-simple parallel`), worktree per lot, integration branch + merge queue tuần tự có journal/crash-recovery; dirty work của user là bất khả xâm phạm. Kèm bộ test nghiệm thu chạy được (`ai-simple parallel self-test` — race atomic 100 lượt, concurrent-merge không silent-loss, crash-resume, dirty-protection; số test hiện hành: CHANGELOG) + claim gate trong pre-commit hook.

**Lớp Security** (vấn đề thứ 7: *"AI đọc docs rồi viết code" tạo/khuếch đại 3 lớp rủi ro — lỗ hổng trong code AI viết, docs độc tiêm lệnh vào AI (prompt-injection), CVE từ thư viện; và cám dỗ dán "đã bảo mật ✓" tạo cảm giác an toàn giả*):
- **Security as a declared gate** — cổng shift-left có KHAI BÁO phủ sóng (3 vùng: A git-time enforced / B CI point-to-tool / C production=NON-GOAL). Enforced ở pre-commit: **secret-scan** (private key/AWS/PAT/token → BLOCK, loại placeholder) + **doc prompt-injection lint** (câu mệnh-lệnh-hướng-agent trong app-map/CLAUDE.md → BLOCK — LLM01, bề mặt tấn công độc nhất của hệ vì docs là input trực tiếp vào AI), cả hai có fixture `--self-test` chạy qua `npm test`. SCA dependency audit ở CI (point-to-tool). Mọi finding map **OWASP LLM Top-10 + OWASP Top-10 web** ngang hàng. Non-goal thẳng thắn: **KHÔNG thay pentest/DAST production** — hệ chỉ sinh runbook kích hoạt. Skill `security-logic` là phần "não".

### EN
When pair-programming with an AI agent, 3 common pain points:
1. **Cold start burns tokens** — every new session must re-explain the codebase
2. **AI hallucinates** — invents files/functions/business rules that don't exist
3. **Docs drift from code** — code changes, docs don't → AI reads stale docs → wrong suggestions

This methodology solves all 3 with:
- **Hierarchical context** instead of one giant root file
- **Numbered app-map docs**, each file = one canonical topic
- **Context routing** via slash command + sub-agent
- **Doc + Test sync invariant** — code changes MUST ship with doc + test in the same commit
- **LOGIC vs REQUEST classification** — separate questions from action requests

**Scale layer** (for when the project grows — pain point #4: *honor-system methodology drifts*):
- **Automated enforcement** — pre-commit hooks block violations instead of relying on discipline
- **Generated vs authored docs** — schemas/routes/inventories are machine-generated; humans only write the "why"
- **Cross-repo contract** — schemas shared across repos get a versioned contract file

**Optimization & Learning layer** (pain point #5: *a system that only detects but never heals itself trends downward*):
- **Evidence-driven self-evolution** — loop A: a doc↔code coupling map (`covers`/`last_verified`/`ttl_days`) + two gates: WRITE (hook blocks code-changed-without-doc-reverify in the same commit) and READ (SUSPECT docs must be checked against real code before the AI relies on them) + doc-lag/hotspot metrics + a metric-anchored `/audit`; loop B: learning from **user-accepted diffs** (SHAs are the evidence); loop C: skill evolution via branches + regression tests + rollback

**Collaboration layer** (pain point #6: *parallel sessions stepping on each other — merge conflicts, lost work, nobody knows who's editing what*):
- **Git-native parallel sessions** — MECE lots by business entity + DAG/waves, atomic leased claims (`ai-simple parallel` CLI), worktree per lot, integration branch + serial merge queue with journal/crash-recovery; the user's dirty work is inviolable. Ships with a runnable acceptance suite (`ai-simple parallel self-test` — 100-attempt atomic race, concurrent-merge no-silent-loss, crash-resume, dirty-protection; current count: CHANGELOG) + a claim gate in the pre-commit hook.

**Security layer** (pain point #7: *an "AI reads docs then writes code" system creates/amplifies three risk classes — vulns in AI-written code, poisoned docs injecting instructions into the AI (prompt injection), CVEs from libraries; plus the temptation to stamp "secured ✓" which is itself false assurance*):
- **Security as a declared gate** — a shift-left gate with DECLARED coverage (3 zones: A git-time enforced / B CI point-to-tool / C production=NON-GOAL). Enforced at pre-commit: **secret-scan** (private key/AWS/PAT/token → BLOCK, placeholders excluded) + **doc prompt-injection lint** (agent-directed imperatives in app-map/CLAUDE.md → BLOCK — LLM01, this system's unique attack surface since docs are direct input to the AI), both with `--self-test` fixtures run by `npm test`. SCA dependency audit in CI (point-to-tool). Every finding maps to **OWASP LLM Top-10 + OWASP Top-10 web** as equals. Honest non-goal: **does NOT replace production pentest/DAST** — the system only emits a runbook to trigger it. The `security-logic` skill is the reasoning layer.

**Roadmap** (đang cân nhắc / under consideration): `examples/` repo before/after (Next.js+Supabase, Python agent) với số đo onboard-time và doc-lag thật; parallel benchmark đo speedup/overhead ex-post; scripts Phase 4–5 (decision-extract/compile tự động — xem `docs/adr/001`).

---

## Quick start

### Cách 1 — CLI (khuyến nghị / recommended)

> ⚠ Nếu `npx ai-simple` báo 404 (npm chưa có bản mới nhất): dùng
> `npx github:Long-Forfun/ai-simple--skill-product-dev init`, hoặc clone repo rồi chạy
> `node <repo>/bin/ai-simple.js init` trong project của bạn.
> Windows: lần chạy đầu gồm self-test hook nên mất ~1-2 phút — bình thường, các lần sau không lặp.

```bash
npx ai-simple init                  # cài hook + doc-health + templates + workflow, set hooksPath, chạy self-test
npx ai-simple init --profile tiny   # project < 10 file: chỉ CLAUDE.md + risk tier, chi phí ≈ 0
npx ai-simple init --stack prisma   # default: supabase; còn có: custom
npx ai-simple doctor                # khám setup: version drift, self-tests, budget, covers + báo bản mới (npm/GitHub, offline bỏ qua)
npx ai-simple update                # nâng hook/script/command lên bản mới bằng GỘP 3 CHIỀU — giữ config + gate/câu chữ project tự thêm (backup .bak; xung đột → không ghi, để .ai-simple-merge) + in checklist RE-APPLY
npx ai-simple doc-health --ci       # gate fail PR; doc-status: regenerate trạng thái doc
npx ai-simple parallel plan|claim|ready|merge|recover   # ≥ 2 session song song (nguyên tắc 13)
```

Song song nhiều AI session: đi tay từng bước ở [docs/walkthroughs/parallel-sessions.md](docs/walkthroughs/parallel-sessions.md).

Sau `init`, hệ chạy theo **sự kiện** — không có lệnh nào phải nhớ: commit → hook chặn sai;
PR → CI fail nếu doc-lag; AI đọc doc → cổng đọc bắt verify. Phần "não" (`/fl`, `/audit`,
verify-on-use) dùng qua Claude Code skill — CLI chỉ đóng gói phần máy chạy-không-cần-AI.

### Cài 5 skill vào Claude Code (bắt buộc để có phần "não")

`init` cài phần MÁY vào project; phần NÃO là 5 skill — Claude Code phải nhìn thấy chúng trong
`~/.claude/skills/`. Clone repo này rồi link (Windows dùng Git Bash, hoặc `mklink /J` trong cmd):

```bash
git clone https://github.com/Long-Forfun/ai-simple--skill-product-dev
cd ai-simple--skill-product-dev
ln -s "$(pwd)/skills/ai-simple-product-dev" ~/.claude/skills/ai-simple-product-dev
ln -s "$(pwd)/skills/ba-flow-logic" ~/.claude/skills/ba-flow-logic
ln -s "$(pwd)/skills/ui-design-logic" ~/.claude/skills/ui-design-logic
ln -s "$(pwd)/skills/ui-ux-triage" ~/.claude/skills/ui-ux-triage
ln -s "$(pwd)/skills/security-logic" ~/.claude/skills/security-logic
```

Link (không copy) để `git pull` là mọi project nhận bản skill mới. Mở phiên Claude Code mới là
skill tự kích hoạt theo tình huống (xem "Không cần nhớ lệnh" bên dưới).

### First win — thấy hook chặn thật trong 2 phút

```bash
printf '> Load khi: task chạm orders\ncovers: src/orders\nlast_verified: 2020-01-01\nttl_days: 90\n\n# Orders\n' > docs/app-map/10-orders.md
mkdir -p src/orders && echo "export const approve = () => true" > src/orders/approve.ts
git add -A && git commit -m "orders: doc + code"
echo "// changed" >> src/orders/approve.ts
git add -A && git commit -m "orders: đổi code, quên doc"   # ← hook BLOCK tại đây
```

Commit thứ hai bị chặn: code trong vùng `covers:` đổi mà doc không sửa/re-verify — đây chính là
lời hứa "doc lệch code không lọt vào suy luận của AI". Sửa doc (hoặc bump `last_verified` kèm
message `re-verify(...)`) rồi commit lại là qua.

### Cách 2 — copy tay (5 phút / 5 min)

### VI
1. Copy `templates/CLAUDE.md.template` → root project, đổi thành `CLAUDE.md`
2. Tạo thư mục `docs/app-map/` + copy `templates/app-map-README.md.template` vào
3. Tạo `.claude/commands/fl.md` từ `templates/fl.command.md.template`
4. Tạo `.claude/agents/context-router.md` từ `templates/context-router.agent.md.template`
5. Cài hook versioned: `mkdir .githooks` → copy `templates/pre-commit.hook.template` vào `.githooks/pre-commit` → `git config core.hooksPath .githooks` → commit folder `.githooks` (sửa 3 biến CONFIG nếu không phải Supabase; verify: `sh .githooks/pre-commit --self-test`)
6. Đọc `methodology/README.md` để hiểu 15 nguyên tắc

### EN
1. Copy `templates/CLAUDE.md.template` → project root, rename to `CLAUDE.md`
2. Create `docs/app-map/` directory, copy `templates/app-map-README.md.template` into it
3. Create `.claude/commands/fl.md` from `templates/fl.command.md.template`
4. Create `.claude/agents/context-router.md` from `templates/context-router.agent.md.template`
5. Install the versioned hook: `mkdir .githooks` → copy `templates/pre-commit.hook.template` to `.githooks/pre-commit` → `git config core.hooksPath .githooks` → commit `.githooks` (edit the 3 CONFIG vars if not Supabase; verify: `sh .githooks/pre-commit --self-test`)
6. Read `methodology/README.md` to grasp the 15 principles

---

## Cấu trúc repo / Repo structure

```
ai-simple--skill-product-dev/
├── README.md                    # This file
├── CHANGELOG.md                 # Lịch sử version (README chỉ dùng tên lớp)
├── skills/ai-simple-product-dev/SKILL.md  # foundation skill — operating layer (auto-discoverable)
├── bin/ai-simple.js             # CLI zero-dependency: init/doctor/update/doc-status/doc-health/parallel
├── lib/parallel.js              # Nguyên tắc 13: claim atomic + merge queue CAS + test nghiệm thu (số: CHANGELOG)
├── docs/adr/                    # ADR-001: thiết kế vNext (Git-native parallel + learning) + roadmap 5 phase
├── skills/                      # 4 skill con: ba-flow-logic, ui-design-logic, ui-ux-triage, security-logic
├── methodology/                 # 15 principles, deep-dive
│   ├── README.md                # Principles index
│   ├── 01-hierarchical-context.md
│   ├── 02-app-map-pattern.md
│   ├── 03-context-routing.md
│   ├── 04-doc-test-sync.md
│   ├── 05-logic-vs-request.md
│   ├── 06-pre-flight-checklist.md       # v3 — risk tier: tự chạy default an toàn, confirm chỉ khi RED
│   ├── 07-memory-as-feedback.md
│   ├── 08-automated-enforcement.md      # v2 — hook chặn, lint, report drift
│   ├── 09-generated-vs-authored-docs.md # v2 — máy sinh "cái gì", người viết "tại sao"
│   ├── 10-cross-repo-contract.md        # v2 — schema chung = contract đánh version
│   ├── 11-ops-layer.md                  # v2.2 — runbook, state registry, routing sự cố
│   ├── 12-self-optimization.md          # v3 — 3 vòng: coupling map + 2 cổng; học từ accepted diffs; skill evolution
│   ├── 13-parallel-sessions.md          # v1 shipped — lot MECE, claim atomic, worktree, merge queue CAS + test suite (số: CHANGELOG)
│   └── 14-security-gate.md              # v1 shipped — secret-scan + doc prompt-injection lint (LLM01) + declared-coverage, map OWASP LLM+web
└── templates/                   # Drop-in files. Quy ước placeholder: {{TÊN_HOA}} = trường BẮT BUỘC
                                 # điền khi copy; <chữ-thường> = ví dụ minh họa hoặc biến — thay bằng
                                 # nội dung thật khi viết, giữ nguyên nếu là pattern runtime (src/<module>/).
    ├── CLAUDE.md.template
    ├── CLAUDE.tiny.md.template
    ├── app-map-README.md.template
    ├── app-map-doc.md.template
    ├── ADR.md.template
    ├── context-router.agent.md.template
    ├── ba-expert.agent.md.template      # agent chuyên gia = vỏ mỏng trỏ skill + bộ nhớ theo vai (ADR 004)
    ├── ui-expert.agent.md.template
    ├── security-expert.agent.md.template
    ├── verifier.agent.md.template       # thẩm định độc lập, mặc định CHƯA ĐẠT cho tới khi có bằng chứng
    ├── agent-memory-README.md.template  # giao thức bộ nhớ theo vai → docs/agent-memory/README.md
    ├── fl.command.md.template
    ├── pre-commit.hook.template         # v2 — enforcement hook (chạy được ngay với default Supabase)
    ├── doc-health-report.sh.template    # v4 — doc-lag, symbol chết, broken links, lint, --status, --self-test
    ├── runbook.md.template              # v2.2 — runbook per service chạy nền
    ├── state-registry.md.template       # v2.2 — registry canonical cho state files
    ├── ops-schedules.md.template        # v3.0 — registry mọi cron/scheduled job
    ├── ops-external-services.md.template# v3.0 — registry API ngoài (token, rate limit, khi chết)
    ├── audit.command.md.template        # /audit: chấm 15 nguyên tắc theo applicability → backlog tối ưu
    ├── learn.command.md.template        # /learn: learning event từ accepted diff (12 v3 vòng B)
    ├── doc-health.workflow.yml.template # GitHub Actions: self-test + --status + --ci gate + SCA audit + artifact
    ├── contract-doc.md.template         # cross-repo contract
    └── security-review.md.template      # v1 — security review declared-coverage + map OWASP (14), cổng security-verify.sh
```

---

## Không cần nhớ lệnh / You don't need to remember commands

### VI
Cài xong, cứ **nói tự nhiên** — skill tự kích hoạt theo tình huống, không cần nhớ tên skill hay command:

| Bạn nói | Hệ tự route |
|---|---|
| "Tôi muốn làm app quản lý đơn hàng" (còn mơ hồ) | `ba-flow-logic` — phân tích nghiệp vụ → ba-spec |
| "Thiết kế dashboard cho phần này" | `ui-design-logic` — pipeline 7 bước → design-spec |
| "Màn này xấu quá / nhìn như AI" | `ui-design-logic` diagnose 4-case (xấu vì gì → sửa đúng cửa) |
| "Bấm nút duyệt bị lỗi" + screenshot | `ui-ux-triage` — test như user thật, fix qua cổng risk |
| "Bot chết lúc 2h sáng / cron không chạy" | Nguyên tắc 11 — runbook trước code |
| "Repo này nhiều AI session cùng sửa" | Nguyên tắc 13 — `ai-simple parallel` |
| "Chỗ này có lỗ hổng không / review bảo mật / doc này có bị inject không" | `security-logic` (NT14) — khai vùng phủ, map OWASP, KHÔNG "đã bảo mật ✓" |

Slash command chỉ là đường tắt cho 3 quy trình máy: `/fl` (routing log), `/audit` (verify quý), `/learn` (học từ diff đã accept).

### EN
After install, just **speak naturally** — skills self-activate from context; no command names to memorize. "Design a dashboard" → design skill; "this screen looks AI-generated" → 4-case diagnose; "the approve button errors" + screenshot → triage; "the bot died at 2am" → runbook-first. Slash commands are shortcuts for the 3 machine workflows only (`/fl`, `/audit`, `/learn`).

---

## Khi nào dùng / When to use

### VI — Phù hợp khi
- Project ≥ 30 file, có business logic phức tạp
- Có nhiều người (kể cả AI agent) cùng đụng codebase
- Có DB + auth + nhiều flow → cần tách concern
- Muốn AI session mới onboard < 1 phút

### VI — Không cần khi
- Throwaway script, prototype 1 file
- Pure library không có business rule
- Solo dev, project < 10 file

### EN — Use when
- Project ≥ 30 files, with non-trivial business logic
- Multiple contributors (humans + AI agents) touch the codebase
- DB + auth + many flows → need separation of concerns
- You want a fresh AI session to onboard in < 1 minute

### EN — Skip when
- Throwaway scripts, single-file prototypes
- Pure libraries with no business rules
- Solo dev, project under 10 files

---

## Triết lý / Philosophy

> **VI**: AI không phải là intern thông minh — AI là một **đồng nghiệp chỉ đọc tài liệu của bạn**. Tài liệu tốt = đồng nghiệp tốt. Phương pháp này không cố ép AI thông minh hơn, mà ép **bạn viết tài liệu tốt hơn**.
>
> **EN**: AI is not a smart intern — AI is **a colleague who only reads your docs**. Good docs = good colleague. This methodology doesn't try to make AI smarter; it forces **you to write better docs**.

---

## Đóng góp / Contributing

Mở issue/PR nếu có **pattern** hay từ project của bạn — chỉ cần phương pháp đã work, không cần kèm code thực tế.

Open an issue/PR with **patterns** from your own project — only the approach that worked, no real code needed.
