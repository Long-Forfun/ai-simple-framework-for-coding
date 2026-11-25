# 12 — Self-Optimization Loop (v3 — evidence-driven self-evolution)

> Ba vòng, một nguyên tắc: **mọi thay đổi của hệ phải có bằng chứng đo được từ Git**. Vòng A — doc mục khi code đổi, coupling map + 2 cổng giữ doc đúng LÚC DÙNG. Vòng B — học từ **diff được user chấp nhận** (SHA + diff là evidence, không phải cảm giác). Vòng C — nâng cấp skill qua Git branch + regression test + rollback. Không tạo nguyên tắc mới cho việc học: học là phần mở rộng của tự tối ưu.
> *(EN: Three loops, one rule: every change to the system needs Git-measurable evidence. Loop A — docs rot when code changes; the coupling map + two gates keep docs correct AT USE TIME. Loop B — learn from user-ACCEPTED diffs. Loop C — evolve skills via Git branches + regression tests + rollback.)*

**v2 — 2026-06-12**: thiết kế lại theo nghiên cứu (EMSE 2024: 28,9% repo top GitHub document thứ không còn tồn tại, trung bình sai 4,7 năm mới bị phát hiện; ICPC 2019: doc chỉ được sửa trong đúng commit đổi code, lỡ là sai mãi; STALE benchmark 2026: AI agent tuân theo tiền đề cũ ~70% số lần nếu staleness không được đánh dấu tường minh). Bản v1 dùng lịch tuần/tháng/quý làm trục chính — sai trục: lịch chỉ còn vai trò phụ.

**v3 — 2026-07-28**: thêm vòng B (interaction learning) + vòng C (skill evolution) theo ADR-001, đã qua hội đồng phản biện (R10–R14): hợp nhất NT07 làm fast-path của vòng B; metric là survival/correction rate đo từ git (không dùng precision/confidence tự chấm); acceptance có tầng; learned rule cũng chịu cơ chế vòng A (last_verified/SUSPECT); từng bước gắn nhãn **[ACTIVE]** (prompt-level chạy được ngay) hoặc **[CONTRACT]** (chờ scripts Phase 4–5 — audit KHÔNG chấm phần CONTRACT, chấm DEFERRED).

---

# VÒNG A — Project health (v2, giữ nguyên — toàn bộ ACTIVE)

## Xương sống: coupling map + freshness frontmatter

Mỗi app-map doc (trừ `_generated/`) khai báo trong 10 dòng đầu:

```markdown
# 03 — Database and automation
> Load khi: đụng schema, RLS, trigger, cron
covers: supabase/migrations, src/lib/db
last_verified: 2026-06-12
ttl_days: 180
```

- `covers:` — danh sách FILE/DIR **có thật** (phẩy ngăn cách) mà doc này mô tả; match anchored: đúng path đó hoặc mọi thứ bên dưới (`src/lib` KHÔNG khớp `src/lib-utils`). **Doc không có covers = doc không được bảo vệ.** Ngoại lệ hợp lệ (exemption list): README router của app-map, doc thuần decision/vision/ADR, `_generated/`. Tùy chọn `gate: warn` cho vùng code churn rất cao (mặc định block)
- `last_verified:` — ngày lần cuối nội dung doc được đối chiếu với code thật (không phải ngày sửa doc!). Mốc này chỉ được máy NÂNG lên khi commit chạm doc là **gate-1-shaped** (cùng chạm covers path) hoặc message bắt đầu `re-verify(` — commit chore/typo chạm doc KHÔNG rửa được trạng thái SUSPECT (chống laundering)
- Chi phí: symbol-scan (check hàm trong doc còn tồn tại) chạy ở report `--ci`/tuần; hook per-commit dùng `--status --fast` (skip symbol) để giữ commit nhanh — dead symbol hiếm khi cần phát hiện trong-phút
- `ttl_days:` — hạn tin cậy THEO LOẠI doc: quickstart/flow hay đổi 90; architecture/decision 365. KHÔNG dùng một ngưỡng 30 ngày đồng loạt — tuổi không phải là mục (doc 300 ngày trên code không đổi vẫn VERIFIED)

