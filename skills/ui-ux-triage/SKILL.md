---
name: ui-ux-triage
description: Team-agent triage + fix loop cho app ĐANG CHẠY: đọc ba-spec + design-spec làm oracle để phân loại defect rồi sửa qua cổng ai-simple; repo-agnostic. Kích hoạt: màn này sai/lệch, screenshot kèm câu than ngắn, nút bấm không ăn, test + fix flow, reproduce lỗi hiển thị. KHÔNG: nhu cầu/tính năng mới (→ba-flow-logic), thiết kế mới hoặc redesign (→ui-design-logic). Không đụng DB production, không auto-commit.
---

# UI/UX Triage — Team Agent (composable, repo-agnostic)

Triage UI/UX chạy qua **team agent** (không phải 1 agent đơn): test từng bước → quan sát → phân loại → fix → test lại. Không chắc → hỏi user: telegram kèm ảnh khi consent NOTIFY hội đủ [NOTIFY-gated], ngược lại ghi PENDING-ASK vào report local (§8). Skill này **repo-agnostic** (chạy mọi repo) và là **một mắt trong hệ 5-skill** — nó không tự quyết cái thuộc skill khác.

---

## 0. Vị trí trong hệ 5-skill (ĐỌC TRƯỚC)

```
BA (nhu cầu→ba-spec) → ui-design-logic (→design-spec) → build → [ui-ux-triage] (VẬN HÀNH/sửa)
        │←──────────── security-logic rà soát CẮT NGANG mọi pha (code/doc/dep — NT14) ────────────→│
        └──────────────── tất cả trên nền ai-simple (rail + truth + tier + memory + verify) ────────────┘
```

- **Skill này = pha VẬN HÀNH.** Code đã có, đang chạy → nó test, bắt drift, sửa.
- **Oracle của nó đến từ pha trên** (xem §3): `ba-spec` = "đúng hành vi chưa", `design-spec` = "đúng giao diện chưa".
- **Handoff sang security-logic**: defect có mùi AN TOÀN (lộ data, bypass quyền, injection nghi ngờ) → không tự vá kiểu triage; chuyển `security-logic` review (NT14) rồi fix qua tier.
- **Defer sang ai-simple** (§7): risk-tier 06, memory 07, verify 12, gate 08 — KHÔNG tự chế lại.
- **Handoff NGƯỢC về BA** (§5 bước 4c): nếu defect hóa ra là *nhu cầu thiếu/sai* (code khớp spec, nhưng spec sai) → đó là việc BA, không phải fix triage.

---

## 1. Trigger / non-trigger / tie-breaker

Kích hoạt khi user:
- Gửi screenshot UI + câu ngắn ("cái này sai", "ko đồng bộ", "ko đẹp", "tại sao…")
- "rà soát", "triage", "test + fix", "chạy flow"
- Flag inconsistency giữa 2 màn / flow / account state