**3 trạng thái doc** (máy tính từ git, không đoán):
| Trạng thái | Điều kiện | Hành xử |
|---|---|---|
| ✅ VERIFIED | code trong `covers` không đổi sau `last_verified` VÀ chưa quá TTL | Dùng bình thường |
| ⚠️ SUSPECT | code trong `covers` đổi sau `last_verified`, HOẶC quá TTL | **Verify-on-use** (xem dưới) |
| ☠️ ORPHANED | path trong `covers` không còn tồn tại | RETIRE flow |

---

## Hai cổng đảm bảo / The two gates

**CỔNG GHI (per-commit, hook — đã ship trong template):** commit đổi code nằm trong `covers` của doc nào → doc đó PHẢI được sửa hoặc bump `last_verified` trong CÙNG commit (xác nhận "tôi đã check, nội dung vẫn đúng"). Đây là quy tắc same-commit mà toàn bộ bằng chứng hội tụ về — lỡ cửa sổ commit là doc sai trung bình nhiều năm.

**CỔNG ĐỌC (verify-on-use, router + main agent):** context-router đánh dấu trạng thái từng doc trong output (đọc từ `_generated/doc-status.md` — hook regenerate MỖI COMMIT nên luôn fresh; không có status file → doc có covers bị coi là SUSPECT, **fail-closed**). Doc SUSPECT → main agent **BẮT BUỘC đối chiếu các khẳng định nó sắp dựa vào với code thật trước khi dùng** (bound phạm vi: chỉ các claim sắp dùng, không cả doc), rồi bump `last_verified` ngay trong task. `--status` còn chèn marker `<!-- DOC-STATUS: SUSPECT -->` vào CHÍNH doc — đường đọc trực tiếp không qua `/fl` cũng thấy cờ.

**Ranh giới của lời bảo đảm (nói thẳng, không nói quá):** điều được đảm bảo bằng cơ chế là *sai sót không vượt qua được thời điểm sử dụng* khi: (1) doc-status fresh — hook regenerate mỗi commit; cửa sổ mù gồm thay đổi chưa commit **và commit lách hook bằng `--no-verify` cho tới hooked-commit hoặc lần CI kế tiếp** (defense-in-depth bắt được, nhưng có độ trễ); (2) agent đi qua `/fl` hoặc thấy marker trong doc; (3) agent tuân thủ lệnh verify — tầng cuối này là prompt-level, được gia cố bằng marker hiển thị tại chỗ (STALE: staleness phải machine-visible thì agent mới không tin tiền đề cũ) và bằng audit spot-check các lần bump (bump phải kèm commit message `re-verify(<doc>): <claims đã check>` — bump không có claims là red flag rubber-stamp); (4) attestation là gate-1-shaped, kế thừa đúng giới hạn của cổng ghi: máy xác nhận *co-change*, không xác nhận *nội dung* — và có residual hẹp: bypass trên path A của doc multi-covers có thể được "xí xóa" bởi lần làm việc hợp lệ sau đó trên path B + sửa doc (marker thường vẫn nằm trong doc nhắc người sửa, nhưng đây là lỗ được NÊU TÊN, audit soi được). Đây là giảm rủi ro rất mạnh có điều kiện nêu rõ — không phải phép màu tuyệt đối, và chính vì nêu rõ nên audit đo được từng điều kiện một.

Chi phí cổng đọc tự giảm dần: mỗi lần verify là một lần bump `last_verified` → doc nóng (được dùng nhiều) gần như luôn VERIFIED; chỉ doc lạnh quay lại sau thời gian dài mới trả phí verify — đúng lúc đáng trả nhất.

---

## Nhịp — sự kiện trước, lịch sau / Event-first cadence

| Trigger | Cơ chế | Việc |
|---|---|---|
| **Mỗi commit** (sự kiện) | hook | Cổng ghi: covers-sync, migration↔doc, token budget, contract version, encoding guard |
| **Mỗi lần dùng doc** (sự kiện) | router + main agent | Cổng đọc: SUSPECT → verify trước khi tin → bump last_verified |
| **Mỗi PR / tuần** | report `--ci` | Doc-lag (xem Đo lường), escaped-drift, broken ref, `_generated` stale, regenerate `doc-status.md` |
| **Tháng** (lịch — việc không có sự kiện trigger) | AI session, người đọc 5' | Promote buffer 20-recent → file riêng; root diet nếu ≥ 80% budget; consolidate memory |
| **Quý** (lịch) | `/audit` | CHỈ còn 3 việc lịch thật sự cần: trend report, verify doc KHÔNG có covers (vision/decision), fire-drill runbook. Mọi verify doc-có-covers đã chạy theo sự kiện |

---

## Đo lường — thay proxy bằng số đo thật / Metrics v2

- **Doc-lag** (chính): số doc SUSPECT + tuổi lệch (ngày từ khi code đổi mà doc chưa re-verify). Mục tiêu: median 0, max < 7 ngày. Thay hẳn "drift % = % commit sửa code có kèm docs" của v1 — proxy đó đo *hoạt động* chứ không đo *độ đúng*, và rule "drift thấp → siết hook" của v1 là lệnh tự tối ưu proxy (Goodhart) — **đã xóa**.
- **Escaped-drift**: lỗi doc bị cổng đọc/audit phát hiện mà lẽ ra cổng ghi phải chặn → mỗi case là 1 pattern mới cho hook (phiên bản hợp lệ của "siết hook").
- **Hotspot = tần suất được route (từ `docs/.fl-routing-log`) × tần suất code trong covers đổi**: xếp độ sâu verify và thứ tự backlog. Doc nóng code động → verify kỹ nhất; doc lạnh code tĩnh → chỉ TTL.
- **Trigger tức thời**: agent làm theo doc X mà hành động fail → verify X ngay, không đợi gì cả.

---

## Bảng tín hiệu → hành động (v2)

| Tín hiệu (máy đo) | Hành động | Loại |
|---|---|---|
| Doc SUSPECT được route tới | Verify claims vs code trước khi dùng → bump last_verified | VERIFY (cổng đọc) |
| Commit đổi code trong covers | Sửa doc hoặc bump last_verified cùng commit — hook chặn | UPDATE (cổng ghi) |
| Drift cơ học: rename/move path, đổi signature, schema regenerate | Máy/agent tự vá phần tham chiếu, không cần quyết định ngữ nghĩa | **AUTO-SYNC** |
| Escaped-drift case mới | Thêm pattern vào hook | UPDATE hook |
| Root CLAUDE.md ≥ 80% budget | Root diet (01 §diet) | UPDATE |
| App-map file > 1500 dòng HOẶC router thường trả về file mà agent chỉ cần 1 section | Tách theo đơn vị retrieval (cái agent cần đọc trọn), không chỉ theo số dòng | REFACTOR |
| App-map > 20 file phẳng | Domain hóa 2 tầng (02 §scaling) | REFACTOR |
| Semantic verify: doc sai căn bản | Viết lại từ code thật, không vá (STALE/CUPMem: hòa giải lúc GHI thắng vá lúc đọc) | REBUILD |
| ORPHANED: path trong covers không còn tồn tại | DEPRECATED + ngày, giữ 1 tháng, xóa. Chỉ khai tử khi chủ thể đã chết | RETIRE |
| Doc lạnh (vắng routing-log 90 ngày) nhưng covers còn sống | KHÔNG xóa: check keyword map router (lạnh thường là lỗi router) + ưu tiên verify kỳ tới | UPDATE router / verify |
| Sự cố cùng loại lần 2 | Mục "lỗi thường gặp" trong runbook (11 §4) | UPDATE runbook |
| User trả lời cùng câu hỏi lần 2 | Fast-path vòng B: learning event `explicit-instruction` → PROJECT RULE (mức 2) ngay, ghi memory theo format NT07 | LEARN (vòng B) |
| User chỉnh sửa bản AI làm rồi chấp nhận bản cuối | Learning event vòng B (evidence chain SHA) | LEARN (vòng B) |

**Update vs Refactor vs Rebuild vs Retire**: đúng nền lệch chi tiết → UPDATE (kèm bump verify); đúng nội dung sai cỡ/granularity → REFACTOR (stub `MOVED →`); sai căn bản hoặc máy sinh được → REBUILD từ source of truth; chủ thể đã xóa khỏi code → RETIRE. Tuyệt đối không retire vì lượt đọc thấp — doc sống theo code.

→ Cross-ref nguyên tắc 02 §Lifecycle: doc bị **thay thế bởi doc kế nhiệm** thì giữ file + stub `DEPRECATED — replaced by NN-x.md` (link không gãy); doc **mồ côi** (không có kế nhiệm, chủ thể biến mất) mới đi flow RETIRE xóa sau 1 tháng.

---

## Tự chấm điểm — judge phải neo vào số đo / De-noised audit