KHÔNG kích hoạt (→ skill khác):
- Nhu cầu/tính năng mới, "tại sao user cần…" → **BA**
- Thiết kế màn mới, "build trang", "làm đẹp từ đầu" → **ui-design-logic**
- Review tĩnh 1 màn không cần flow+fix loop → **ui-design-logic 06 §3** (diagnose 4-case, read-only)
- DB migration / schema → ASK + gate (ai-simple #06 RED + memory db-safety)

Tie-breaker đầy đủ: §11.

---

## 2. Repo-agnostic setup — KHÔNG hardcode (chạy mọi repo)

Trước khi spawn team, Lead chạy **gate THẬT**:
```
bash <skill-dir>/triage-verify.sh        # exit 0 mới spawn
```
Gate đọc `./.claude/triage.config` nếu có; KHÔNG có → **auto-discover** mặc định:
- App-map: `docs/app-map/` (mọi `*.md` = read-ref cần resolve)
- Memory: thư mục memory của Claude Code (harness)
- ba-spec / design-spec: glob trong app-map (xem §3); thiếu → degrade
- Test cmd: từ `package.json` scripts (typecheck/test/e2e) nếu có
- **E2E harness** (nếu repo có `tests/e2e/` + helpers): account-matrix theo VAI TRÒ, helper auth/create-family/add-member/join/approve/link, dual-context multi-user, **test-data tracker** (log entity tạo ra, vd JSONL) + **cleanup cmd** (vd `test:e2e:cleanup`). → Flow-tester TÁI DÙNG (§4.2), KHÔNG tự clicking ad-hoc. Thiếu → degrade flow thủ công.
- Telegram: script tầng user `~/.ai-simple/notify-telegram.sh` (token qua env user) [telegram-ref]; thiếu script HOẶC consent chưa hội đủ → degrade ghi file (§8)

→ Cùng một skill global chạy đúng ở *từng* repo vì ref được **khám phá**, không **đóng cứng**. (Bài học ai-simple #08 CONFIG-per-repo, #09 generic-vs-project.)

Copy `triage.config.template` → `.claude/triage.config` ở repo nào cần chỉ định rõ (vd test cmd khác chuẩn, spec ở chỗ lạ).

---

## 3. ORACLE — trái tim của composition

Observer phân loại defect bằng cách **đối chiếu với oracle**, KHÔNG phán "xấu/đẹp" cảm tính. Thứ tự ưu tiên oracle:

| Bucket | Oracle (cao→thấp) | "Defect" = |
|---|---|---|
| **LOGIC** / **FLOW** | `ba-spec` (acceptance criteria, JTBD) → app-map flows | lệch AC / vi phạm invariant / journey đứt |
| **DESIGN** | `design-spec` (ui-design-logic) → design-system doc | lệch screen map / state matrix / token |
| **TEXT** | `design-spec` (copy/wording UI) + ba-spec (THUẬT NGỮ nghiệp vụ: tên đối tượng/trạng thái) + i18n contract | sai/ lẫn ngôn ngữ, copy không khớp intent, thuật ngữ lệch ba-spec |

- **Có ba-spec/design-spec** → diff thực-tế-vs-spec. Đây là chế độ mạnh nhất (composition đủ).
- **Thiếu spec** (repo chưa chạy BA/design) → fallback design-system + heuristics, NHƯNG gắn cờ `[no-oracle, confidence thấp]` trong mọi finding để Lead biết đang đoán.
- **Defect mà code KHỚP spec** → không phải bug triage. Code đúng spec mà vẫn sai = **spec sai** →
  §5 bước 4c: sai HÀNH VI (AC/flow/nghiệp vụ) → handoff **BA**; sai GIAO DIỆN tại design-spec
  (screen map/state/token chính nó sai) → handoff **ui-design-logic** — BA bị cấm đụng UI.

### 3b. Sổ đã chốt — chống sửa xong lại hỏng (v1.26.0, ADR 003 G9)

**Trước khi fix:**
- Đọc `## Sổ đã chốt` của ba-spec và design-spec vùng đó.
- Đọc thêm thân commit gần nhất của vùng (`git log -5 --format=%B -- <path>`).
- Bản fix đi ngược một dòng trong sổ thì DỪNG: đó là RED (đảo quyết định của chủ dự án), không phải bug.

**Sau khi fix theo lời chủ dự án** ("bỏ X", "đừng Y", ảnh chụp kèm câu than):
- Ghi 1 dòng vào Sổ đã chốt: ngày, lời nguyên văn ngắn, luật, thứ canh.
- Thứ canh là test hoặc grep, để lần sau agent khác không thêm lại. Án lệ: mkn-3 ẩn BORDER_NEAR → mở lại → ẩn lại.
- KHÔNG viết comment `re-verified` dài vào spec. Lịch sử đã nằm trong commit.

**Phân loại theo 8 lỗi gốc** (ui-design-logic §0b):
- Bảng tra:
  - "bỏ đi / rối / không cần" → G3
  - "tự làm đi / đừng hỏi" → G4
  - "chưa giống fb / gg map" → G5
  - "chỉ muốn đổi X" → G10
  - lộ mã / id / `[object Object]` → G11
  - "số này gây hiểu lầm" → G12
  - "làm sao quay về" → G13
- Lỗi G11 sửa ở **hàm dùng chung** (bảng nhãn enum, hàm thông báo lỗi), không vá từng màn.
- Lỗi thuộc G1–G7 phía BA (vai, đại lượng, luật chặn) → handoff BA.

---

## 4. Team structure

```
TeamCreate team_name=ui-triage-<n>      (tên BẮT BUỘC prefix "ui-triage" — hook/gate nhận diện)
  team-lead → flow-tester / observer / fixer / advisor
```

### 4.1 team-lead (general-purpose)
Parse feedback → test plan; giao Tester; nhận Observer → giao Fixer; không chắc → Advisor → vẫn không chắc → telegram khi consent hội đủ [NOTIFY-gated], off → PENDING-ASK trong report (§8). Không tự code.

### 4.2 flow-tester — test NHƯ USER THẬT, tái dùng harness repo (KHÔNG clicking ad-hoc)
**Bước 0 — tái dùng harness**: repo có E2E harness (§2) → DÙNG LẠI helper sẵn (login, account-matrix theo vai, create-family/add-member/join/approve/link, dual-context) để dựng user + chạy hành trình; KHÔNG tự viết selector rời. Đây là cách đi đúng "đường người dùng thật" mà E2E chính thức đã đi → bắt được lỗi mà 1-session-1-user bỏ sót.

**Luật nền (BẤT BIẾN — vi phạm = test vô nghĩa):**
1. **UI-driven thật, CẤM seed DB tắt.** Toàn hành trình từ ĐĂNG KÝ → thao tác phải bấm qua UI thật như user (Playwright/preview). KHÔNG insert thẳng DB / gọi API tắt để "có sẵn user/data" — seed DB thì KHÔNG biết button có tác dụng không, flow/UI có chạy không (đó mới là thứ cần kiểm). Seed CHỈ được phép khi cả 2: (a) tiền-điều-kiện đó **KHÔNG có helper UI** trong harness, VÀ (b) **không phải** thứ feedback đang nhắm. Có helper UI cho việc đó → BẮT BUỘC đi UI, CẤM seed (ranh giới là "có helper hay không" — kiểm được, không để agent tự phán "trong/ngoài phạm vi").
2. **Sát thiết bị user.** Dùng viewport/profile đúng thiết bị thật: app mobile → mobile-first (profile iOS/Android), app web → desktop+responsive. Không chỉ 1 viewport desktop.
3. **Test-data CÓ SỔ + clear được, và dữ liệu thật là AUTHORITY L2.** MỌI user/family/record tạo ra trong test → ghi vào test-data tracker của repo (§2) để **clear sạch trước khi lên production**. Không tạo data mồ côi. **Mặc định BẮT BUỘC: env/DB test cô lập + synthetic identity.** Chạm dữ liệu thật đang phục vụ người dùng là L2 (foundation §Authority contract): **mặc định CẤM**, chỉ làm khi user nêu đúng target và cấp quyền cho lần đó — "có đường cleanup đã verify" là điều kiện CẦN, KHÔNG phải quyền. (KHÔNG skip tracking để "chạy nhanh".)

**Test plan PHẢI phủ (theo phạm vi feedback):**
- **Theo VAI TRÒ**: chạy lại flow trên từng role của account-matrix (owner/admin/member/guest/banned…) — defect hay chỉ hiện ở 1 role.
- **Hành trình đầy đủ**: entry → mục tiêu user → bước kế; KHÔNG test 1 màn cô lập nếu lỗi nằm trong flow.
- **Cross-user / multi-context**: flow cần ≥2 user (join family, link/duyệt member, chat/call) → **dual-context** (2 browser context đồng thời), KHÔNG giả lập 1 user.
- **Đổi vai giữa chừng**: hành trình đổi quyền (member→admin, transfer owner) → test cả TRƯỚC và SAU khi đổi.

Chụp **MỌI bước** vào `test-reports/triage/<iter>/`. **Allowlist** reversible (navigate, mở/đóng modal, toggle, nhập-không-submit); irreversible (submit xoá/gửi/thanh toán/destructive) → STOP chờ Lead. (Denylist chuỗi cố định bỏ sót action không khớp tên.)

**Repo KHÔNG có harness** → degrade: flow thủ công + flag `[no-harness]`; đề xuất tạo helper tối thiểu theo pattern E2E của repo (đừng bịa đường đi user).

### 4.3 observer (read-only)
Pre-load `triage-log` nếu có (skip nếu run đầu) → ưu tiên bucket hay tái diễn. Đối chiếu oracle (§3). Output mỗi defect: `[bucket] mô tả | screenshot | suspected file:line | severity P0/P1/P2 | oracle vi phạm (spec:dòng) | suggested fix`.

### 4.4 fixer
ĐỌC file trước khi sửa. Minimal diff. Preserve i18n keys / data-testid / data-hint-key. Verify sau fix (test cmd từ §2). **Revert = qua patch-file của CHÍNH MÌNH** [ADVISORY]: trước khi apply, loop BẮT BUỘC lưu patch (`git diff > <patch-của-loop>`); verify fail → `git apply -R <patch-của-loop>` + báo Lead. **CẤM `git reset` / `git checkout --` / `git stash` / `git restore`** trên working tree — chỉ được reverse đúng patch/hunk do chính mình tạo, không phục hồi toàn file đè dirty sẵn có của user (NT13/ADR-001). **KHÔNG git commit** (ai-simple #08).

### 4.5 advisor (read-only)
Tư vấn khi nhiều option/risk. Dựa decision-pattern §6 (đọc bản mới nhất). Format: Options A/B + risk + recommend + red flags. Không tự apply.

---

## 5. Loop iteration (max 3 tự động)

```
iter N:
 1. LEAD parse feedback → test plan: liệt kê user-journey × VAI TRÒ × cross-user cần phủ (§4.2), không chỉ vài click rời
 2. TESTER chạy + chụp mọi step.
      → 1 BƯỚC HÀNH TRÌNH HỎNG (nút không tác dụng, đăng ký không xong, flow đứt) = defect → Fixer sửa → Tester **làm lại TỪ bước đó** tới khi qua (không bỏ qua bước, không giả lập đường vòng). User sinh ra qua mỗi lần retry đều ghi sổ test-data (§4.2 luật 3).
 3. OBSERVER classify theo oracle (§3)
 4. LEAD review:
      - clear → 5
      - ambiguous → ADVISOR → vẫn ambiguous → gộp 1 TELEGRAM ASK khi consent hội đủ [NOTIFY-gated], off → PENDING-ASK trong report (§8) + pause
      - stale-pause >24h không hồi → nhắc 1 lần → TeamDelete (không giữ team zombie)
 4b. CAPTURE (đóng vòng học): user trả lời ASK → ghi [date] tình-huống→quyết-định→heuristic vào §6 +
      memory feedback_triage_decisions.md; mâu thuẫn heuristic cũ → [stale]; ≥2x → promote rule (ai-simple #07)
 4c. HANDOFF khi code KHỚP spec mà vẫn sai → KHÔNG fix, ghi 1 dòng HANDOFF vào triage-log rồi exit:
      `HANDOFF | to=<BA|design> | spec=<file + AC/mục bị nghi> | ca=<spec-sai|nhu-cầu-thiếu|nhu-cầu-mới> | bằng-chứng=<screenshot/log> | đề-xuất=<1 câu>`
      — sai HÀNH VI → to=BA (ba-flow-logic ref 04 nhận đúng format này); sai GIAO DIỆN tại design-spec → to=design (ui-design-logic đọc spec + sửa theo pipeline nó)
 5. LEAD brief FIXER (request cụ thể)
 6. FIXER apply + verify; không rõ → hỏi Lead; verify fail → revert qua patch-file của chính mình (§4.4, CẤM reset/checkout/stash/restore) + escalate
 7. TESTER rerun từ step 1 (regression) — tái dùng pattern bug-fix-verify spec của repo nếu có
 8. hết defect:
      - tóm tắt + TELEGRAM done khi consent hội đủ [NOTIFY-gated], off → report local (§8)
      - update doc/memory nếu có LOGIC mới
      - append 1 dòng STRUCTURED vào triage-log:
        `<ISO> | <repo> | iter=N | buckets=LOGIC:a,TEXT:b,DESIGN:c,FLOW:d | decided=<1 dòng> | verify=tsc:pass,... | telegram=ok|fail|degraded|off` [telegram-ref]
      - exit
 9. còn defect + iter<3 → về 1 (scope hẹp hơn)
10. iter≥3 → TELEGRAM xin hướng khi consent hội đủ [NOTIFY-gated], off → PENDING-ASK trong report + pause
```

---

## 6. Decision patterns học từ user (seed RỖNG mỗi repo, LIVE-UPDATED)

> Repo mới: bảng này bắt đầu **trống** — mỗi repo tự học pattern riêng qua §4b (KHÔNG bê pattern lunar sang repo khác).
> Cột **Tần suất** `(×N, last <date>)`: tăng N mỗi lần lặp. Heuristic bị user mâu thuẫn → `[stale]` (giữ history). Advisor đọc bản mới nhất.

| Tình huống | User's pattern | Heuristic | Tần suất |
|---|---|---|---|
| (trống — điền khi học) | | | |

---

## 7. Defer sang ai-simple (KHÔNG tự chế lại nếu skill đó có mặt)

| Việc | Chủ sở hữu | Triage làm gì |
|---|---|---|
| Escalation GREEN/YELLOW/RED | ai-simple #06 | Phân loại action theo tier; chỉ RED → 1 ASK gộp (no-petty-confirms) |
| no-DB / no-commit | ai-simple #08 + memory | Là GATE của nó, không tự định nghĩa |
| Memory format + luật ≥2x | ai-simple #07 | Ghi pattern theo format đó |
| Coupling/verify-on-use, /audit | ai-simple #12 | Gate §2 + triage-log để /audit verify |
| ba-spec (AC), design-spec | BA / ui-design-logic | Đọc làm ORACLE (§3), không tự định nghĩa "đúng là gì" |
| E2E harness (helper, account-matrix, dual-context) | repo's tests (ai-simple #04 doc+test-sync) | TÁI DÙNG để test như user thật (§4.2), KHÔNG dựng lại đường đi user |

ai-simple/BA/ui-design-logic **vắng** trong repo → degrade: tier áp cục bộ, oracle fallback design-system, vẫn chạy.

---

## 8. Consent NOTIFY + Telegram + degrade [telegram-ref]

**Degrade là HÀNH VI MẶC ĐỊNH** (v1.11.0): luôn tạo local report trước; chỉ gửi telegram khi consent NOTIFY hội đủ [NOTIFY-gated]. "Có script telegram" KHÔNG đồng nghĩa user đã consent; reversible KHÔNG đồng nghĩa authorized.

**Consent hội đủ** = phép hợp nhất tri-state {on, off, unset} của 3 nguồn (máy: `triage-verify.sh` hàm `consent_resolve`):
- Nguồn ngoài-repo: `~/.ai-simple/config` (NOTIFY=) hoặc env `AI_SIMPLE_NOTIFY` — do **user tự đặt**. Env là per-session; consent bền qua verify-time dùng `~/.ai-simple/config`.
- Nguồn repo `.claude/triage.config` chỉ được **thu hẹp**: `NOTIFY=off` trong repo phủ quyết mọi override.
- off tường minh ở BẤT KỲ nguồn nào → off; on đòi ≥1 nguồn ngoài-repo on VÀ không nguồn nào off.

**[ADVISORY — luật hành vi agent, cùng hạng luật cấm stash NT13]**: agent bị CẤM set env `AI_SIMPLE_NOTIFY`, CẤM ghi `~/.ai-simple/config`, CẤM tự thêm dòng token `# user-consent: notify-on` thay user. Máy không phân biệt được ai ghi — consent thật nằm ở hành vi user.

**Máy liên quan** [telegram-ref]: verifier degrade-theo-consent + hậu-kiểm log telegram=ok [ENFORCED hậu-kiểm]; hook pre-commit chặn commit gỡ `NOTIFY=off` thiếu token [ENFORCED phạm-vi-hẹp]; `--config-check` ghi dòng `consent |` vào triage-log [DETECTED].

3 template ASK/DONE/STUCK. ≤2 ảnh, text thuần. **Redaction trước --photo**: che SĐT/email/token/PII member khác. **DEGRADE** [telegram-ref]: consent chưa hội đủ HOẶC thiếu telegram script → ghi `test-reports/triage/report-<date>.txt` (câu hỏi đang chờ ghi mục **PENDING-ASK**), KHÔNG crash; log `telegram=off` khi consent off, `telegram=degraded` khi thiếu script (cấm ghi `ok` khi thật ra fail/degrade/off).

---

## 9. Exit gates (verify-on-use, có bằng chứng — tự tick khi CHẠY xong, không pre-tick)
- [ ] `triage-verify.sh` exit 0
- [ ] **session-audit đã chạy ĐỦ 2 PHA** — đầu phiên `--session-audit` (lấy `<id>`), cuối phiên `--session-audit --close <id>`; record chính thức `test-reports/triage/audit-<stamp>.txt` đính kèm. Tick mà không có record = vi phạm exit gate. [DETECTED — máy phát hiện sau sự việc; phần agent tự gọi giữa phiên là ADVISORY]
- [ ] Loop ≥1 iter end-to-end; mọi defect fix hoặc escalate
- [ ] Verify pass (capture exit code, không "chắc pass")
- [ ] Decision-pattern §6 updated nếu user dạy khác (§4b)
- [ ] triage-log dòng mới qua `triage-verify.sh --lint-log`
- [ ] Telegram: consent hội đủ + exit 0 [NOTIFY-gated] HOẶC degrade-ghi-file (off/degraded ghi đúng trạng thái)
- [ ] Test-data tạo ra đã ghi sổ tracker + biết đường clear trước production (§4.2 luật 3)
- [ ] TeamDelete sau khi user confirm done · KHÔNG auto-commit · KHÔNG đụng DB production

---

## 10. Anti-patterns
| Anti-pattern | Đúng |
|---|---|
| Lead tự code | Strict role separation |
| Tester skip step | Chụp MỌI bước |
| Test 1 màn cô lập / 1 user khi lỗi nằm trong flow hoặc cross-user | Journey đầy đủ, đa-vai, dual-context (§4.2) |
| Tự viết selector rời khi repo đã có E2E helper | Tái dùng harness repo (§4.2) |
| Seed DB/gọi API tắt để "có sẵn user" rồi test | Bấm UI thật từ đăng ký — mới biết button/flow chạy (§4.2 luật 1) |
| Test 1 viewport desktop cho app mobile | Sát thiết bị: mobile-first, profile iOS/Android (§4.2 luật 2) |
| Bước hỏng thì đi đường vòng / bỏ qua | Fix rồi làm lại TỪ bước đó tới khi qua (§5.2) |
| Tạo test-data rồi để đó (rác vào production) | Ghi sổ tracker + clear trước production (§4.2 luật 3) |
| Observer phán cảm tính, không oracle | Diff vs ba-spec/design-spec (§3) |
| Fix khi code KHỚP spec | Đó là spec sai → handoff BA (§4c) |
| §6 không update sau ASK | §4b CAPTURE bắt buộc |
| Bê pattern lunar sang repo khác | Seed §6 rỗng mỗi repo |
| Hardcode ref repo cụ thể | Auto-discover / triage.config (§2) |
| Log telegram=ok khi fail/degrade/off [telegram-ref] | Ghi đúng trạng thái |
| Agent tự set AI_SIMPLE_NOTIFY / ghi ~/.ai-simple/config / thêm token consent | Consent là của user (§8) |
| Tự chế escalation/no-commit | Defer ai-simple (§7) |

---

## 11. Cross-reference + tie-breaker
- **Skill nền**: `ai-simple-product-dev` (#06 tier, #07 memory, #08 gate, #12 verify) — defer, không tự chế.
- **Pha trên (oracle)**: `BA` → ba-spec (AC); `ui-design-logic` → design-spec.
- **Tie-breaker** (cùng trigger "rà soát UI"): triage = multi-step flow+fix loop; review tĩnh 1 màn = ui-design-logic 06 §3; chạy test suite thuần (jest/playwright) hoặc static code review = KHÔNG phải triage (nếu máy user có skill riêng cho việc đó thì nhường).
- Chi tiết hợp đồng composition: `references/07-integration.md`.

---

## 12. Giới hạn đã biết
1. **Đúng-ngữ-nghĩa phân loại Observer** = phán đoán LLM; chỉ chạy-thật tích lũy chứng minh (evidence over time).
2. **Agent CHỊU chạy gate §2** vẫn honor-system ở tầng skill; cơ chế hóa nốt = PreToolUse hook chặn TeamCreate đến khi `triage-verify.sh` exit 0 (per-repo, cần user đồng ý — không tự thêm).
3. Self-test chỉ phủ cấu trúc, không phủ chất lượng fix.