Quý 1 lần, `/audit` (slash command, read-only trừ `docs/audit-history.md`):
1. Điểm mỗi nguyên tắc phải **neo vào sub-metric deterministic có sẵn lệnh đo** (doc-lag, escaped-drift, budget, hook self-test, covers coverage %...) — LLM chỉ diễn giải và bắt vùng xám, không chấm cảm tính
2. **"Hệ đang mục" chỉ được tuyên bố khi metric deterministic cũng xấu đi** — điểm judge LLM dao động giữa các lần chạy; 2 mẫu của máy đo nhiễu không phải trend
3. Semantic verify sâu: 3 doc hotspot cao nhất (theo công thức hotspot) — claim-by-claim vs code
4. Output: backlog xếp hạng theo hotspot, mỗi mục có loại hành động + effort + deadline; append 1 dòng vào `docs/audit-history.md`

---

# VÒNG B — Interaction learning (v3): học từ diff được chấp nhận

> **STATUS từng bước**: capture qua `/learn` cuối phiên = **[ACTIVE]** (template `learn.command.md.template` — `ai-simple init` cài thành `.claude/commands/learn.md`); scripts decision-extract/compile/telemetry tự động = **[CONTRACT — Phase 4]**. Audit chấm phần CONTRACT là DEFERRED, không chấm vòng lặp không tồn tại.

## Evidence chain — SHA là bằng chứng, không phải cảm giác

```text
base_sha (mốc bắt đầu) → initial_sha (bản AI làm đầu) → revision requests (câu chữ user)
→ accepted_sha (bản cuối được chấp nhận)
```

Learning event (JSON, per-session; **[ACTIVE]** = ghi tay qua `/learn`, **[CONTRACT]** = script extract):

```json
{
  "run": "hp-rewards", "lot": "shop",
  "base_sha": "abc123", "initial_sha": "def456", "accepted_sha": "fed987",
  "user_revisions": ["make cards more compact", "remove decorative shadow"],
  "changed_paths": ["src/features/rewards/shop/RewardCard.tsx"],
  "inferred_decisions": [
    { "decision": "Rewards admin screens use compact density",
      "scope": "project:rewards-admin",
      "evidence": "strong-accepted" }
  ]
}
```

**KHÔNG có trường confidence thập phân** (0.81 = false precision không calibrated, không audit được). Trường `evidence` là enum thứ bậc gắn với LOẠI bằng chứng — audit đối chiếu được với transcript:

| `evidence` | Nghĩa | Đủ cho |
|---|---|---|
| `explicit-instruction` | User nói thẳng rule / lặp ≥ 2 lần (fast-path NT07) | Nhảy thẳng PROJECT RULE (mức 2) |
| `strong-accepted` | User "chốt/đúng rồi", yêu cầu commit/merge, áp pattern cho màn khác | 1 case đếm vào ngưỡng mức 2 (chưa là rule) |
| `medium-accepted` | Im lặng + merge, hoặc xây tiếp lên trên output | OBSERVED ở scope nhỏ nhất |
| `weak-inferred` | AI tự suy từ diff, không tín hiệu user | Chỉ ghi nhận, không promote |

**Acceptance có tầng — im lặng không chết vòng B, survival mới là vé promote:**
- Im lặng + merge = medium — đủ ghi OBSERVED ở scope component, KHÔNG đủ promote lên domain/project.
- **Survival là acceptance mạnh nhất không cần lời nói**: code từ accepted_sha sống qua N session mà user không sửa lại vùng đó — git đo được, mạnh hơn câu "ổn" (câu "ổn" có thể vì mệt; code sống 3 tuần thì không).
- AI tự cho là xong / session kết thúc = KHÔNG phải bằng chứng.

## Filter TRƯỚC khi sinh event — chống học sai từ gốc [ACTIVE]

1. **Defect ≠ preference**: revision trace được về vi phạm ba-spec/design-spec/AC → đó là SỬA LỖI, không sinh learning event (oracle đã có sẵn trong pipeline BA→design→triage).
2. **Độc lập giữa case**: 3 accepted diff cùng buổi, cùng mạch task = 1 case, không phải 3. Đếm case theo session khác nhau + cách nhau thời gian.
3. **Ràng buộc ngoài đội lốt preference**: quyết định do khách hàng/brand của project ép → scope tối đa là `project:`, cấm generalize lên `user:`.
4. Câu chữ user quote nguyên văn vào event — nhưng decision suy ra phải viết được thành **assertion kiểm chứng được** ("admin screens dùng density compact"), không phải cảm nhận ("làm đẹp hơn").

## Scope ladder + destination — lưu ở scope NHỎ NHẤT phù hợp [ACTIVE]

```text
component → domain/screen → project → user → domain skill → AI Simple core
```

| Loại quyết định | Nơi cập nhật |
|---|---|
| Component-specific | Code/component spec |
| Domain rule | App-map domain doc (vòng A bảo vệ tiếp) |
| Project convention | Design system / CLAUDE.md project |
| User preference | Memory (format + lifecycle NT07) |
| UI/domain pattern | Skill chuyên môn (ui-design-logic…) |
| Workflow xuyên domain | AI Simple (vòng C) |
| Deterministic operation | Script |

**Hợp nhất NT07**: NT07 không còn là pipeline riêng — nó là **fast-path `explicit-instruction`** của vòng B (một ladder, một destination, một nơi ghi). NT07 giữ: format entry, index MEMORY.md, lifecycle (update/merge/sunset). Khi bản ghi NT07-explicit và learned-rule-inferred cùng scope mâu thuẫn → **explicit thắng**.

## Promotion — 3 mức vận hành (8 tên trạng thái chỉ là nhãn) 

```text
Mức 1 OBSERVED    (1 case, hoặc medium)      → ghi event, chưa là rule
Mức 2 PROJECT RULE (2–3 case ĐỘC LẬP cùng project, hoặc explicit-instruction,
                    hoặc survival N session)  → active rule ở scope đúng [ACTIVE]
Mức 3 SKILL CANDIDATE (lặp ≥ 3 project KHÁC DOMAIN cùng user, cách nhau thời gian,
                    HOẶC quyết định thủ công của owner — evidence là hồ sơ đề xuất)
                                              → vào vòng C [CONTRACT trừ quyết định tay]
```

- Security/data-loss: được đặc cách lên mức 2 từ 1 case — NHƯNG assertion phải nêu RỦI RO CỤ THỂ (lộ data gì, mất gì) và evidence tối thiểu `strong-accepted`; `weak-inferred` tự dán nhãn "security" không được đặc cách (chống lách ngưỡng).
- **Bộ nhớ theo vai [ACTIVE]** (ADR 004): PROJECT RULE chỉ một vai chuyên gia cần (BA / UI / security / verifier) ghi vào `docs/agent-memory/<vai>.md` — một dòng một mục, bắt buộc mã + `evidence` + `last_verified` + `bỏ khi`, trần 40 mục. Mục ở đây chịu đúng cơ chế vòng A: quá hạn hoặc code liên quan đổi → SUSPECT, đối chiếu rồi mới tin. Chạm trần → đẩy lên spec/app-map, hoặc thành SKILL CANDIDATE (mức 3) *(ép bởi `agent-memory-verify.sh` — chạy trong `doctor` và `npm test`; chưa nối pre-commit)*.
- KHÔNG có đường "nhiều user độc lập" tự động — repo 1 owner thì đường đó là spec chết; promote lên core luôn qua tay owner.

## Thứ tự ưu tiên khi mâu thuẫn [ACTIVE]

```text
Yêu cầu hiện tại > canonical project spec > domain rule > user preference
> inferred pattern > skill default
```
+ Rule hẹp thắng rule rộng; explicit thắng inference; decision mới được chấp nhận thắng inference cũ cùng scope.
+ Hòa giải khi 2 trục cọ nhau (scope vs evidence): rule scope hẹp áp TRONG scope của nó bất kể evidence; chỉ khi hai rule cùng phạm vi áp dụng mới xét evidence — explicit thắng inferred.

## Learned rule cũng là doc — vòng A áp lên chính nó [ACTIVE]

Mỗi active learned rule BẮT BUỘC có: evidence links (SHA/event), `last_verified`, rollback condition; và chuyển **SUSPECT khi spec/code nền đổi** — tái dùng nguyên máy móc coupling map. Rule "admin dùng compact density" không được sống mãi sau khi design system đổi.

**Chống echo-chamber (lỗ nghiêm trọng nhất)**: rule được compile vào context → AI tự áp → user im lặng → KHÔNG được tính là bằng chứng củng cố. Trạng thái MONITORED chỉ đếm bằng chứng NGOÀI vòng: user chủ động tái khẳng định, hoặc **correction** (user sửa ngược rule đang active — tín hiệu rollback).

## Metric vòng B — chỉ số đo được từ git [số nào không có lệnh đo thì không tồn tại]

**N mặc định = 5 session HOẶC 14 ngày (mốc nào tới trước) VÀ có ≥ 2 session hoạt động trong khoảng đó** — repo không hoạt động thì survival KHÔNG đủ làm vé promote: không có cơ hội bị correction thì "sống sót" rỗng không phải bằng chứng. Nguồn đếm session: timestamp trong `docs/.fl-routing-log` hoặc `docs/learning/events.jsonl` (mỗi ngày có entry = 1 session). (Chỉnh trong CLAUDE.md project nếu nhịp khác.) Nguồn dữ liệu event: `docs/learning/events.jsonl`.

- **Survival** (per event): `git log --oneline <accepted_sha>.. -- <changed_paths>` — RỖNG sau N = diff sống sót (bằng chứng promote); CÓ commit người sửa lại vùng đó = correction candidate (đọc commit xem sửa gì).
- **Survival rate**: % event sống sót / tổng event đủ N tuổi.
- **Correction rate**: số lần user sửa NGƯỢC một rule đang active (mỗi case → xem lại rule; ≥ 2 case độc lập → rollback theo điều kiện đã khai).
- **Survival sau release (vòng C) chỉ dùng để GIỮ hoặc ROLLBACK rule — không bao giờ dùng để nâng scope/status** (nâng cần bằng chứng ngoài vòng — chống echo-chamber).
- KHÔNG dùng "classification precision ≥ X%" (không có ground truth, không có lệnh đo) — nếu Phase 4 xây được eval set thì mới có metric đó, tới lúc đó nó là CONTRACT.

## Active rules compile vào context — gọn, không nạp raw evidence

```markdown
- Admin screens use compact density.        [proj:rewards | last_verified 2026-07-28]
- Avoid decorative shadow.                  [proj:rewards | last_verified 2026-07-28]
```
Raw evidence (diff, before/after) nằm archive — không auto-load (state taxonomy dưới).

---

# VÒNG C — Skill evolution (v3): nâng cấp skill qua Git [phần lớn ACTIVE — chính là PR workflow]

```text
Candidate (mức 3) → xác định owner logic (skill nào/NT nào sở hữu)
→ viết thành assertion kiểm chứng được + regression test (case cũ không vỡ)
→ proposal trên Git BRANCH (không sửa thẳng main của skill)
→ user/owner review → release (version trong CHANGELOG) → monitor → retain hoặc rollback
```

- **[ACTIVE]** ngay: candidate → branch → review → release → rollback là PR workflow làm tay được, tần suất thấp.
- **[CONTRACT — Phase 5]**: forward-test bằng context sạch (spawn session mới với fixture "rule NÊN fire" + fixture "rule KHÔNG ĐƯỢC fire" — test misfire quan trọng hơn test fire), benchmark token/runtime. Gate thay thế khi chưa có: assertion kiểm chứng được + user duyệt trực tiếp trước khi release.
- Monitor = survival/correction rate của rule sau release; correction vượt ngưỡng → rollback (điều kiện rollback viết sẵn trong proposal).
- Core skill KHÔNG BAO GIỜ tự merge từ 1 case, bất kể bằng chứng mạnh cỡ nào.

---

## Phối hợp NT12 ↔ NT13 (parallel mode)

Worker KHÔNG cùng commit các file global — đụng nhau chính là loại conflict NT13 sinh ra để tránh:

| Dữ liệu | Worker | Integrator |
|---|---|---|
| Entity code/doc/test | Commit trong lot | Review |
| `_generated/doc-status.md` | Tính on-demand, không commit | Regenerate canonical sau merge |
| `docs/.fl-routing-log` | Per-session buffer | Aggregate |
| Learning events (vòng B) | Per-session/lot (`docs/learning/events/<run>-<lot>.jsonl`) | **[ACTIVE — thủ công]**: integrator gom vào `docs/learning/events.jsonl` khi chạy `/learn` cấp run, SAU accepted integration SHA (bước có trong end-of-run checklist doc 13) |
| `docs/.escaped-drift.log` | Per-session | Aggregate |
| `docs/audit-history.md` | Không sửa | Single writer |

Accepted integration SHA của run là mốc tổng hợp learning events toàn run — diff được merge mới là diff "được chấp nhận". **REMAP SHA khi gom (bắt buộc)**: merge queue REBASE lot branch → `accepted_sha` per-lot thành orphan (sau `git gc` là SHA ma). Khi integrator gom event vào `events.jsonl`: ghi `accepted_sha` = **integration SHA sau merge của lot đó** (giữ SHA cũ vào trường `lot_sha_pre_rebase` làm archive). Đây chính là bài "so SHA sau rebase" của NT13 áp vào learning — không remap thì survival đo sai và audit spot-check false-positive trên event hợp lệ.

## State taxonomy — cái gì sống ở đâu

| Loại state | Ví dụ | Nơi lưu |
|---|---|---|
| Canonical authored | CLAUDE.md, app-map, ADR, contract | Git |
| Generated cache | `_generated/` schema, routes, doc-status | Integrator/CI regenerate |
| Telemetry | routing-log, drift-log, learning events | Per-session → aggregate |
| Ephemeral coordination | claims, lease, lock (NT13) | `GIT_COMMON_DIR` — KHÔNG commit |
| Active learned rules | project/user/domain rule files | Canonical scoped file (Git, có last_verified) |
| Raw evidence | before/after, diffs | Archive — không auto-load vào context |

---

## Anti-patterns

| Anti-pattern | Hậu quả |
|---|---|
| Verify theo lịch thay vì theo sự kiện đổi code | Doc sai nằm chờ tới 90 ngày — với AI agent là đầu độc ngữ cảnh, không phải "tham khảo kém" (STALE: agent tin tiền đề cũ ~70% nếu không đánh dấu) |
| Doc không khai `covers` (trừ doc thuần quyết định) | Nằm ngoài mọi cổng bảo vệ — staleness quay về đoán mò |
| Bump `last_verified` mà không thật sự đối chiếu | Đầu độc chính cơ chế — tệ hơn không bump; bump = lời cam kết "tôi đã check" |
| Dùng tuổi doc làm thước mục (stale 30d đồng loạt) | Tuổi không phải mục: doc già trên code tĩnh vẫn đúng; doc mới trên code vừa viết lại là khẩn cấp. Đo doc-LAG, không đo doc-AGE |
| Đo drift bằng % commit có kèm doc | Proxy gameable — đo hoạt động không đo độ đúng (Goodhart) |
| Tin trend từ 2 lần chấm LLM | Judge nhiễu; trend phải có metric deterministic đi kèm |
| Vá doc sai nền tảng thay vì rebuild | Chăn vá — AI đọc tin nhầm phần cũ |
| Xóa doc chỉ vì lâu không ai đọc | Đốt trí nhớ module còn sống — lúc code đụng lại mất sạch ngữ cảnh |
| Giữ doc MỒ CÔI "biết đâu cần" | AI đọc tin vào feature không còn tồn tại |
| Confidence thập phân tự chấm (0.81) trong learning event | False precision không calibrated — downstream dùng như xác suất thật |
| Đếm im lặng của user là bằng chứng củng cố rule đang active | Echo chamber — rule tự sản xuất bằng chứng cho chính nó |
| Học preference từ revision sửa bug (vi phạm spec) | Rule sinh từ nhiễu — defect phải về triage, không về memory |
| Promote rule mà không có regression test + rollback condition | Skill drift không đường lui |
| Learned rule không có last_verified/SUSPECT | Rule mục sống mãi sau khi design system/spec nền đổi |

---

## Checklist áp dụng / Adoption checklist

- [ ] Mọi app-map doc gắn code có `covers:` + `last_verified:` + `ttl_days:` (audit đo % coverage)
- [ ] Hook có check covers-sync (cổng ghi) — `--self-test` pass
- [ ] `_generated/doc-status.md` được regenerate (report `--status`) và router đọc nó (cổng đọc)
- [ ] `docs/.fl-routing-log` + `docs/audit-history.md` được commit (append-only)
- [ ] `/audit` kỳ đầu đã chạy: điểm neo metric, backlog có owner + deadline
- [ ] Đã xóa mọi rule "drift % thấp → siết hook" nếu retrofit từ v1
- [ ] (v3) Cuối phiên có revision đáng nhớ → `/learn` ghi learning event (evidence enum, không confidence số)
- [ ] (v3) Active learned rules có evidence links + `last_verified` + rollback condition
- [ ] (v3) Audit chấm vòng B/C bằng survival/correction rate khi có dữ liệu — chưa có → DEFERRED
