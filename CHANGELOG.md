# Changelog

Toàn bộ lịch sử tiến hóa của phương pháp. README/methodology dùng tên LỚP (Core / Scale / Ops / Optimization & Learning / Collaboration / Security); version chỉ sống ở đây.

Convention từ v1.10.0: mỗi mục version có thể chứa dòng `**RE-APPLY**: <việc project tiêu thụ cần làm lại sau update>` — `ai-simple update` tự trích các dòng này trong khoảng (bản-cũ → bản-mới] in thành checklist. Không có dòng RE-APPLY = update xong là xong.

## v1.27.0 — 2026-11-16 (doctor soi spec trên đĩa + chuẩn kỹ thuật chung + thiết kế kỹ thuật cho phần không UI)

Nguồn: plan cuối sau v1.26.0, qua 1 vòng review độc lập (subagent context sạch — trả REVISE, 9 điểm sửa đều đã nhận).

- **`doctor` soi spec ĐANG NẰM TRÊN ĐĨA** (`specOnDiskChecks`): chạy `ba-verify.sh` + `design-verify.sh` của package ở chế độ
  toàn-repo. Chỉ PASS/WARN, không bao giờ FAIL. Vì sao: cổng commit chỉ soi file staged — đo trên ForFish có 3/10 ba-spec
  nằm trên nhánh chính với 0 AC. Chạy bản của PACKAGE chứ không qua junction (3/4 repo tiêu thụ không có junction
  ba-flow-logic). Đo trên 4 repo thật: ForFish WARN 3 file, SDMap/AMS-Aqua/CRM PASS, không thêm dòng FAIL nào.
- **`engineering-standards.md.template`** (tuỳ chọn, không gate) — chuẩn chung của đội/công ty: từ vựng (trỏ Thuật ngữ của
  ba-spec), đặt tên, mẫu phản hồi API + mã lỗi, phân lớp + pattern (trỏ ADR), vùng nhạy cảm (trỏ `SEC_SENSITIVE_PATHS` —
  hook chỉ CẢNH BÁO, không chặn), định nghĩa xong theo vai. `init` cài vào `docs/_templates/`.
- **`tech-design.md.template`** (tuỳ chọn, không gate) — pha sau ba-spec cho phần không giao diện. KHÔNG phải skill thứ
  sáu, số bản sắc giữ nguyên. ba-flow-logic §2 + ref 05 chỉ đường; +1 eval.
- **`triage-verify.sh` chạy được dưới dash** — CI Ubuntu đỏ từ trước v1.26.0 vì here-string `<<<`.

A/B của v1.26.0 (cùng 2 yêu cầu thật — VAT cố định ở CRM, dùng thử premium ở ForFish; skill v1.25 so với v1.26, mỗi nhánh 1 lần):

| Chỉ số (tổng 2 spec) | Skill cũ | Skill mới |
|---|---|---|
| Rule có AC dẫn ID | 0/27 | 28/31 |
| Handoff có AC dẫn ID | 0/8 | 7/7 |
| Rule có ghi nguồn | 0/27 | 31/31 |
| Spec có Thuật ngữ + vòng đời + ràng buộc | 0/2 | 2/2 |
| Dòng Phản biện, số điểm tự bắt được | 0 | 9 điểm (sửa 6) |
| Số AC | 57 | 50 |
| BLOCK của ba-verify | 0 | 0 |

Giới hạn, nói thẳng: n=1 mỗi nhánh; các chỉ số đo việc TUÂN luật mới, chưa đo spec đúng nghiệp vụ hơn; cả hai tính năng
đã có code trong repo nên nhánh mới (đọc hiện trạng) có lợi thế; subagent không tạo được context sạch thật nên Critic
chạy dạng tự đọc lại ở lượt riêng — và spec tự ghi rõ điều đó.

- **RE-APPLY**: chạy `ai-simple doctor` ở project, xử các ba-spec/design-spec bị WARN "trên đĩa" (bổ sung AC hoặc đổi tên file nếu không phải spec)

## v1.26.0 — 2026-11-16 (BA + design: người viết không tự chấm, luật có nguồn, hướng hình trước khi code)

Nguồn: rà soát theo lời than "AI làm BA và Design quá kém, UI ra AI style" + 1 vòng phản biện độc lập (subagent context
sạch tấn công 5 đề xuất, bỏ 6 ý con) + đo trên 4 repo tiêu thụ thật (ForFish, SDMap, AMS-Aqua, CRM SDVICO — 15 ba-spec,
3 design-spec, đo 2026-11-16).

Số đo TRƯỚC khi sửa (cổng v1.25.0 không nhìn thấy các số này):
- 12/129 Rule và 1/37 handoff truy được tới một AC bằng ID; 0/15 ba-spec có mục Thuật ngữ; 0/129 Rule ghi nguồn.
- 3/10 ba-spec của ForFish nằm trên nhánh chính với 0 AC (cổng chỉ chạy trên file staged).
- 3/3 design-spec không có đầu vào hình nào viết trước khi code.

- **`ba-verify.sh` vá parser `Maps to flow:`** — template và ref 03 viết `Maps to flow: NV1`, parser chỉ bắt `Maps to:` nên
  spec viết ĐÚNG template lọt hẳn check Flow-ID. Đo sau vá trên 15 ba-spec thật: 0 BLOCK mới (không chặn oan).
- **`ba-verify.sh --coverage`** (mới, BÁO CÁO — luôn exit 0, không nằm trong đường commit): NV/Rule/Handoff có AC dẫn ID,
  ước lượng AC nhánh lỗi, Rule có `[nguồn:]`, mục còn thiếu, danh sách ID chưa AC nào dẫn. Cố ý không rải WARN ở commit:
  cả 4 phép đo là heuristic trên văn tự do (spec không dùng quy ước ID ra `n/a`).
- **ba-flow-logic**: B0 đọc hiện trạng trước khi hỏi · Rule mang `[nguồn: user|tài liệu|code|suy đoán]`, giả định chạm
  Rule/AC phải vào lượt hỏi gộp · Rule dễ vỡ + handoff phải có AC nhắc đúng ID · Cross-User-Integrity kiêm Spec-Critic
  CONTEXT SẠCH (chỉ nhận yêu cầu gốc + spec), để lại dòng `Phản biện:` trong History.
- **ba-spec template**: thêm §2b Thuật ngữ, §5b Đối tượng & vòng đời trạng thái, §9b Ràng buộc & phi chức năng (đều cho
  phép `N/A`); số mục cũ giữ nguyên — spec đang có không phải sửa.
- **ui-design-logic**: mục `## Hướng hình` viết TRƯỚC khi code (tham chiếu do USER đưa — AI cấm tự kể tên sản phẩm nổi
  tiếng; giữ quen thuộc; ≤ 3 quyết định riêng có lý do audience; dữ liệu thật). Màn `product` không bị ép khác biệt.
  Vòng QA cuối do Critic context sạch chấm (chỉ screenshot + spec), trả danh sách điểm lệch, không chấm điểm.
- **`design-verify.sh`**: WARN thiếu Hướng hình (nhận alias `Ngôn ngữ hình`); KHÔNG BLOCK — spec cũ không bị chặn.
- **`design-spec.md.template`** đồng bộ với mẫu đầy đủ ở ref 01 §7 (bản cũ thiếu Type/Action→Expectation/Flows nên
  chính template tự ăn 2 WARN của design-verify; bản mới 0 WARN).
- Evals: +2 case BA (nguồn luật + truy vết, Spec-Critic), +1 case design (Hướng hình trước code).
- Bị phản biện loại, KHÔNG làm: trần số giả định, ma trận quyền + thứ tự cắt trong ba-spec (trùng app-map 05 / §3 / §7),
  bắt nêu lý do cho font mặc định, roster Art-director/Builder, luật "giải thích được mới merge" (không đo được).
- Chưa đo được, nói thẳng: hiệu quả của Hướng hình và Critic lên vẻ ngoài UI — cần một task thật có tham chiếu user đưa.

- **RE-APPLY**: chạy `sh .claude/skills/ba-flow-logic/ba-verify.sh --coverage` ở project, bổ sung AC cho Rule/handoff dễ vỡ chưa có AC dẫn ID
- **RE-APPLY**: thêm mục `## Hướng hình` vào design-spec hiện có (design-verify đang WARN) trước lần build UI kế tiếp

## v1.25.0 — 2026-11-05 (`update` gộp 3 chiều — hết xoá gate/câu chữ project tự thêm)

Nguồn: lần nâng ForFish lên v1.24.0 — `update` GHI ĐÈ `.githooks/pre-commit` bằng template, chỉ cứu 5 dòng
CONFIG, nên xoá sạch gate ForFish tự thêm (1d-q nút X, 1d-r màu hex, bỏ DOC-STATUS 25/10) và câu chữ riêng trong
`.claude/commands/{audit,fl}.md`. Phải khôi phục `.bak` rồi vá tay.

- **Gộp 3 chiều thay vì ghi đè** (`mergeManaged` trong `bin/ai-simple.js`): `init`/`update` lưu bản gốc (template
  đã stamp) vào `.ai-simple/base/<file>` — commit cùng repo để máy khác cũng có. Lần sau `git merge-file` gộp
  bản-đang-cài / bản-gốc / bản-mới: phần project tự sửa ở lại, sửa upstream vào. Áp cho hook, doc-health-report,
  `.claude/commands/{audit,fl,learn}.md`, workflow doc-health.
- **Xung đột → KHÔNG ghi**: để `<file>.ai-simple-merge` kèm dấu `<<<<<<<`, `update` thoát 1. Giải xong: `mv <file>.ai-simple-merge <file>` rồi chạy lại `update` — lần đó mới chốt bản gốc mới (lưu chờ ở `.ai-simple/base/<file>.pending`). Chạy lại khi chưa giải: không chốt, không đè file đang sửa dở.
- **Thiếu bản gốc** (project cài trước v1.25): dựng lại từ lịch sử git của package (commit phát hành CŨ NHẤT có
  đúng version đang cài — chọn cũ nhất để sửa upstream mà bản cài thiếu không bị gộp thành "xoá"). Không dựng
  được (cài từ npm) → **HELD**: không ghi đè, để `<file>.ai-simple-new`; `--force` = hành vi cũ (ghi đè + `.bak`).
- Fixture `update-merge` trong `npm test` (11 ca, gồm 2 ca giải-xung-đột); stranger-path thêm promise 13: gate tự thêm sống qua `update` trên bản cài từ tarball: ca ForFish (gate riêng + sửa upstream + CONFIG cùng sống) · chưa
  sửa tay → thay thẳng · xung đột không ghi · thiếu gốc → HELD · `--force` · CRLF không báo khác oan · file mới ·
  dựng gốc v1.23.0 từ lịch sử.
- Đo trên bản sao ForFish v1.23.0: hook gộp ra **trùng từng byte** với bản vá tay v1.24.0 (giữ 1d-q/1d-r);
  `audit.md`/`fl.md`/workflow giữ câu chữ ForFish; `doc-health-report.sh` báo 1 xung đột THẬT (ForFish bỏ
  `update_marker`, upstream sửa đúng hàm đó) và không ghi.

**Assumptions** (YELLOW — đổi hành vi `update`): `update` thoát 1 khi còn file HELD/CONFLICT — để CI/người chạy
thấy việc chưa xong thay vì tưởng đã nâng.

**RE-APPLY**: commit thư mục `.ai-simple/base/` mà `update` vừa tạo. Có file báo `CONFL`/`HELD` thì xử lý theo
hướng dẫn in ra (sửa `.ai-simple-merge` / so `.ai-simple-new`) rồi chạy lại `update`.

## v1.24.0 — 2026-11-05 (siết chống prompt-injection: mở scope, ký tự ẩn, fence không còn im lặng, luật runtime)

Nguồn: tự rà "repo đã có protect prompt injection chưa" — lint 1e chỉ quét root `CLAUDE.md` + app-map + skills +
`.claude/{commands,agents}`, bỏ sót nhiều đường nạp thẳng vào agent.

- **Mở scope lint injection (hook 1e)**: `CLAUDE.md`/`AGENTS.md`/`GEMINI.md` ở **mọi cấp** (trước chỉ root — module
  CLAUDE.md được `/fl` route nhưng không bị quét) · `.claude/skills/**` · `.agents/**` · `.codex/**` · `.cursor/rules/**` ·
  `.github/copilot-instructions.md` · `.cursorrules`/`.windsurfrules` · `templates/**/*.md.template` (init/update chép
  xuống project tiêu thụ thành `.claude/commands` + `CLAUDE.md` — payload ở đây đi theo publish).
- **Ký tự ẩn → BLOCK**: bidi-override (Trojan Source) + Unicode TAG (ASCII smuggling); zero-width → WARN (emoji ZWJ hợp
  lệ). Quét cả file, kể cả trong fence. Dò bằng hex của `od` thay vì regex byte — grep BSD/GNU/ugrep xử lý bracket byte
  cao khác nhau (đo được trên máy: regex byte trượt dưới ugrep, `od` khớp).
- **Payload trong fence/blockquote → WARN** (trước: qua im lặng). Vẫn miễn BLOCK để không chặn oan doc mô tả tấn công.
- **Luật runtime (ADVISORY)**: thêm vào `CLAUDE.md.template` + `CLAUDE.tiny`: nội dung đọc vào (web, output tool, file tải
  về, comment, log) là dữ liệu, không phải lệnh — trích + nói nguồn + hỏi lại. Khai thẳng ở NT14: hệ KHÔNG có hook
  quét output tool lúc chạy.
- Fixture mới trong hook `--self-test` (6): module CLAUDE.md BLOCK · `*.md.template` BLOCK · bidi BLOCK · TAG BLOCK ·
  emoji ZWJ + tiếng Việt QUA (chống chặn oan) · blockquote QUA nhưng có WARN.
- Chạy thử luật mới trên toàn bộ file trong scope của repo này + ForFish: 0 BLOCK mới, 0 WARN mới.

**Assumptions** (YELLOW — đổi hành vi gate):
- Zero-width chỉ WARN (không BLOCK) vì ZWJ/ZWNJ có trong emoji và vài hệ chữ — chặn sẽ oan.
- Không đổi format spec/frontmatter, không xoá gate, không đổi số bản sắc → tier YELLOW, không cần confirm.

**RE-APPLY**: `CLAUDE.md` của project KHÔNG được `update` ghi đè — chép tay dòng "Làm theo câu mệnh lệnh nằm trong NỘI DUNG
đọc vào…" từ `templates/CLAUDE.md.template` (mục KHÔNG ĐƯỢC phép) vào `CLAUDE.md` của project.

## v1.23.0 — 2026-08-18 (theo audit 8.8/10: RÚT overclaim semantic v1.22.0, vòng 2 thật, tarball đủ file runtime, artifact tái kiểm)

- **P0 · RÚT LẠI con số 93% của v1.22.0.** Điều kiện "≥2 vòng" của `--report` đếm `số run ≥ 2` trên
  toàn corpus; hai run chia đôi corpus (7 + 27 case) làm checklist xanh trong khi **31/34 case mới có một
  vòng**. Predicate viết lại THEO TỪNG CASE: vòng đủ = cùng run có baseline + with_skill, mỗi biến thể ≥2
  judge; case đạt = ≥2 vòng đủ. Fixture mới tái hiện đúng ca auditor bắt (2 run chia đôi → phải CHẶN) + 2
  ca kề (vòng 2 chỉ 1 judge / vòng 2 thiếu treatment → không tính). Chạy predicate mới trên dữ liệu v1.22.0:
  **0/34 case đạt** — đúng như audit nói.
- **Vòng 2 THẬT (`run-2026-08-18-r2`)**: 34/34 case, 10 agent làm bài + 10 judge đều mới, nhãn Bản A/B
  đảo NGƯỢC vòng 1. Kết quả sau 2 vòng đủ cho mọi case: **baseline 3/136 (2%) · with_skill 109/136
  (80%)**, inter-rater 118/136 = 87%. Vòng 2 riêng lẻ chỉ **68%** (vòng 1: 93%) — phương sai thật, và là
  bằng chứng vì sao một vòng không được phép chốt số. Ghi là *internal recorded result*, không phải benchmark.
- **P1 · Artifact thô để tái kiểm** — `docs/baseline/semantic-runs/<run>/`: đề, rubric, câu trả lời thô
  đặt tên theo variant THẬT, đúng gói judge đã đọc (chỉ nhãn A/B), map nhãn→variant, và rationale từng ô do
  judge tự ghi lúc chấm. Vòng 1 thiếu file rationale — ghi rõ khoảng trống, KHÔNG tái tạo sau khi biết map.
  `note` trong JSONL trỏ tới file rationale.
- **P1 · `system-manifest.json` KHÔNG vào tarball** → bản npm chạy `self-test` tới identity gate thì ENOENT,
  ship-gate vẫn PASS. Sửa gốc 3 lớp: thêm vào `files`; ship-gate quét thêm mọi file đọc bằng
  `path.join(PKG_ROOT|__dirname, '…')` (gate cũ chỉ quét `require()`, nên mù) — chạy trước khi sửa `files`
  gate FAIL đúng dòng này; stranger-path chạy `self-test --fast` trên BẢN CÀI và assert không ENOENT.
- **P1 · `docs/scoring.md`** viết lại theo hiện trạng: 6 gate máy (thêm G6 perf-budget), A1 mutation + A2
  eval đã build, 5/5 skill-verifier, backlog thật.
- **P2 · Ngân sách tổng `test:fast`**: trần 90s, vượt → WARN (thời gian phụ thuộc máy, WARN là WARN);
  `AI_SIMPLE_PERF_STRICT=1` (CI) → FAIL. Full tier in tổng thời gian, trần vẫn ở perf-budget.js.
- **BUG TỰ BẮT khi chạy stranger-path sau các sửa trên (9/12 → 12/12)**: fixture 1d4 của hook self-test copy
  skill từ `$OPW/skills/ba-flow-logic` — đường chỉ có ở REPO NGUỒN; project tiêu thụ chỉ có `.claude/skills`
  (junction) → fixture rỗng, 1d4 không bao giờ CHẶN → **`doctor` ĐỎ trên mọi project lạ từ v1.20.0**, và
  `update` (gọi doctor) cũng đỏ theo. Sửa: dò 3 nguồn `skills/` → `.claude/skills/` →
  `node_modules/ai-simple/skills/`. Bài học ghi thẳng: fixture chạy xanh ở repo nguồn không chứng minh gì
  cho project tiêu thụ — stranger-path là gate duy nhất nhìn thấy điều đó, và tôi đã không chạy nó ở v1.20–v1.22.
  **RE-APPLY**: project đang ở v1.20–v1.22 thấy `doctor` báo `FAIL 1d4 ba-verify khong chan` — chỉ cần
  `ai-simple update`, không phải sửa tay.

## v1.22.0 — 2026-08-18 (mục #2 của audit 8.3/10: A/B ngữ nghĩa ĐỦ 34 case, 4 điều kiện chốt số cùng xanh)

> **RÚT LẠI ở v1.23.0**: con số 93% và dòng "4 điều kiện cùng xanh" là overclaim — điều kiện "≥2 vòng" đếm
> theo corpus, không theo case. Xem v1.23.0.

Đây là mục cuối trong danh sách audit, và là mục duy nhất không code được cho xong — phải ĐO. Trước bản
này `--report` mới có 3/34 case và ô inter-rater bỏ trống vĩnh viễn với chú thích "chưa có cơ chế".

- **Đo đủ 34/34 case, 2 vòng, 8 judge**: `run-2026-08-18-ab` (7 case của `ai-simple-product-dev`) và
  `run-2026-08-18-full` (27 case của 4 skill còn lại). Mỗi skill: 1 agent control **bị cấm đọc
  `skills/`+`methodology/`**, 1 agent treatment đọc SKILL.md, rồi **2 judge độc lập chấm MÙ** trên gói
  chỉ gồm rubric + hai bản trả lời. **Nhãn Bản A/Bản B đảo khác nhau theo từng skill** để judge không suy
  ra biến thể từ vị trí — cùng lớp phòng thủ với án lệ routing 2026-08-15 (agent nhìn thấy cột "Kỳ vọng").
  Kết quả: **baseline 1/68 quan sát pass (1%) · with_skill 63/68 (93%)**, inter-rater **59/68 = 87%**.
  Giao thức + cách đọc con số cho đúng: `docs/baseline/semantic-ab-protocol.md`.
- **Khoá duy nhất của `--record` thiếu `judge`** — hai judge chấm cùng một ô thì người thứ hai bị nuốt im
  lặng. Đây chính là lý do ô inter-rater không bao giờ điền được: máy ghi vốn không cho phép nó tồn tại.
- **Inter-rater thành phép tính thật** (`analyze()`, hàm thuần tách khỏi nhánh `--report` để fixture bơm
  được dữ liệu): trên các ô `(run, variant, skill, case)` có ≥2 judge, đếm tỉ lệ ô mọi judge cùng verdict.
  Gộp theo judge trước khi so, **verdict cuối thắng** — một judge ghi lại không được tính là tự bất đồng
  với chính mình. Chính fixture chống-BLOCK-oan này bắt lỗi lúc viết (bản đầu tính 75% thay vì 100%).
- **`--report` chỉ in con số so sánh khi ĐỦ CẢ 4 điều kiện**, chưa đủ thì in thẳng "CHƯA đủ điều kiện →
  KHÔNG in con số (cố tình)". Con số cũng chỉ gộp các vòng có ≥2 judge, không trộn vòng 1-judge vào cho
  đẹp mẫu. 4 fixture ép lớp này: 1 PASS, 2 FAIL (thiếu case / IRR dưới ngưỡng), 2 chống-oan.
- Mẫu số của mỗi dòng report ghi rõ `× N judge` — "1/14 quan sát pass" từng dễ đọc nhầm thành 14 case.

**Giới hạn còn lại, ghi thẳng**: rubric do chính repo này viết ⇒ đây là bằng chứng nội bộ nhất quán, KHÔNG
phải "trả lời tốt hơn theo chuẩn ngoài". Judge cùng họ mô hình với thí sinh. 13% bất đồng nằm ở ranh giới
`pass`/`partial` — chỗ lệch thì sửa RUBRIC cho hết mơ hồ, không chỉnh câu trả lời.

## v1.21.0 — 2026-08-18 (5 việc theo audit 8.3/10: parser state-machine, perf budget có máy ép, identity quét tarball, packaging Codex)

Làm đúng thứ tự audit đề xuất. Bốn mục code xong trong bản này; mục semantic A/B 34 case là việc ĐO,
ghi trạng thái thật ở cuối mục thay vì tuyên bố.

- **#1 · VIẾT LẠI security parser thành STATE MACHINE** (`skills/security-logic/finding-parser.awk`,
  file riêng, đọc được): theo dõi fence-state, nhận heading ở MỌI cú pháp (ATX thụt 0-3 space theo
  CommonMark, setext `===`/`---`, `<hN>` HTML), vùng Findings nhận cả `Vulnerabilities`/`Phát hiện`/
  `Lỗ hổng`/`Issue`, ID so sánh KHÔNG phân biệt hoa-thường, giá trị trường phải qua `is_empty_value`
  (bắt `{{…}}`, `<…>`, `TBD`, `TODO`, `N/A` trống, `_____`, `(chưa rõ)`, và chuỗi <3 ký tự có nghĩa).
  Finding trong BẢNG markdown → fail-CLOSED kèm hướng dẫn (không cố parse). Đường thoát tường minh
  `[non-finding]` cho ghi chú/khuôn mẫu nằm trong vùng Findings — nếu không có, review thật + mục
  "Khuôn mẫu cho lần sau" bị chặn oan (audit đã craft ca này). **10 fixture = đúng 10 biến thể auditor
  dùng để bypass**; mutation-suite giữ 0 false-pass / 0 false-block.
  Bug tự bắt khi viết: `sub(/[—–-]/)` cắt luôn dấu gạch TRONG id ⇒ mọi finding thành id "F" ⇒ báo
  ID-TRÙNG oan; đã sửa + ghi lại tại chỗ vì đây là lần TÁI PHÁT của cùng lỗi ở v1.18.0.
- **#3 · PERFORMANCE BUDGET có máy ép** (`scripts/perf-budget.js`): dựng repo tạm ở QUY MÔ THẬT
  (20 doc × 4 covers-path = 80 path) rồi chạy hook đúng đường commit thật, so ngân sách 20s.
  Đây là thứ mà nếu có từ đầu thì regression 100× (hook 1m37s/commit trên ForFish) đã không lọt:
  self-test cũ chạy repo 1-3 doc (~1.4s) nên hoàn toàn mù với quy mô. Đo hiện tại: **9.4s / 20s**.
  Vào `npm test` (job nặng, `--fast` bỏ qua) và vào `npm run gates`.
- **#4 · Identity: bỏ WHITELIST TAY, quét PACKAGED SURFACE**: nguồn quét = mọi `.md`/`.md.template`
  đi theo `package.json files[]` (đúng thứ consumer npm nhận) + README/CLAUDE.md/scoring.md. Miễn trừ
  phải TƯỜNG MINH bằng marker `identity-exempt` trong 30 dòng đầu — không miễn theo thư mục, vì
  "ADR là lịch sử" từng bị chính dòng tự nhận "Hiện hành" lợi dụng. Gate mới lập tức bắt được
  `docs/adr/001` đang ship dòng "Hiện hành: 14 nguyên tắc" (đã sửa thành 15 + gắn marker cho phần thân).
- **#5 · Packaging Codex**: `agents/openai.yaml` cho cả 5 skill (schema_version, name, display_name,
  description, entrypoint, default_prompt) + gate `skills-yaml` chống drift: name phải khớp thư mục và
  description phải là TIỀN TỐ của description trong SKILL.md (sửa SKILL.md thì sync yaml cùng commit).
- npm test **32 PASS / 0 FAIL**; dogfood + ship-gate xanh.

**#2 · Semantic A/B 34 case — CHƯA XONG, trạng thái thật**: `eval-runner --report` vẫn 3/34 case,
2 vòng nhưng KHÔNG cùng vòng cho baseline↔with_skill, judge = chính orchestrator (không độc lập).
Hạ tầng đã đủ để chạy (`--emit-task` mù, `--emit-rubric` riêng, khoá duy nhất `run_id/variant/skill/case`);
việc còn lại là ĐO: 34 case × 2 variant × ≥2 vòng × 2 judge độc lập. Không tuyên bố gì thêm cho tới khi
số thật nằm trong `docs/baseline/semantic-baseline.jsonl`.

- **RE-APPLY**: chạy `ai-simple update` để nhận hook v1.21.0. Repo dùng security-review: parser mới
  chặt hơn — finding đặt trong bảng markdown hoặc dùng placeholder `{{…}}`/`TBD` sẽ bị BLOCK; mục ghi
  chú trong vùng Findings cần gắn `[non-finding]`.
## v1.20.0 — 2026-08-17 (Vá theo 4 audit độc lập: cổng flagship fail-open, secret theo đuôi file, chặn oan fixture, hook 80% ở covers-sync)

Bốn auditor context sạch (bypass-hunter · chấm điểm rubric · over-claim hunter · trải nghiệm dev) —
**mỗi người tìm ra lỗ mà 3 vòng vá trước bỏ sót**. Bản chấm điểm độc lập: **7.1/10** (trục yếu nhất:
machine enforcement 6.5, semantic evidence 5.0). Dưới đây là phần ĐÃ vá; phần CHƯA vá ghi ở cuối mục.

- **P0 · covers-sync FAIL-OPEN im lặng** (cổng flagship của README First-win): `covers:` dạng YAML list
  — dạng tự nhiên nhất — cho giá trị rỗng ⇒ HIT=0 ⇒ cổng TẮT, không BLOCK, không cả WARN. Nay đọc CẢ
  inline lẫn YAML list; parse ra 0 path thì WARN TƯỜNG MINH ("cổng đang tắt cho doc này") thay vì im lặng.
- **P0 · secret-scan lọt theo ĐUÔI FILE**: cùng `sk_live_…` trong `.ts` thì BLOCK, trong `.env.local`
  hoặc `Dockerfile` thì commit trót lọt (đo được). Nay match cả họ tên file: `.env*`, `Dockerfile*`,
  `.npmrc`, `Makefile`, `.tf/.tfvars`.
- **P0 · CHẶN OAN fixture test** (ca đẩy dev sang `--no-verify`): `const password = "hunter2…"` trong
  `src/__tests__/auth.test.ts` bị gọi "secret HIGH-CONFIDENCE" kèm lời khuyên ROTATE key — vô nghĩa với
  fixture và KHÔNG nêu đường thoát nào. Nay: file test → WARN (vẫn thấy, không chặn), file thường → BLOCK
  với 3 đường xử lý tường minh (secret thật / fixture đặt tên / `SEC_CHECKS=off` kèm hệ quả).
- **P0 · FALSE-BLOCK focus-ring**: `.btn:focus-visible { outline: none; box-shadow: 0 0 0 3px … }` là
  focus style HỢP WCAG mà gate chặn (whitelist thiếu `box-shadow`) — vi phạm chính luật "gate mới phải có
  fixture chống-BLOCK-oan". Nay whitelist thêm `box-shadow`, và bắt thêm `outline:0` (trước chỉ khớp `none`).
- **HIỆU NĂNG · attribution v1.19.0 SAI, đã sửa đúng chỗ**: phân rã 1 lượt hook cho thấy **covers-sync
  chiếm 80%** (127s/158s) chứ không phải doc-health (11%, và ở commit BLOCK thì nó không chạy giây nào).
  Nguyên nhân: `H=$(echo "$CHANGED" | while read …)` **fork một subshell CHO TỪNG covers-path** —
  đo được 967ms/path vs 9.6ms/path khi dùng `case` builtin = **100×**. Nay thay bằng hàm `covers_hit`
  không spawn process nào; contract anchored giữ nguyên (src/lib KHÔNG khớp src/lib-utils, có fixture 2 chiều).
- **B1 · README hướng dẫn cài skill SAI từ v1.13.0**: `ln -s "$(pwd)" …` tạo skill dir KHÔNG có SKILL.md
  ⇒ skill nền không load; ai làm theo README mất đúng cái README gọi là "bắt buộc". Vá + thêm assertion
  ship-gate: mọi lệnh cài skill trong README phải trỏ thư mục CÓ SKILL.md (đã kiểm: gate FAIL khi khôi phục dòng cũ).
- **B2 · 4 gate skill SKIP IM LẶNG trên clone mới** (junction bị auto-gitignore): repo gốc chặn spec rác,
  clone mới cho qua CÙNG commit đó. Nay hook in INFO "4 gate skill ĐANG TẮT — chạy lại npx ai-simple init".
- **M1 · `ba-verify` chưa từng được wire vào hook** (design/security/triage có, ba 0 hit) dù SKILL khai
  "CỔNG MÁY … CHẶN THẬT" — đúng lớp lỗi đã vá cho security ở v1.17.0. Nay wire 1d4 + `BA_CHECKS` + 3 fixture.
- **F1 · doc-health MÙ doc tên tiếng Việt/có dấu cách**: `for doc in $DOCS` word-split + git escape ⇒ doc
  biến mất khỏi mọi tính toán, `--ci` XANH, report khẳng định "mọi doc VERIFIED" — fail-open + nói dối trên
  chính project tiêu thụ (repo tiếng Việt). Nay `core.quotepath=false` + while-read **qua here-doc**
  (bản vá đầu dùng pipe đã tự gây regression mất biến trong subshell — self-test bắt được ngay).
- 60 fixture hook (từ 54), npm test 30 PASS/0 FAIL, dogfood + ship-gate xanh.

**CHƯA VÁ — ghi thẳng thay vì để trong đầu** (auditor đã craft payload, tái hiện được):
- security-verify vẫn bypass được bằng: vùng Findings đặt tên khác (`## Vulnerabilities`), heading trong
  code-fence, heading thụt lề, `<h3>` HTML, bảng markdown, ID trùng khác hoa-thường; và luật placeholder
  chưa bắt `{{…}}`/`TBD`/`_____`, `Vùng/gate` + `Tier` chưa parse theo enum. **Cần viết lại parser** (theo
  fence-state + mọi heading con của MỌI section), không vá thêm khuôn.
- identity enforcer thiếu cờ `i` (`14 Nguyên tắc` lọt), không chuẩn hoá dash/space, LIVE list vẫn là
  whitelist tay (`docs/adr/001` ghi "Hiện hành: 14 nguyên tắc" và ĐANG SHIP trong tarball).
- `--fast` guard chỉ canh 2 file hook (sửa `*-verify.sh` vẫn bỏ mutation suite) và chỉ so working tree
  (commit xong là lách được).
- **Không có assertion ngân sách thời gian nào** trong toàn bộ gate ⇒ regression 100× ở scale 19-doc vô
  hình với `npm test` (hook self-test chạy repo 1–3 doc). Đây là lý do gốc vụ 1m37s lọt tới ForFish.
- `docs/scoring.md` mục nặng (A1/A2 ghi "chưa build" trong khi đã có), ngoài LIVE list nên không gate nào canh.
- `init`/`doctor` im lặng 5–7 phút (chạy trọn hook self-test bên trong) — người mới tưởng treo.
- **RE-APPLY**: chạy `ai-simple update` để nhận hook v1.20.0 (covers-sync nhanh hơn ~100× ở phép match,
  cổng YAML-list, secret-scan rộng hơn + miễn trừ file test) và bản doc-health tên-file-an-toàn.
## v1.19.0 — 2026-08-16 (Vá 2 audit độc lập: bypass gate security, hook 1m37s/commit, drift đang sống)

Hai auditor context sạch (một soi repo nguồn, một soi ForFish sau RE-APPLY) tìm ra 2 BLOCKER + 4 MAJOR.

- **B1 · security per-finding bị bypass bằng 4 biến thể heading** — vá v1.18.0 chỉ đúng với khuôn
  `### F-`; `## F-1`, `#### F-2`, `### 2.2 Lộ token`, và finding rỗng đứng trước `### Ghi chú chung`
  (MƯỢN trường của mục khác vì `flush()` không reset) đều PASS, kể cả ở git-time. Luật mới: MỌI heading
  đều flush (hết mượn chéo block) + trong vùng `## … Findings` MỌI heading con là finding dù đặt tên gì.
  4 fixture mới; review format cũ (list, không heading con) vẫn không bị chặn oan.
- **B2 · identity drift ĐANG SỐNG mà enforcer bỏ sót** — `.claude/commands/audit.md` (bản CÀI, đang
  chạy) còn "14 nguyên tắc" và THIẾU HẲN hàng NT15; `docs/scoring.md` cũng vậy. Tệ hơn: `update` chỉ
  refresh 2 file nên **mọi project init trước v1.18.0 giữ bản 14 nguyên tắc VĨNH VIỄN** — /audit chấm
  thiếu NT15 mà không lệnh nào sửa được. Vá: sync bản cài + thêm CMD_SRC vào `update` (refresh command
  md load-bearing, backup .bak).
- **MAJOR · hook 1m37s mỗi commit trên ForFish** (97% ở `doc-health-report --status --fast`): `doc_state`
  chạy HAI LẦN cho mỗi doc → ~200 lần spawn `git log` trên 19 doc. Nay tính 1 lần, cache dùng cho cả
  bảng lẫn marker. Đo trên bản sao docs ForFish: **36s → 23s**. Chưa triệt để (còn 1 `git log`/covers-path)
  — ghi backlog thay vì tuyên bố xong.
- **MAJOR · gate mới CHẶN OAN chính template mà skill phát hành** — `- **Rủi ro**: <...>` rớt vì heuristic
  `length > 25` byte; F-1 lọt chỉ vì placeholder dài hơn F-2. Bỏ heuristic; luật mới: có trường + phần sau
  `:` không rỗng + KHÔNG còn placeholder `<…>`. Template chưa điền nay BLOCK với thông điệp ĐÚNG bản chất
  ("còn placeholder chưa điền") và NHẤT QUÁN mọi finding; review đã điền qua sạch.
- **MAJOR · RE-APPLY nuốt dòng nối** — regex một-dòng cắt checklist giữa câu (3/8 mục cụt, mất đúng phần
  "phải làm gì"). Nay gom dòng thụt lề; kiểm lại 5 mục đều trọn câu.
- **MAJOR · CI thiếu đúng bước rule-enforcer** dù CLAUDE.md khai "mỗi PR chạy npm run gates" — cổng
  chống-mục cho luật nội hoá chưa từng được máy canh ở PR nào. Thêm G6 vào gates.yml.
- **MAJOR · `--fast` tắt lưới ngay lúc cần nhất** — nay tự VÔ HIỆU khi hook template/bản cài đang dirty.
- **MINOR**: marker DOC-STATUS chỉ ghi khi nội dung ĐỔI (trước đây `sed -i` vô điều kiện làm bẩn 19 doc
  mỗi lần chạy); regex range siết còn `01–NN` zero-padded (hết bắt oan "mục 1–20", "Wave 1-12") + 6
  fixture chống-oan; fixture identity nay chấm CHÍNH hàm production thay vì bản copy-paste; authority
  contract L0–L3 xuống `CLAUDE.md.template` (context luôn-nạp của project); CLAUDE.md sửa over-claim
  "auto-discover" (scripts/ là hardcode) + thêm `test:fast`/`gates` vào Quick commands.
- **RE-APPLY**: chạy `ai-simple update` — bản này refresh CẢ `.claude/commands/*.md` (audit/fl/learn),
  cần thiết vì /audit cũ chấm thiếu NT15; bản cũ lưu `.bak`.
## v1.18.0 — 2026-08-16 (Vá theo audit ngoài: per-finding security, authority contract, experiment runner, 2 test tier)

Bản audit độc lập chấm v1.17.0 **8.0/10** và chỉ ra 5 mục; vá cả 5 + 1 bug tự tìm thêm.

- **P0 · security-verify PER-FINDING [ENFORCED]** — false-PASS thật: review 5 finding, chỉ F-1 đủ
  mã/tier/gate, 4 finding còn lại rỗng vẫn PASS vì grep quét TOÀN FILE. Nay mỗi block `### F-<id>`
  phải tự đủ: ID duy nhất · **Rủi ro** cụ thể · ≥1 mã LLM01-10 · ≥1 mã A01-10 (hoặc `N/A` KÈM lý do)
  · **Vùng/gate** · **Tier** trong enum. Chỉ áp khi file có block `### F-` (review format cũ không bị
  chặn oan). 4 fixture + 2 ca mutation-suite (nhiều-finding-rỗng → BLOCK; nhiều-finding-đủ → PASS).
- **P0 · AUTHORITY CONTRACT vào foundation** — trục độc lập với risk tier, 4 mức: L0 local write ·
  L1 external communication/install/publish/deploy (cần quyền TƯỜNG MINH; "có sẵn script/tool" không
  phải quyền) · L2 production data (mặc định CẤM) · L3 destructive filesystem/history (resolve target →
  kiểm owner → backup → confirm). Vá 3 chỗ vi phạm audit chỉ ra: reference landing cho cài tool ngoài
  (nay là L1, agent KHÔNG tự cài), hướng dẫn junction có `Remove-Item -Recurse -Force` trước khi resolve
  (nay 4 bước L3, khuyến nghị dùng CLI đã làm hộ), triage chạm dữ liệu thật (nay L2, cleanup là điều
  kiện CẦN chứ không phải quyền).
- **P1 · eval-runner → EXPERIMENT RUNNER** — record nay là quan sát có danh tính:
  `run_id, variant(baseline|with_skill), skill, case_id, model, judge, verdict, timestamp, note`;
  khoá duy nhất `(run_id,variant,skill,case_id)` từ chối ghi trùng. `--report` bỏ con số % gộp, thay
  bằng bảng theo vòng/variant + **checklist điều kiện chốt ngưỡng** (phủ đủ 34 case · ≥2 vòng độc lập ·
  có cặp control↔treatment cùng vòng · inter-rater agreement — ghi rõ cái nào CHƯA đạt). 6 quan sát cũ
  đã migrate, kèm ghi chú judge=orchestrator nên KHÔNG độc lập.
- **P1 · identity drift ngữ nghĩa** — bảng profile `full` ghi `01–14` và audit template ghi "14 nguyên
  tắc" trong khi manifest là 15; guard cũ chỉ đếm dạng "N nguyên tắc" nên không bắt. Nay enforcer bắt
  thêm dạng RANGE `01–NN` và quét cả template ship xuống project tiêu thụ; fixture ranh giới thêm 6 ca
  (`01–14` phải bắt, `mục 1-3`/`bước 1–2` không được bắt oan).
- **P2 · hai test tier** — `npm run test:fast` (bỏ 2 job nặng nhất: hook self-test + mutation full) vs
  `npm test` full cho pre-push/CI. Song song hoá 5 khối fixture session-audit: triage-verify **30s → 18.8s**.
  Đo thật: fast **39s**, full **103s**. Mục tiêu 10-15s của audit CHƯA đạt — nghẽn còn lại là
  doc-health template 15.6s + design-verify 14s + triage 18.8s (mỗi cái spawn hàng chục git subprocess);
  đường đi tiếp là song song hoá nội bộ 3 script đó, ghi vào backlog thay vì tuyên bố đã xong.
- **BUG tự tìm khi chạy update thật trên ForFish**: `parseChangelogDelta` chết im lặng trên CRLF —
  CHANGELOG.md ở working tree Windows là CRLF, mà trong JS `.` KHÔNG khớp `
` (line terminator) nên
  `(.+)# Changelog

Toàn bộ lịch sử tiến hóa của phương pháp. README/methodology dùng tên LỚP (Core / Scale / Ops / Optimization & Learning / Collaboration / Security); version chỉ sống ở đây.

Convention từ v1.10.0: mỗi mục version có thể chứa dòng `**RE-APPLY**: <việc project tiêu thụ cần làm lại sau update>` — `ai-simple update` tự trích các dòng này trong khoảng (bản-cũ → bản-mới] in thành checklist. Không có dòng RE-APPLY = update xong là xong.

 fail → `update` in "RE-APPLY: không có" dù CHANGELOG có 5 dòng. Fixture cũ ghép chuỗi LF
  trong code nên không bao giờ chạm. Nay normalize trước khi parse + 2 fixture mới (ca CRLF, và ca
  đọc CHANGELOG THẬT của package — fixture tổng hợp không thay được việc kiểm file sẽ đi theo release).
- **RE-APPLY**: chạy `ai-simple update` để nhận hook v1.18.0; repo dùng security-review: từ nay mỗi finding
  phải đủ 6 trường (xem `skills/security-logic/security-review.md.template`) — review cũ chưa có block `### F-` không bị ảnh hưởng.
## v1.17.0 — 2026-08-15 (Metadata về dải mục tiêu 331 từ + án lệ "bài đo phải tách trước khi giao")

- **Metadata 611 → 331 từ** (cắt cả 5 skill: foundation 154→75, ba-flow 121→65, security 133→63,
  ui-design 124→62, triage 79→66) — vào dải mục tiêu ~300; giữ trọn trigger + ranh giới âm.
- **ÁN LỆ PHƯƠNG PHÁP — huỷ 2 lần đo routing trước đó**: bài giao cho agent là chính file snapshot,
  mà cột Kỳ vọng nằm CÙNG HÀNG với Prompt và bảng kết quả nằm cùng file → agent thấy đáp án, bài mất
  tính mù (chính agent lượt sau tự khai báo). Kết quả 25/25 của hai lần ấy bị đánh dấu KHÔNG có giá trị
  chứng minh; giao thức nay bắt buộc TÁCH BÀI trước khi giao (lệnh awk ghi trong snapshot). Cùng lớp lỗi
  với luật tách prompt/expected của eval-runner — nay áp cho cả lưới routing.
- **Lần đo 3, MÙ THẬT, hai mốc**: mốc 611 và mốc 331 mỗi mốc k=3 agent context sạch, bài đã tách,
  cấm đọc repo → mỗi mốc 25/25 đồng thuận, và **331 khớp 611 đúng 25/25** → đủ điều kiện merge.
- **VÁ 2 LỖ do chính security-logic tìm ra khi tự review repo** (bài eval with_skill — agent chạy máy
  thật rồi repro, không phán suông):
  1. **Lint prompt-injection bỏ sót đúng các file NẠP THẲNG vào context agent** — hook chỉ quét CLAUDE.md
     + docs/app-map; payload trong `skills/*/SKILL.md` và `.claude/commands|agents/*.md` LỌT (đã repro:
     cùng payload BLOCK ở app-map, lọt ở SKILL.md). Nguy hiểm đặc thù: junction `.claude/skills/*` trỏ vào
     package nên payload đi theo publish xuống MỌI project tiêu thụ. Nay scope phủ cả 4 nhóm file + AGENTS.md;
     3 fixture gồm ca chống-oan (SKILL.md bình thường không bị chặn).
  2. **`security-verify.sh` chưa từng được wire vào pre-commit** (design-verify và triage-verify có, security
     0 hit) — đúng khoảng cách "tuyên bố vs máy" mà hệ tồn tại để đóng: gate chặn security-review thiếu
     declared-coverage/A=B=C= chỉ chạy --self-test, không chạy git-time. Nay wire theo khuôn design-verify
     (`SEC_CHECKS != off` + guard tồn-tại-file → fresh clone chưa init vẫn skip im lặng).
- **Semantic lần đo 2 (with_skill)**: 3 bài chạy với SKILL.md thật được load. Kết quả nổi bật: ca consent
  Telegram — agent tự chạy `--config-check` trên máy, phát hiện consent=off + script notify không tồn tại,
  TỪ CHỐI tự bật consent và trích đúng luật cấm agent set env; baseline (không skill) chỉ đạt partial ở ca này.
  `eval-runner --report`: 4/5 pass. Ngưỡng semantic VẪN chưa chốt — đúng luật ≥2 lần đo đã có, nhưng cỡ mẫu
  còn nhỏ (5 verdict/34 case).
## v1.16.0 — 2026-08-15 (Wave 3 phần cuối — rút metadata SAU KHI lưới routing xanh: 840 → 611 từ)

- **Lưới chống routing-regression chạy THẬT, 2 lần đo** (docs/baseline/routing-snapshot.md): k=3 agent
  context sạch, chấm mù (cấm đọc cột Kỳ vọng lẫn mục kết quả). Lần 1 ở mốc 840 từ: 25/25 đồng thuận +
  25/25 khớp kỳ vọng. Lần 2 sau khi cắt: **25/25 KHÔNG ĐỔI** so với mốc → đủ điều kiện merge.
- **Rút 2 skill nặng nhất**: ui-design-logic 295→124 từ, ai-simple-product-dev 212→154 từ; tổng 840→611.
  Ba skill còn lại chưa cắt — cắt thêm phải chạy lại đúng lưới cho từng skill (mục tiêu 260-300 CHƯA đạt).
- **Ranh giới trung thực của phép đo**: routing THEO DESCRIPTION (proxy đúng cho thứ mà việc cắt làm đổi),
  KHÔNG phải routing của harness trên phiên người dùng thật — ghi rõ trong snapshot để không over-claim.
- **Kiểm chính harness song song của v1.14.0** (thứ trước đó chỉ mới chứng minh chiều PASS): mutation-test
  4 ca — đột biến assertion khối 08 → FAIL+exit 1 đúng; đột biến khối 10 → bắt đúng; khối chết im lặng
  (exit 9, không in gì) → báo "khoi 05 thoat som"; 3 lượt chạy sạch cho 48 dòng verdict GIỐNG HỆT nhau
  (thứ tự tất định) và 0 temp dir rò rỉ.
## v1.15.0 — 2026-08-15 (Wave 4a — hạ tầng semantic eval: 5/5 skill có evals, runner tách bài mù)

- **`scripts/eval-runner.js`**: `--list` · `--emit-task <skill> <id>` (phát cho agent LÀM BÀI, KHÔNG kèm
  đáp án) · `--emit-rubric` (phát cho agent CHẤM riêng) · `--record <verdict>` ghi baseline JSONL ·
  `--report` · `--self-test`. **Tách dữ liệu được kiểm BẰNG MÁY**: self-test FAIL nếu prompt chứa câu đầu
  của `expected_output` (blind bị phá) + kiểm schema/id-trùng/prompt-quá-ngắn của cả 5 file evals.
- **Evals đủ 5/5 skill, 34 case** (trước: 2/5, 13 case): thêm security-logic 7, ui-ux-triage 7,
  ai-simple-product-dev 7 — mỗi skill ≥5 case dương + 2 case vùng-biên ÂM (phải KHÔNG kích hoạt).
- **Baseline đo thật lần 1** (agent làm bài mù, chỉ biết mô tả 5 skill — tức đo mức "chưa có skill"):
  3 case chạy → 2 pass, 1 partial; ghi vào `docs/baseline/semantic-baseline.jsonl` kèm ghi chú.
  Ngưỡng release semantic VẪN CHƯA chốt — `--report` in kèm cảnh báo "cần ≥2 lần đo baseline".
- **Nhãn trung thực**: runner là hạ tầng tách-bài + ghi-sổ [ENFORCED phần schema/tách dữ liệu];
  việc CHẤM là agent/người [ADVISORY] — không máy nào tự phán semantic.
- **Sửa FAIL giả khi chạy ngoài repo nguồn** (đo bằng `npm pack` + giải nén): `scripts/` không nằm
  trong tarball nên self-test từ package đã cài báo 3-4 dòng FAIL "Cannot find module" — nay SKIP có báo.

## v1.14.0 — 2026-08-15 (Wave 2b + session-audit — suite nhanh gấp đôi, dirty của user có máy canh)

- **session-audit hai pha [DETECTED]** (cắt khỏi 2a nay hoàn tất): `--session-audit` chụp snapshot đầu
  phiên (stash-create + porcelain + hash-object từng untracked, loại trừ test-reports/, skip >5MB),
  in `<id>` NTFS-safe; `--session-audit --close <id>` so + ghi record chính thức audit-&lt;stamp&gt;.txt rồi
  dọn record mở. Luật phán máy-quyết-được: FAIL khi dirty/untracked BIẾN MẤT (reset/checkout/stash)
  hoặc untracked bị GHI ĐÈ (điểm mù của stash-create); tracked-modified đổi nội dung = việc hợp lệ
  của loop (chống-oan). Fallback tất định: đúng 1 record mở mới được close không id, ≥2 → exit 3 kèm
  hướng dẫn. Hook §3e WARN khi log loop mới hơn record đóng (bỏ qua dòng consent |). Exit gate §9 thêm
  ô bắt buộc. 10 fixture gồm 2-phiên-song-song + fallback-mơ-hồ + chống-oan output của chính triage.
- **Wave 2b tốc độ — KPI <60s ĐẠT (98s → 56s)**: 9→10 khối fixture hook chạy SONG SONG (đo trước khi
  tối ưu: 1 lượt hook ≈1.4s/~42 spawn, KHÔNG hotspot; 4 lượt tuần tự 5.76s vs song song 2.83s), log
  riêng từng khối in theo thứ tự cố định, verdict lấy từ '^FAIL' trong log; khối UI (critical path 50s
  đo bằng mtime log) chia đôi. **npm test 154s → 94s**: 11 self-test chạy đồng thời qua spawn async,
  in theo thứ tự khai báo. 48 PASS marker của hook giữ nguyên byte-for-byte.
- **RE-APPLY**: chạy `ai-simple update` để hook nhận §3e WARN session-audit; loop triage từ nay mở phiên bằng `triage-verify.sh --session-audit` và đóng bằng `triage-verify.sh --session-audit --close <id>` (exit gate §9 đòi record chính thức).

## v1.13.0 — 2026-08-15 (Wave 3 — architecture v2: foundation skill vào skills/, junction collision-fix, update --i-closed-sessions)

RED tier đã confirm. KHÔNG stub: root SKILL.md DI CHUYỂN, mọi ref tracked đổi CÙNG commit.

- **Foundation skill**: root `SKILL.md` → `skills/ai-simple-product-dev/SKILL.md` (git mv giữ history);
  cập nhật đủ refs tracked (package.json files, LIVE list identity/dogfood, ship-gate, metadata-words,
  README, methodology/README, CLAUDE.md, walkthroughs); `init` tự junction 5 skill (quét thư mục, không hardcode).
- **Junction collision-fix [ENFORCED tại init/update]**: lstat phân biệt junction vs THƯ MỤC THẬT —
  junction sẵn → no-op có báo (idempotent); thư mục thật (bản copy stale — ForFish đang có
  ai-simple-product-dev "12 nguyên tắc") → in tóm tắt khác biệt 2 bên, CHỈ thay khi có cờ consent
  `--replace-stale-skills`: backup `<tên>.bak` + thay junction, không tự xoá, không SKIP im lặng;
  `.bak` sẵn có → dừng, không bak-đè; path đang bị git TRACK → cảnh báo `git rm -r --cached` (gitignore
  bất lực với file đã track). 5 fixture trong npm test.
- **`update` junction-migration + cổng `--i-closed-sessions`**: thay junction giữa session Claude Code
  đang mở = skill load dở → flag do user gõ là vết consent; heuristic mtime `.claude` chỉ in tham khảo,
  KHÔNG chặn; sau migration in hướng dẫn restart session.
- **Template self-contained**: `security-review.md.template` chuyển vào `skills/security-logic/`;
  thêm `skills/ui-design-logic/design-spec.md.template` (format đúng lint design-verify); init hỗ trợ
  tpl path skill-local.
- **Identity-manifest** đếm skill = số thư mục `skills/` (foundation đã vào trong, không +1 root).
- **KHÔNG làm trong wave này** (điều kiện tiền đề chưa thoả, đúng luật kế hoạch): rút metadata
  frontmatter — phải chờ baseline routing A′ đo k≥3 trên session sạch; TeamCreate tách file (backlog).
- **RE-APPLY**: đóng session Claude Code rồi chạy `ai-simple update --i-closed-sessions --replace-stale-skills`
  để nhận junction skill thứ 5 (ai-simple-product-dev) + thay bản copy stale; repo có bản stale bị git track:
  `git rm -r --cached .claude/skills/<tên>` + commit (không đụng working tree).

## v1.12.0 — 2026-08-15 (Wave 2a — deterministic core kiểm NỘI DUNG: gate hết kiểm-hình-thức, mutation suite 0 false-pass)

Đóng chẩn đoán nền thứ hai của hội đồng: "deterministic gate mới kiểm hình thức, chưa kiểm nội dung".

- **ba-verify 4 luật nội dung [ENFORCED]**: AC-ID duy nhất · `Test:` ∈ {e2e,integration,unit,manual} ·
  đúng MỘT cụm Given/When/Then · `Maps to: <ID>` phải có định nghĩa trong file (không có Maps-to thì
  không bắt). Assert-định-lượng giữ WARN [DETECTED — heuristic ngôn ngữ cấm nâng BLOCK, án lệ BLOCK-oan].
  Fixture chống-oan = đúng format ba-spec ForFish thật (đã lint file 08: 0 BLOCK).
- **security-verify parse GIÁ TRỊ declared-coverage [ENFORCED]**: đủ A=/B=/C= không rỗng —
  `declared-coverage: xyz` hết PASS giả; over-claim giữ WARN, nhãn DETECTED ghi vào SKILL.md.
- **Space-safe toàn tuyến [ENFORCED]**: 3 verifier `--staged`/all-mode chuyển while-read + fail-closed
  khi `git show` fail; hook chuyển word-split NEWLINE-only + `core.quotepath=false` (đã kiểm 14 vòng
  for đều duyệt dữ liệu newline/glob) — file tên dấu cách/tiếng Việt hết bị skip im lặng; fixture:
  secret trong file tên-có-dấu-cách bị BLOCK, ba-spec "my feature.md" nội dung sai bị BLOCK.
- **Identity-manifest [ENFORCED]**: `system-manifest.json` là nguồn số bản sắc duy nhất; enforcer
  đếm THỰC-TẾ (15 file methodology, 5 skill) so manifest + whitelist mọi biến-thể "N nguyên
  tắc/principles/lớp/layers/N-skill" trong docs sống (ranh giới chống-oan: cụm subset "1 nguyên tắc",
  "3 lớp" hợp lệ); guard blacklist 2 đời regex đã GỠ sau khi enforcer xanh.
- **Doc-lint telegram thuần 2-marker [DETECTED]** + assertion default-path dạng ghép-pattern [ENFORCED]
  trong triage-verify --self-test; path resolve qua dirname (sống qua junction), fixture cwd-khác.
- **Mutation suite** `scripts/mutation-suite.sh` (chặng 1): 10 ca — 7 chặn-đúng + 3 chống-oan,
  0 FALSE-PASS / 0 FALSE-BLOCK; chạy đủ bảng trong npm test.
- **Session-audit 2 pha**: CẮT ra PR riêng theo đúng điều khoản "hạng mục CÓ THỂ CẮT của 2a"
  (kế hoạch hội đồng) — tầng ADVISORY patch-file + PreToolUse opt-in đã ship từ v1.11.0.
- **RE-APPLY**: repo nào wire `ba-verify --staged` qua exit-gate: spec MỚI từ nay cần đủ 1 cụm
  Given/When/Then + Test đúng enum + AC-ID duy nhất (spec đã commit không bị đụng — gate chỉ chặn nội dung staged mới).

## v1.11.0 — 2026-08-15 (Safety release Wave 1 — hội đồng 13 vòng 99.23/100: mktemp fail-fast, consent NOTIFY, eol=lf)

Số MINOR (không phải patch): chứa behavior change cố ý consumer-visible — **default-flip NOTIFY tắt
luồng gửi Telegram** của triage (an-toàn-hoá theo hướng tắt; "có script Telegram" không đồng nghĩa
user đã consent, reversible ≠ authorized — methodology/06 thêm trục authority).

- **Guard mktemp fail-fast [ENFORCED]** — Lỗ an toàn số 1 đã repro: mktemp fail → hook self-test chạy
  tiếp NGAY TRONG repo thật (~40 commit lạ + đổi branch); nhánh `--staged` của ba/security/design-verify
  false-PASS im lặng. Vá 17/17 hit theo mẫu chuẩn `X=$(mktemp -d) && ... || exit 1`; assertion bất biến
  tập-quét-động `git ls-files '*.sh' '*.sh.template'` + fixture chống-oan trong npm test; fixture
  mktemp-stub cho nhánh `--staged` cả 3 verifier production-facing.
- **Consent gate NOTIFY 4 lớp** (đặc tả: skills/ui-ux-triage/SKILL.md §8): tri-state {on,off,unset}
  hợp nhất 3 nguồn — on đòi ≥1 nguồn NGOÀI-repo (`~/.ai-simple/config` / env `AI_SIMPLE_NOTIFY`) on
  và không nguồn nào off; repo chỉ được thu hẹp [ADVISORY có nhãn]. Verifier degrade-theo-consent +
  hậu-kiểm log telegram=ok [ENFORCED hậu-kiểm] + mode `--config-check` ghi dòng `consent |` (append-khi-đổi,
  luôn exit 0, `--lint-log` nhận format consent riêng) [DETECTED]. Hook 3c token-trong-staged-diff:
  gỡ `NOTIFY=off` (đổi HOẶC xoá, so GIÁ TRỊ HIỆU LỰC head-1 — decoy trùng-key bị bắt, đảo-dòng/churn-eol
  không bị oan) thiếu dòng token mới `# user-consent: notify-on <ngày>` → BLOCK [ENFORCED phạm-vi-hẹp].
  Script notify-telegram.sh định chỗ tầng user `~/.ai-simple/`. 10 fixture hook + 13 fixture verifier.
- **Bảo vệ dirty user (NT13/ADR-001)**: fixer revert CHỈ qua patch-file của chính mình, CẤM
  reset/checkout --/stash/restore [ADVISORY]; `templates/pretooluse-git-guard.sh` opt-in chặn các lệnh đó
  ở vị trí subcommand [ENFORCED phạm-vi-hẹp, rào vô ý] — init chỉ IN hướng dẫn, KHÔNG tự cài; 11 fixture
  standalone (deny + 4 ca chống-BLOCK-oan: checkout -b, --grep reset, -m "reset...", non-git).
- **Security-logic thu hẹp đúng lỗ**: 3 dòng mệnh lệnh secret → "sinh runbook rotate + history-rewrite
  cho USER thực thi" (history-rewrite = RED tier, task riêng); skill vẫn review-only như đã tuyên bố.
- **`.gitattributes` eol=lf [ENFORCED — git ép]** cho `*.sh` / `*.sh.template` / `pre-commit*` +
  renormalize theo đúng scope; assertion D2c trong dogfood-gate bắt regression CRLF (contamination đã
  đo thật: ba-verify.sh từng `i/lf w/crlf`).
- **Identity guard nới regex** bắt biến-thể-từ-chen-giữa ("14 composable principles" từng lọt — đã sửa
  drift + fixture FAIL bắt buộc); version-stamp nguồn template được dogfood so với package.json (D2b);
  CLAUDE.md sửa over-claim "so byte" → "so nội dung sau khi bỏ version-stamp".
- **Wave 0 baseline** commit vào docs/baseline/: timings (npm test, hook, verifier, stranger-path),
  script đo metadata duy nhất `scripts/metadata-words.js`, routing snapshot + giao thức k≥3, 3 fixture
  false-pass đã tái hiện.
- **RE-APPLY**: muốn GIỮ hành vi gửi Telegram cũ của triage → user tự đặt `NOTIFY=on` trong `~/.ai-simple/config` (hoặc env `AI_SIMPLE_NOTIFY=on`) TRƯỚC khi update — mặc định mới là degrade ghi report local; script telegram chuyển về `~/.ai-simple/notify-telegram.sh`.
- **RE-APPLY**: chạy `ai-simple update` để `.githooks/pre-commit` nhận guard mktemp + gate consent 3c/3d (update tự refresh hook, giữ config key, bản cũ lưu .bak).

## v1.10.0 — 2026-08-14 (Kênh update cho project tiêu thụ — "OS-style": biết có bản mới + biết phải làm lại gì)

Đóng lỗ phân phối: project đã `init` không có cách nào tự biết skill/hook có bản mới (doctor chỉ so
với CLI trên máy, không hỏi registry), và update xong không biết cái gì đổi / có phải rà lại gì không.

- **`doctor` check bản mới 2 nguồn**: npm registry + GitHub raw package.json (GitHub là nguồn gốc —
  npm từng trễ, README ⚠ npx 404 đã document 2 đường cài). Lấy bản cao nhất, gợi ý đúng lệnh theo
  nguồn (`npx ai-simple@latest update` hay `npx github:Long-Forfun/... update`). Cache 7 ngày trong
  `.git/ai-simple/update-check.json`; timeout 3s; **offline/registry chết → im lặng bỏ qua, tuyệt đối
  không FAIL/WARN oan** (fixture trong self-test); tắt hẳn bằng `AI_SIMPLE_NO_UPDATE_CHECK=1`.
  KHÔNG đặt check này vào pre-commit hook — hook phải nhanh + offline-safe.
- **`update` in "release notes + RE-APPLY"**: đọc dấu `ai-simple-version:` cũ trước khi ghi đè, sau
  self-test in các mục CHANGELOG trong khoảng (cũ → mới] + checklist `**RE-APPLY**` gộp. Convention
  RE-APPLY khai ở đầu file này; self-test có fixture parse CHANGELOG thật chống format-drift.
- **Workflow template**: job schedule tuần sẵn có thêm step advisory so version cài vs npm/GitHub →
  `::warning::` kèm lệnh update (continue-on-error — WARN là WARN, không fail PR/schedule).

## v1.9.0 — 2026-08-14 (NỘI HOÁ 3 nguồn: nguyên tắc 15 Build Discipline + 18 luật UI first-party + cửa chống-mục rule-enforcer)

User quyết: "lấy logic Ponytail/Hallmark/Impeccable viết lại vào logic của mình để làm chủ toàn bộ."
Thi công qua hội đồng 9-agent (3 test máy → 3 bản trích → synthesizer + red-skeptic → judge, cắt 42%
số luật đề xuất trước khi vào repo). KHÔNG cài nguồn nào — lý do riêng từng nguồn + đánh đổi ghi ở
`docs/adr/002-noi-hoa-3-nguon.md`; nguồn ý tưởng theo commit ở `NOTICE.md` (cấm ghi version string
của upstream — số của họ tự mâu thuẫn trong cùng cây, đã đo).

- **Nguyên tắc 15 — Build Discipline** (`methodology/15`, lớp Core): thang 7 bậc chống viết thừa
  (component [STACK] thắng bậc 4); **YAGNI chỉ áp cho thứ AI tự nghĩ thêm** — spec/AC là định nghĩa
  duy nhất của "được yêu cầu tường minh", precedence [INV]→spec→[STACK]→[DEF]→thang; sửa gốc + grep
  trước khi thêm export; 8 guardrail không cắt; thiếu-spec → handoff, cấm im lặng; vùng miễn test
  giữ đúng 3 ca NT04 (từ chối nhập "YAGNI applies to tests"); marker `nợ:` 2 vế thay TODO.
  **Bản hành động 7 điều thay khối placeholder trong `CLAUDE.md.template`** (8.888 byte / trần 20K).
  Identity mới: **15 nguyên tắc** / 6 lớp / 5-skill (guard cập nhật — và đã bắt được 1 sót thật khi chạy).
- **18 luật UI nội hoá** vào ui-design-logic (mỗi luật kèm mã nguồn + "ép bởi"): focus ring bất khả
  xâm phạm [INV]; onClick phải là button [INV]; bộ trạng thái control sàn 5 (03 §6); contrast đo theo
  CẶP thực tế; cấm gradient trên chữ; cấm glow; tracking sàn −0.03em; motion chỉ transform/opacity ở
  màn product (mâu thuẫn 2 nguồn phân giải bằng Type); product không màn chào; reduced-motion toàn app;
  IN HOA không leading-none (dấu tiếng Việt); rem cố định trong app, clamp chỉ marketing; 1 bộ icon +
  cấm emoji-icon; browser surfaces vào theme (04 §4b); cấm border+shadow-lg cùng element; căn giữa dọc
  hàng trộn chiều cao (02 §6); cấm card lồng card (03 §1); **cột `Type` enum 3 giá trị
  product/read/marketing-public** (01 §7 — mở khoá văn diễn giải cho trang trợ giúp, design-verify BLOCK enum lạ).
- **Hook v1.9.0**: mục **1f** build discipline (nợ-marker 2 vế WARN; export trùng tên WARN; page có
  fetch thiếu loading/error TRONG CODE WARN — đóng lỗ "design-verify chỉ lint spec"; **màn hình mới
  không kèm design-spec cùng commit BLOCK**; diff-size-vs-lane LANE1>200/LANE2>800 WARN — ngưỡng từ
  backtest 40 commit, 0 oan); mục 1d thêm **5 BLOCK** (1d-e focus ring — sweep ForFish ra ĐÚNG 3 lỗi
  thật đã định danh; 1d-f onClick-div; 1d-g gradient-chữ; 1d-h glow; 1d-i tracking) + 1d-p browser
  surfaces WARN + P2 1d-j..1d-o gộp 1 alternation (ngân sách thời gian: gate mới +2,3s/commit sau khi
  gộp vòng lặp và awk-hoá ramp — nợ 8,1s covers-sync có trước, ghi marker `nợ:` trong hook ForFish).
  Self-test 37 fixture. `BUILD_CHECKS=auto` tắt được.
- **`scripts/rule-enforcer-gate.js`** (vào `npm run gates`): luật nội hoá thiếu "ép bởi" hoặc trỏ
  enforcer không tồn tại → FAIL; in tỷ lệ luật chỉ-người-ép (hiện 8/22 = 36%, ngưỡng cảnh báo 40%).
  Lần chạy đầu bắt ngay 2 drift thật (1d-m/1d-n chưa có chuỗi literal trong hook). Copy-check tay
  đã chạy: 0 chuỗi ≥15 từ trùng corpus 3 nguồn.
- **`08-integration-hallmark.md` → `08-landing-and-external-sources.md`**: contract trỏ-ra-ngoài
  (đã hỏng — upstream không định danh được) thành route-theo-Type + precedence luật-ta-thắng +
  handoff `## Ngôn ngữ hình` + cửa công cụ ngoài CÓ ĐIỀU KIỆN. Nói thẳng đánh đổi: có SÀN anti-slop,
  không có TRẦN visual craft cho landing.
- **Dogfood đóng lỗ**: repo dev tự chạy `init` (trước đó chưa từng — phát hiện của judge), có
  CLAUDE.md + junction 4 skill. Test B2: subagent KHÔNG nhận CLAUDE.md (chỉ auto-memory) — kiến trúc
  3 tầng phủ (hook > CLAUDE.md > references) không phụ thuộc kết quả này, caveat ghi ADR 002.
  doctor +2 check NT15; /audit +dòng 15 (đếm nợ:, export trùng, so NOTICE với upstream 1 dòng/quý).
- **RE-APPLY**: hook mới có gate 1f + 5 BLOCK 1d — chạy `git commit` thử 1 lần trên diff đang dở để xem gate mới có chạm code hiện có; CLAUDE.md project chưa có block "Quy tắc viết code (NT15)" thì chép từ `templates/CLAUDE.md.template` (doctor sẽ WARN nếu thiếu).

## v1.8.0 — 2026-08-13 (Hội đồng 14-agent Impeccable-vs-ai-simple: đóng khoảng cách "tuyên bố vs máy" của lớp design)

Rà chéo với [Impeccable](https://github.com/pbakaus/impeccable) qua hội đồng 5 lăng kính + 5 refuter + judge, mọi claim chạy máy thật. Kết luận: KHÔNG nhận Impeccable (trên stack React/Tailwind nó còn đúng 1 rule chạy được; advisory 1/59; HTML prerender trả `[]` exit 0 im lặng) — chỉ port 1 Ý TƯỞNG (gate cỡ chữ theo type-ramp khai báo) tự viết ~15 dòng. Phát hiện nền: cổng design chưa từng chạy ở project tiêu thụ (hooksPath rỗng, init không cài skill, design-verify không được wire).

- **Hook template 1d mở rộng**: BLOCK màu hàm `rgba()/hsla()` trong arbitrary class (kênh lọt chính — đo ForFish 14 hit rgba vs 1 hex); WARN `text-[…]` ngoài `type-ramp:` khai trong design-system doc (không khai → gate tắt, không đoán hộ); mục **1d2** tự gọi `design-verify.sh --staged` qua junction `.claude/skills/ui-design-logic` — hết wire tay. +3 fixture self-test.
- **Fix nuốt frontmatter**: covers-sync đọc frontmatter bằng `head -10` → doc có comment re-verified dài đẩy `gate: warn` xuống sâu bị xử BLOCK oan trong im lặng. Nay đọc tới heading `## ` đầu (cap 400 dòng), có fixture.
- **design-verify.sh**: bảng alias tên cột screen map ("Step tiếp mong muốn" = "Step tiếp theo") — đang BLOCK OAN chính project dogfood; +1 fixture header kiểu ForFish.
- **`ai-simple init` cài phần NÃO**: junction 4 skill vào `.claude/skills/` (junction, KHÔNG copy — bài học #08/#10). **doctor +3 check design** (junction skill / design-verify self-test / repo có UI mà thiếu design-spec), trước đó 0/10 check chạm lớp design.
- **ui-design-logic tách 3 mức chính sách** `[INV]`/`[DEF]`/`[STACK]` — hết trộn invariant usability với gu với stack convention. Luật FONT hạ `[DEF]`: bỏ danh sách đen 3 font toàn cục (gu 1 user hard-code thành luật là sai kiến trúc — ForFish chọn đúng font bị cấm vì lý do audience đọc được); cơ chế thay thế = `## Ngoại lệ đã duyệt` (lý do audience/kỹ thuật, cấm lý do "gu") + `## Anti-references` cấp project trong template DESIGN-SPEC. Trọng số 0–3 hạ khỏi quy tắc cứng thành công cụ tư duy (01 §1b; bảng ví dụ của chính nó từng vi phạm trần W3 của chính nó).
- **Dọn 9 mâu thuẫn nội tại ui-design-logic**: metric card về 1 nhà (02 §1, tối đa 4/màn M — 03 và kim tự tháp trỏ về); kim tự tháp dashboard khớp budget M ≤6 khối; tỷ lệ 2–3× chỉ cho hero KPI (metric phụ ≥1,5×); bottom tabs 05 §2 = 4+Menu (tổng ≤5, hết phá M3); tách thang spacing vs sizing + grep 07 §5 scope prefix spacing (cấm blanket px); gate 50 + gradient/hero-3-card có mục THẬT trong 06 §2 (trước đây 2 file trỏ vào checklist không tồn tại); density L hero ≥50% chỉ landing/onboarding; thuật toán hoà màu logo phải ĐO ≥4.5:1 (hue ấm L 32–40% — công thức cũ cho accent trượt chính gate BLOCK của skill); toast Undo 5s; +categorical palette cho chart (04 §1 — 02 §22 bắt hue-danh-mục mà không có nguồn màu).
- **`ui-lane.sh` (skill ui-design-logic)**: cost-router dạng SCRIPT xuất 1 token (NOUI/LANE1/LANE2/LANE3) từ diff staged, luật tất định, `--self-test` 10 case, vào gate `npm test` (discovery mở rộng `-(verify|lane).sh`); context-router template thêm bảng route theo lane — hết load 8 reference cho task sửa button.
- **RE-APPLY**: chạy `ai-simple init` lại 1 lần để tạo junction 4 skill vào `.claude/skills/` (update chỉ thay hook/script, không tạo junction); repo có UI thì khai `type-ramp:` trong design-system doc để gate text-size bật.
- **ForFish (project tiêu thụ)**: bật `core.hooksPath`; hook lên 1.8.0 giữ nguyên custom (spacing-px, encoding guard, contract); junction 4 skill; chốt `type-ramp:` 6 bậc (phủ 87% — 800/919 lượt đo thật, nợ đuôi ~119 ghi trong 03 §3 kèm luật cấm nới ramp); dọn drift font Be-Vietnam-Pro trong 07-design-spec; 3 khối token lift về 03-design-system (07 chỉ trỏ). Tiêu chí dừng của hội đồng ghi ở CHANGELOG này: ramp nới >2 bậc sprint đầu = rút lui; >10 waiver/sprint = rút lui.

## v1.7.0 — 2026-08-13 (Bộ chấm điểm SẢN PHẨM — 5 GATE máy: self-test hợp nhất, stranger-path E2E, ship-gate, dogfood, CI 2 OS)

Thiết kế qua hội đồng team-agent (3 đề xuất triết lý chấm ĐỘC LẬP → 6 phản biện theo 4 trục hiệu-quả/đơn-giản/trực-tiếp/không-đi-vòng → judge → synthesize → Red-Skeptic). Winner **machine-first** (31.5 vs adoption 29 vs outcome 27.5). Nguyên tắc chốt: **điểm = số GATE máy đang xanh, không trọng số không /100** — danh sách gate đỏ CHÍNH LÀ "sửa gì trước"; điểm LLM không bao giờ vào mẫu số. Khác `/audit` (chấm project áp dụng) — bộ này chấm CHÍNH SẢN PHẨM. Tài liệu: `docs/scoring.md`. Bản này IMPLEMENT 5/5 gate (A1/A2 ADVISORY để sau):

- **G1 — Self-test hợp nhất** (`bin/ai-simple.js` cmdSelfTest): trước chỉ 1/4 skill-verifier được nối vào `npm test` (ba/design/triage-verify PASS nhưng **mồ côi** → rot âm thầm). Giờ **auto-discover mọi `skills/*/*-verify.sh`** và chạy hết → `npm test` từ 5 lên 8 check. (Đề xuất tối ưu #1 của council — rẻ nhất, làm trước.)
- **G2 — Stranger-path E2E** (`scripts/stranger-path.js`, ~150 dòng, 11/11 promises): đi TRỌN đường người-lạ — `npm pack` → cài tarball vào thư mục cô lập → CLI sống (`--version` + `parallel` load `lib/` = class bug v1.4.1) → `init` → `doctor` exit 0 → **First-win đổi-code-quên-doc BỊ CHẶN** (B1) → **PRECISION: 10 commit sạch đa dạng KHÔNG chặn oan** (failure mode giết sản phẩm: hook khắt → user tắt hook) → secret/injection chặn → **update GIỮ CONFIG người dùng sửa**. Chạy từ TARBALL đã cài, không từ repo checkout (E2E từ PKG_ROOT không bao giờ thấy lỗi đóng gói). (Bug harness bắt lúc build: `git` chạy `shell:true` trên Windows làm commit-message tiếng Việt bị split thành pathspec → git lỗi TRƯỚC hook; fix bằng shell chỉ cho npm.)
- **G3 — Ship-gate** (`scripts/ship-gate.js`, gắn `prepublishOnly`): THUẦN STATIC trên `npm pack --dry-run --json` — mọi `require()` trong bin/lib có trong tarball, mọi template bin tham chiếu có trong tarball, mọi link tương đối README/SKILL trỏ file tồn tại cả trên disk lẫn trong tarball. Chặn 2 class bug đã xảy ra (v1.4.1 thiếu `lib/`, dangling pointer v1.5.0 W4 + v1.6.0 m7). Đã kiểm cắn thật: bỏ `lib` khỏi files → FAIL; link chết → FAIL.
- **G4 — Docs-lint + Dogfood** (`scripts/dogfood-gate.js`): repo NGUỒN giờ tự dùng hook của chính mình — cài `.githooks/pre-commit` + `git config core.hooksPath .githooks` (trước đó = 0, "dạy dogfood mà không tự dùng"). Gate kiểm: hook tồn tại + **đồng bộ template** (bỏ version-stamp; chặn drift kiểu hook lạc pre-1.4 v1.5.0 W1) + docs sống không over-claim "đã bảo mật ✓" ngoài ngữ cảnh cấm. (doctor-on-self KHÔNG dùng: doctor kiểm layout project-tiêu-thụ, repo nguồn không có/không nên có.) **Dogfood lộ ngay 1 self-block** (đúng giá trị dogfood): ví dụ `token = "modal-open-overlay-x"` trong methodology/14 khớp secret-literal → sửa thành `<n>` để gate nhận là placeholder.
- **G5 — CI matrix 2 OS** (`.github/workflows/gates.yml`): G1–G4 + G2 chạy trên ubuntu-latest + windows-latest mỗi push (W1 v1.5.0 là bug chỉ-Windows). Timing hook chỉ ĐO-VÀ-GHI advisory, không assert (CI runner dao động). Repo lần đầu có `.github/`.
- **package.json scripts**: `ship-gate`/`dogfood-gate`/`stranger-path`/`gates` (=test+ship+dogfood) + `prepublishOnly` (=gates+stranger-path — npm tự chặn publish khi gate đỏ). Script gate là dev-only, KHÔNG vào tarball (đã xác nhận qua `npm pack --dry-run`).
- **identity-numbers guard tự chứng minh giá trị**: trong lúc build, một negative-test `git checkout README.md` (README chưa commit) đã revert TOÀN BỘ edit session → guard bắt ngay ("13 nguyên tắc còn trong README") → khôi phục đủ 8 edit. Đúng loại drift guard sinh ra để chặn.

## v1.6.0 — 2026-08-12 (Lớp Security — nguyên tắc 14 + skill security-logic, cổng máy chạy thật)

Vấn đề thứ 7: hệ "AI đọc docs rồi viết code" tạo/khuếch đại 3 lớp rủi ro bảo mật (lỗ hổng trong code AI viết · docs độc tiêm lệnh vào AI = prompt-injection · CVE từ thư viện), và cám dỗ dán "đã bảo mật ✓" tạo cảm giác an toàn giả — chính nó là lỗ hổng. Bản này thêm **lớp Security** với thiết kế trung thực "declared coverage" thay vì tick trần:

- **NEW `methodology/14-security-gate.md`** — nguyên tắc "bảo mật là cổng có KHAI BÁO phủ sóng": 3 vùng A (git-time, ENFORCED) / B (CI-time, point-to-tool) / C (production=NON-GOAL, chỉ sinh runbook). Mọi finding map **OWASP LLM Top-10 (2025) + OWASP Top-10 web (2021) ngang hàng** (LLM01 Prompt Injection = "lỗi do md", hạng số 1 vì docs là input trực tiếp vào AI). Bảng Enforced-vs-Advisory + Non-goals nói thẳng "KHÔNG thay pentest".
- **NEW skill `security-logic`** (`skills/security-logic/SKILL.md` + `security-verify.sh`) — phần "não": pipeline 6 bước, roster team-agent (Injection-Hunter / Secret-&-Crypto / Access-&-Agency / Deps-&-Supply / **Red-Skeptic** chống over-claim), defer risk-tier về NT06 (KHÔNG chế tier mới). `security-verify.sh` (anh em ba-verify) BLOCK security-review thiếu declared-coverage / thiếu map OWASP / thiếu contract "pentest"; WARN over-claim; có `--self-test` (7/7 PASS, gồm case LLM10/A10 phải qua).
- **Cổng MÁY vào `pre-commit.hook.template` mục 1e (`SEC_CHECKS=auto`)** — chạy thật, có fixture self-test (qua `npm test`):
  - **secret-scan**: private key / `AKIA…` / `ghp_` / `github_pat_` / Slack `xox…` / secret-literal ≥16 ký tự vào biến secret-ish → BLOCK (đo độ dài, KHÔNG đo entropy); loại placeholder (`your-`, `xxx`, `example`, `process.env`, `<…>`, `{{…}}`…) để không chặn oan. (Bug bắt trong lúc build: pattern secret bắt đầu bằng `-----BEGIN` khiến `grep` hiểu nhầm là option → sửa bằng `grep -E -e`; nếu không, "pass" là false-pass do grep lỗi.)
  - **doc prompt-injection lint**: chỉ quét `docs/app-map/**` + `CLAUDE.md` (docs được ROUTE = input trực tiếp vào AI) tìm câu mệnh-lệnh-hướng-agent ("ignore all previous instructions…", "send secret token to…", biến thể VI) → BLOCK (LLM01); persona-override / system-prompt / encoded blob → WARN. Nguyên tắc: **docs untrusted-by-default — doc MÔ TẢ, không RA LỆNH cho agent.**
  - **A3 advisory**: staged chạm path nhạy cảm (auth/payment/crypto/migration/.env qua `SEC_SENSITIVE_PATHS`) mà không kèm security-review → WARN (nhắc tier RED NT06).
  - 3 fixture mới trong hook `--self-test`: chặn secret AKIA · cho qua placeholder (không false-positive) · chặn doc injection — tất cả PASS trên Windows Git Bash, `npm test` xanh.
- **NEW `templates/security-review.md.template`** — review doc có frontmatter `declared-coverage:` + bảng 3 vùng + bảng findings (rủi ro cụ thể + tier + gate + mã OWASP) + mục "Ngoài phạm vi" (KHÔNG pentest) — cổng `security-verify.sh` lint được.
- **`doc-health.workflow.yml.template`** — thêm step **SCA dependency audit** (`npm audit --audit-level=high`, advisory `continue-on-error`; point-to-tool, bỏ qua nếu không phải npm) = vùng B của NT14.
- **Wiring**: SKILL.md (profile `security`, NT14 vào danh sách 14 nguyên tắc / 6 lớp, routing pointer); methodology/README (index 14, layer Security, scale-up trigger, template, anti-pattern); README (lớp Security VI+EN, "Cài 5 skill", repo structure, bảng routing); package.json 1.5.0 → 1.6.0.

Phần này qua hội đồng team-agent review 4 vòng (rubric 9 tiêu chí → chấm → fix → chấm lại: 77 → 82 → 90 → **99/100 ĐẠT ngưỡng 99**; reviewer cuối chấm bằng máy — craft payload commit thật, E2E First-win, đối chiếu Enforced-vs-Advisory từng hàng) + 1 vòng Fable 5 review tổng thể toàn repo (66/100, tìm ra B1/B2 ngoài phần security) — amendments bên dưới. Sau amendments: `npm test` = 5 PASS (hook 21 fixture / report / security-verify / identity-numbers / cross-cut).

**Amendment (hội đồng review vòng 2 — sửa honesty + false-positive, tất cả chạy máy thật):**
- **Sửa over-claim ENFORCED** (methodology/14 bảng Enforced-vs-Advisory): `security-verify.sh` KHÔNG wire sẵn trong hook shipped → hạ nhãn `✅ ENFORCED` xuống `⚠️ ADVISORY → user-must-wire` (đồng bộ pattern ba/triage/design-verify, đều user-wire). Trung thực: badge ENFORCED chỉ dành cho secret-scan + doc-injection (thật sự auto-chạy mục 1e).
- **Fix regex OWASP bỏ sót mã 2 chữ số** (`security-verify.sh`): `LLM0[0-9]|A0[0-9]` → `LLM(0[0-9]|10)|A(0[0-9]|10)` — trước đó review chỉ gắn **LLM10 (Unbounded Consumption) / A10 (SSRF)** bị BLOCK OAN dù đó là mã canonical methodology/14 hàng 10 map tới. Thêm self-test case #6 (review chỉ LLM10/A10 phải QUA).
- **Fix false-positive doc-injection** (`pre-commit.hook.template` 1e): doc-injection lint chặn oan `*security-review*.md` (review LLM01 tất phải trích payload làm ví dụ) → **miễn trừ `*security-review*.md`** khỏi INJECT_BLOCK; khai giới hạn false-positive vào methodology/14 §Non-goals; thêm fixture "security-review mô tả injection phải QUA".
- **Bịt gap secret-scan `.md`** (1e): thêm `md` vào danh sách đuôi quét secret (docs là first-class input — secret dán vào `.md` rất thường gặp mà trước đó LỌT); thêm fixture "AWS key trong README.md → BLOCK".
- **Chống fixture-rot âm thầm**: `security-verify.sh --self-test` giờ chạy trong `npm test` (qua `bin/ai-simple.js self-test`) — cùng chỗ canh với hook fixture, đổi regex mà làm thối fixture thì `npm test` bắt được.

**Amendment (hội đồng review vòng 3 — bịt lỗ né-theo-tên + coverage secret, tất cả kiểm bằng tay + fixture):**
- **BLOCKER — bỏ miễn-trừ-theo-tên của doc-injection lint** (`pre-commit.hook.template` 1e): miễn trừ `*security-review*.md` (vòng 2) tạo **lỗ né không khai báo cho chính cổng độc nhất của hệ** — kẻ tấn công đặt tên `orders-security-review.md` rồi cài câu lệnh trần thì LỌT vào app-map (kịch bản §2). Thay bằng lint **fence/blockquote-aware**: chỉ soi DÒNG TRẦN (ngoài code-fence ` ``` ` và không phải blockquote `>`); payload trích làm ví dụ phải fence/blockquote thì được miễn — áp dụng cho MỌI doc (kể cả security-review). Vừa vá lỗ né-theo-tên, vừa hết chặn-oan doc *mô tả* injection (không còn phải `SEC_CHECKS=off` làm mù cả secret-scan). Fixture: (a) payload trần trong doc tên `*security-review*` → **BLOCK**; (b) cùng payload đã fence/blockquote → QUA. methodology/14 §A2 + §Non-goals viết lại theo contract mới.
- **Bịt gap secret-scan bỏ sót prefix high-confidence phổ biến** (1e `SECRET_PAT`): thêm Google API key `AIza[0-9A-Za-z_-]{35}`, Stripe `sk_(live|test)_`/`rk_live_`, GitLab `glpat-`, OpenAI `sk-` — trước đó `const k="AIzaSy…"`/`"sk_live_…"` với biến không tên secret-ish LỌT vì chỉ dựa AKIA/ghp_/xox/private-key. Fixture "Google AIza key trong var thường → BLOCK"; methodology/14 §A1 liệt kê đủ vendor.
- **Fix WARN over-claim bắn nhầm dòng CẤM** (`security-verify.sh`): bộ dò `✓ + bảo-mật` WARN oan chính dòng "LUẬT VÀNG: KHÔNG 'đã bảo mật ✓'" (mệnh lệnh cấm, không phải tuyên bố). Loại ngữ cảnh phủ định (`khong/không/cấm/never/đừng/luật vàng`) khỏi nhánh (a); nhánh (b) vẫn bắt "không có lỗ hổng" (đó LÀ over-claim). Self-test case #7 (dòng phủ định luật vàng KHÔNG bị WARN oan).

**Amendment (vòng 4 — hợp nhất 4 finding cuối của hội đồng NT14 + review tổng thể toàn repo bằng Fable 5, tất cả kiểm bằng máy):**

*Từ hội đồng NT14 (3 vòng: 77→82→90, cả 3 lăng kính tự tay phá gate):*
- **Fix false-positive T3** (1e): tách nhánh exfil-verb — `exfiltrat/leak/curl/upload` + secret-object vẫn BLOCK vô điều kiện; `send/post/fetch/email/transmit` chuyển sang **nhánh mềm chỉ BLOCK khi cùng dòng có sink khả nghi** (`http`/`://`/`webhook`/`attacker`/`evil`/`copy of`). Trước đó prose mô tả hợp lệ "The payment handler will send the auth token to the Stripe provider" bị BLOCK oan — đúng docs auth/payment mà security-review sống, đẩy user sang `SEC_CHECKS=off` làm mù cả secret-scan. 2 fixture mới: prose send-token hợp lệ → QUA · send-token + sink → BLOCK.
- **Gỡ over-claim "entropy"** (methodology/14 ×3 chỗ + CHANGELOG): máy chỉ đo **ĐỘ DÀI ≥16 + charset, KHÔNG đo entropy** — doc giờ nói thật, kèm khai chặn-oan (biến `token` gán tên-lớp-CSS dài kiểu `"modal-open-overlay-<n>"`) và bỏ-sót (secret không prefix + biến trung tính → cần SCA/gitleaks ở CI).
- **Khai thẳng fence/blockquote exemption là đường né đã-biết** (§Non-goals): bọc payload trong `>`/``` là né được lint nhưng AI đọc raw .md vẫn ingest — lint chỉ chặn injection ngây thơ/trần; attacker có chủ đích → phòng tuyến là docs-untrusted-by-default + review người.

*Từ Fable 5 review tổng thể toàn repo (66/100, 2 BLOCKER + 4 MAJOR + 9 minor — mọi finding có bằng chứng chạy):*
- **B1/M4 — vá false-pass hệ thống của CỔNG GHI**: cổng covers (1b) trước đó tính MỌI diff doc là "đã sửa", kể cả dòng `DOC-STATUS` do chính hook ghi ở bước 5 → user quen tay `git add -A` là lọt cổng không cần đối chiếu; demo "First win" của README fail khi làm theo từng chữ (commit 2 KHÔNG bị chặn — Fable E2E chứng minh). Fix: diff chỉ-gồm-dòng-DOC-STATUS **không được tính là sửa doc** (`git diff --cached -U0 | grep -v DOC-STATUS`). 2 fixture mới (marker-only → BLOCK · sửa thật → qua) + E2E First-win tái chạy: commit 2 exit=1 ✓.
- **B2 — profile `security` vào CLI**: SKILL.md quảng cáo 9 profile nhưng `PROFILES` chỉ nhận 8 → `init --profile security` chết. Thêm vào PROFILES + HELP; `init` cài thêm `security-review.md.template` vào `docs/_templates/`.
- **M1 — SKILL.md frontmatter description** (bề mặt trigger routing) còn "13 composable principles in 5 layers" → 14/6 + thêm trigger security VI/EN + nhắc declared-coverage gate.
- **M2 — `/audit` mù NT14**: audit.command.md.template thêm hàng 14 (SEC_CHECKS bật? fixture xanh? declared-coverage? SCA? đếm WARN path nhạy cảm bị bỏ qua? tìm over-claim) + description "14 nguyên tắc".
- **Sweep drift số bản sắc** (~8 chỗ): "13 nguyên tắc/principles" → 14 (README ×3, methodology/README); "hệ 4-skill" → 5-skill + dòng *security-logic cắt ngang* trong sơ đồ §0 (ba-flow-logic, ui-ux-triage, ref 07); BA khai đường **nhận** handoff từ security (AC cho phép hành vi không an toàn → sửa AC); triage khai đường **đẩy** sang security (defect mùi an toàn); profile list methodology/README đủ 9; CHANGELOG header thêm lớp Security; ADR-001 thêm status note "số trong thân là lịch sử".
- **m7 — tarball**: `docs/walkthroughs` vào `files` package.json (README trong tarball hết link chết — đúng class bug v1.5.0 W4).
- **NEW identity-numbers guard trong `npm test`** (đề xuất chiến lược #3 của Fable): grep các số bản sắc cũ (13 nguyên tắc / 5 lớp / 4-skill…) trên docs SỐNG (README/SKILL/methodology-README/skills; CHANGELOG+ADR là lịch sử được miễn) → FAIL khi drift. Diệt vĩnh viễn loại finding chiếm nửa bảng review này.

## v1.5.0 — 2026-08-04 (sửa theo hội đồng thẩm định 5 reviewer — npm test xanh trên Windows, UI gate thành máy, đóng vòng design, onboarding có đường đi)

Hội đồng 5 reviewer (lớp máy 6.5 / doc-drift 8.5 / ui-design-logic 6.5 / pipeline 7 / onboarding 4 — tất cả chạy máy thật, không đọc suông) tìm 4 CRITICAL + loạt MAJOR. Bản này sửa theo 5 wave:

- **W1 — Lớp máy**: fix bug path Windows `case "$SELF" in /*)` không match `C:\` ở pre-commit.hook.template + doc-health-report.sh.template → **`npm test` xanh lại tại HEAD trên Windows** (trước đó FAIL 4 sub-test khi gọi bằng absolute path). Xóa bản hook drift pre-1.4 nằm lạc trong `skills/ui-design-logic/.githooks/`. HELP thêm lệnh `self-test`. (Claim "bug bin:285 backslash" của reviewer onboarding được kiểm chứng là SAI — code dùng forward slash.)
- **W1b — UI anti-slop gate thành MÁY THẬT**: `pre-commit.hook.template` thêm mục 1d `UI_CHECKS=auto` (auto-bật khi repo có tailwind.config/globals.css): màu hard-code `-[#...]` → BLOCK (Hallmark gate 48); `font-family` ngoài globals/tokens + `overflow-x: hidden` → WARN (gate 34); kèm 2 fixture trong hook self-test (chặn màu hex, cho qua màu token). Description ui-design-logic "blocked at pre-commit" giờ là sự thật, hết lời hứa suông; 07 §5 + 08 §4 trỏ về template làm nguồn sự thật; `1fr` trần (gate 50) chuyển sang check bằng mắt trong 06 §2 — grep không phân biệt được grid-có-ảnh.
- **W2 — template ↔ cổng ↔ contract**: template DESIGN-SPEC (01 §7) thêm 4 dòng frontmatter bắt buộc (hết cảnh agent làm đúng template bị design-verify.sh chặn oan — fixture self-test trước đó khớp script chứ không khớp template) + cột `Type` (`product` | `marketing-public`) wire cơ chế phân loại của contract 08 vào chỗ khai được + ghi chú vị trí root-vs-app-map; design-verify.sh thêm WARN "có màn marketing-public mà thiếu Visual fingerprint" (self-test 9/9). Hợp nhất rule empty-state về 1 câu chuẩn ở 03 §4 (hết 3 phiên bản đá nhau). Chốt viewport: ma trận 375 + spot-check 320, fail ở 320 = MAJOR (06/03/05 cùng một đáp án). Bảng route 08 hàng Redesign hết chỉ nhầm sang triage. Description ui-design-logic thêm trigger tiếng Việt + mục KHÔNG-kích-hoạt (vá 3 ca double-trigger với triage/BA).
- **W3 — đóng vòng pipeline nhánh design**: triage §5 4c tách 2 đích — sai HÀNH VI → BA, sai GIAO DIỆN tại design-spec → **ui-design-logic** (trước đó ca này là hố đen: chỉ có đường về BA mà BA bị cấm đụng UI); định nghĩa format payload `HANDOFF | to= | spec= | ca= | bằng-chứng= | đề-xuất=` ghi vào triage-log, ba ref 04 nhận đúng format. Chốt chủ quyền TEXT một chỗ: copy UI = design-spec, thuật ngữ nghiệp vụ = ba-spec (hết 3 file 3 phán quyết). BA khai đường nhận thứ 2 từ ui-design-logic (06 §3 case C — spec thiếu hành vi phát hiện lúc design, trước khi có code). Gỡ route sang skill "uiux"/"test-runner" không tồn tại trong repo.
- **W4 — onboarding + npm**: README thêm npm badge; cảnh báo 404 + lệnh thay thế (`npx github:...` / clone+node) ngay đầu Quick start; mục mới **"Cài 4 skill vào Claude Code"** (symlink/junction — trước đó repo là bộ skill mà zero hướng dẫn cài skill); mục **"First win — thấy hook chặn thật trong 2 phút"** (tạo doc có covers → đổi code quên doc → BLOCK); ghi chú thời gian init trên Windows. package.json: `files` thêm `skills/` + `docs/adr` (hết dangling pointer trong tarball), thêm homepage/bugs/keywords. Claim hiệu năng "≤500ms" sửa thành số đo thật (POSIX target; Windows ~3s, hướng tối ưu ghi rõ) ở SKILL.md + methodology/08.
- **W5 — vệ sinh + tài liệu**: NEW `docs/walkthroughs/parallel-sessions.md` — đi tay 2 session/3 lot từ plan→claim→merge→recover (feature khác biệt nhất giờ có đường đi thật); evals ui-design-logic tạo fixture `dashboard.tsx` còn thiếu + 2 eval mới cover rule v1.4 (font-ban/chữ-AI; redesign admin 4-case + cấm Hallmark vào admin); sửa junction path chết trỏ repo standalone cũ trong triage ref 07; profile `full` có mặt trong bảng §Bước 0; mục lục README + methodology thêm `CLAUDE.tiny.md.template` thiếu; "cả 7 file" → 8 file trong routing 07 §2.

## v1.4.1 — 2026-08-04 (npm publish blocker + redesign 4-case + zero-command routing)

Hai đề xuất mới (Redesign mode riêng + "Principle 14 Intent Router") qua hội đồng 2 reviewer: cùng 3/10 — ~70% tái phát minh cái đã có (06 §3, bảng route 08, triage handoff, description-routing native của Claude Code), router agent trung tâm chạy-trước-mọi-message là cơ chế không tồn tại trên platform, mode "incident/sentry-fix" trong bảng intent là bịa, và cả hai tái xuất thư mục `commands/` đã bác từ v1.4.0. Chỉ ship phần lõi sống sót (~45 dòng docs, 0 nguyên tắc mới, 0 command mới):

- **FIX npm publish blocker**: `package.json` mục `files` thiếu `lib/` → tarball publish sẽ thiếu `lib/parallel.js`, lệnh `ai-simple parallel` chết ngay khi cài từ npm. Đã thêm + xác nhận `npm pack --dry-run` (38 file, có lib) + `parallel self-test` 42 PASS. Package `ai-simple` trên npm hiện còn trống — chưa publish.
- **ui-design-logic 06 §3 — phân loại 4-case trước khi sửa UI "xấu"**: (A) nghiệp vụ đúng, giao diện rối → chạy ngược checklist; (B) nhìn AI/slop → gate anti-slop/contract 08; (C) "xấu" vì thiếu hành vi → KHÔNG sửa UI, handoff BA; (D) app lỗi chức năng → ui-ux-triage. Kèm **guardrail redesign**: đổi HOW nhìn giữ WHAT chạy — không tự đổi AC/permission/flow/dữ liệu; token toàn cục/nav giữa chừng vẫn RED theo 07 §4; đổi wording = sync ba-spec cùng commit.
- **Bảng route 08 §1 thêm hàng handoff BA** — vá lỗ bảng route không có đường về BA khi "xấu" hoá ra là spec sai/thiếu.
- **Zero-command routing (docs, không cơ chế mới)**: mục Routing SKILL.md root thành bảng pointer triệu chứng→đích (thêm 2 route thiếu: sự cố production → NT11 runbook-trước-code; "UI nhìn như AI" → 06 §3); description root thêm trigger tiếng Việt tự nhiên; README thêm mục "Không cần nhớ lệnh / You don't need to remember commands" (bảng câu nói → skill, song ngữ); CLAUDE.md.template thêm 2 dòng "skill tự kích hoạt, không hỏi user chọn".

## v1.4.0 — 2026-08-04 (ui-design-logic: anti-slop layer + contract Hallmark — qua hội đồng 3 reviewer)

Đề xuất ban đầu (fork nội dung Hallmark thành 4 references + 4 command) bị hội đồng 3 reviewer độc lập chấm 4/3/3 trên 10 — finding hội tụ: theme catalog chứa font bị cấm đích danh (Hum = Plus Jakarta Sans), diversification rule nghịch triết lý nhất quán của admin app (chính Hallmark tự đảo rule khi có design.md — DESIGN-SPEC chính là design.md), fork-tóm-tắt dựng lại monolith Hallmark v1.1 vừa refactor bỏ, và claim "Hallmark build trước hỏi sau" sai 180° so với nguồn. Bản ship theo kiến trúc thay thế của hội đồng — contract thay vì copy (đúng nguyên tắc 10):

- **NEW `ui-design-logic/references/08-integration-hallmark.md`** — contract 4 mục với skill Hallmark (cài riêng `npx skills add nutlope/hallmark`, không fork nội dung): bảng ROUTE (admin/internal → ui-design-logic 100%, Hallmark cấm đụng; landing/marketing khai `type: marketing-public` trong screen map → Hallmark lo visual giữa bước 3 và 6); PRECEDENCE (system font stack + lệnh cấm font + shadcn lock + 1 accent + hoà màu logo THẮNG theme catalog — theme nhập kiểu palette-only; diversification TẮT vì DESIGN-SPEC đóng vai design.md; 3-question gate của Hallmark im lặng khi có ba-spec/DESIGN-SPEC; đổi token toàn cục vẫn là RED theo 07 §4); HANDOFF (output Hallmark ghi ngược vào DESIGN-SPEC mục Visual Fingerprint — oracle duy nhất cho triage, token lift vào globals.css cùng commit); danh mục gate đã cherry-pick kèm số gate nguồn.
- **Checklist 06 §2 nhập 5 gate anti-slop phổ quát** (ghi nguồn Hallmark gate): scroll ngang mobile kể cả 320px (34) + metric/testimonial bịa (46) vào BLOCK; clickable text wrap 2 dòng (49), fake browser/phone/code chrome (47), heading italic (38a) vào MAJOR. Screenshot loop thêm **spot-check 320×568** (soi 3 lỗi chỉ lộ ở bề rộng hẹp nhất — không nhân đôi ma trận 3 viewport).
- **07 §5 thêm 4 pattern grep anti-slop máy-check** cho pre-commit hook của project: màu hard-code `-[#...]` ngoài token → BLOCK (gate 48); `font-family:` trong component ngoài token block → WARN; `overflow-x: hidden` ở html/body → WARN (dùng `clip`); `1fr` trần cho grid ảnh → WARN (`minmax(0,1fr)`, gate 50). Đúng charter: design-verify.sh KHÔNG đổi (lint spec), lint code sống ở hook.
- **Fix bug 04 §3**: gợi ý font còn sót "Be Vietnam Pro" mâu thuẫn lệnh cấm trong SKILL.md → thay bằng system font stack, cấm đích danh 3 font, font riêng (kể cả Inter) chỉ khi user yêu cầu rõ.
- **SKILL.md ui-design-logic**: 3 quy tắc cứng mới từ sản phẩm thật (system font stack + cấm chữ giải thích kiểu AI trên UI + IA theo đối tượng/bộ phận), rule đồng bộ HÌNH DẠNG label nhóm ngang hàng (03 §4 quy trình budget-trước-chọn-từ-sau + checklist 06), trigger + description nhận diện "UI nhìn như AI", mục lục thêm ref 08.

## v1.3.1 — 2026-07-28 (hardening vòng 2+3 theo hội đồng tái chấm — 42 test nghiệm thu)

Hội đồng 3 reviewer tái chấm v1.3.0 (67/77/82 trên 100) và tìm ra 1 CRITICAL bằng thí nghiệm thật: **2 merge đồng thời làm mất lot khỏi integration 8/8 lần** (rebase→ff chạy ngoài lock, `branch -f` đè nhau, cả hai báo OK). Fix + toàn bộ MAJOR:

- **C1 — merge queue TUẦN TỰ bằng máy**: merge-lock per-run (mkdir, stale 15 phút) giữ suốt `cmdMerge` + bước ff chuyển sang **CAS `git update-ref <ref> <new> <expected-old>`** (compare-and-swap của git — hai bên không thể cùng thắng); thua CAS/ancestry → **eject về READY có báo** (branch đã rebase, head cập nhật, chạy lại merge là tiếp); tạo integration branch idempotent. Test mới: 4 vòng concurrent-merge — không silent-loss, integration đủ lot sau retry.
- **M1 — FAIL-CLOSED claim hỏng**: JSON không parse được → chặn mọi claim/status (trước đây bị filter im lặng = claim tàng hình); dọn qua `release --force` sau khi người xác minh.
- **M2 — run-lease sống theo hoạt động**: renew/extend/ready/merge đều bump; STALE ≠ tự lấy — run khác takeover cần `--force-run` SAU recover.
- **M3 — path space/quote/control bị reject tại CLI** (normPath) — non-goal được enforce thay vì lời hứa; hook comment sửa lại cho đúng.
- **M5 — registry lock release kiểm owner** (victim bị cướp lock không xóa nhầm lock người khác); NFC normalize + unquote octal porcelain (tên file tiếng Việt); `git worktree prune` tự động ở ready/merge/recover; doctor quét journal mồ côi.
- **Race test nâng lên 100 lượt** (20 vòng × 5 process concurrent — khớp điều kiện nghiệm thu ADR §13). Sau vòng 2: 40 test; sau vòng 3 (dưới): **42 test, 0 FAIL**.
- **Pragmatics**: doctor nhận diện profile tiny (hết cảnh repo tiny lành mạnh bị phán "FAIL 5 mục") + in trigger scale-up; `init --profile` nhận đủ 8 tên (SKILL.md ghi rõ mapping bộ file); **`CLAUDE.tiny.md.template` mới** — tiny không còn nhận CLAUDE.md đầy tham chiếu ma; cổng conflict chuyển về MAIN agent chạy `parallel status --check` (router chỉ có Read/Glob/Grep — spec cũ bất khả thi); doc 13 thêm walkthrough 2-session end-to-end + bảng Enforced vs Advisory đối chiếu lại từng dòng với code; README hết drift (SPEC→shipped, CLI hết "đang cân nhắc", quick start có `parallel`).
- **Learning (12 v3)**: N định nghĩa = 5 session/14 ngày; survival/correction có LỆNH đo trong audit row 12 + spot-check 3 event chống SHA bịa; `/learn` thêm bước verify `git cat-file -e` + dán `git diff --name-only`; aggregation events per-lot có chủ ([ACTIVE thủ công] trong end-of-run checklist); residue ladder cũ dọn sạch; đặc cách security cần rủi ro cụ thể + strong-accepted; hòa giải scope-vs-evidence; survival sau release chỉ giữ/rollback.
- **Vòng 3 (hội đồng tái chấm lần 2: 90/91/93)**: merge-lock có owner-check khi release + heartbeat `touchMergeLock()` qua rebase/test dài (serialization không rơi sau phút 15); EEXIST tử tế ở nhánh stale-takeover; bump run-lease vào trong withLock; dọn tmp dir ở mọi đường fail của merge; **doctor chống false-PASS tiny** (repo có dấu vết core mà mất `.githooks` → FAIL "hook đang không chạy im lặng", không được nhận nhầm là tiny); **REMAP SHA khi gom learning events cấp run** (lot branch bị rebase → `accepted_sha` per-lot thành orphan; gom = ghi integration SHA, giữ `lot_sha_pre_rebase`, audit không false-positive "SHA ma"); vá lỗ "repo im ắng" (survival cần ≥ 2 session hoạt động trong cửa sổ N); sweep số test hard-code khỏi docs (con số sống ở CHANGELOG — hiện hành: **42 test**, thêm assert bên-thua-CAS giữ claim READY + test merge-lock stale takeover 16 phút); ghi runtime self-test ~2–4 phút Windows.

## v1.3.0 — 2026-07-28 (Phase 2: NT13 chạy thật — CLI parallel + claim gate + 26 test nghiệm thu)

- **NEW: `lib/parallel.js` + `ai-simple parallel plan|claim|extend|renew|status|ready|merge|recover|release|self-test`** — toàn bộ cơ chế NT13 thành máy: claim JSON atomic trong `<GIT_COMMON_DIR>/ai-simple/` (mkdir lock + owner/epoch/stale 30s, write-temp-rename không đè + retry EPERM/EBUSY, casefold path trên win32/macOS), overlap block write/write + ancestor/child, PROTECTED từ `git status` + re-scan tại merge (R4), target-branch lease 1-run-1-target (R3), `extend` first-wins (R2), read/write → WARN + gợi ý depends_on (R5), `plan` = MECE test + topo-sort waves + admission, merge queue đúng Git-reality (READY tự nhả worktree, journal từng bước, ancestry check thay so-SHA, FAILED fail-eject, RESUME sau crash từ journal), recover checklist không-silent-takeover, release bảo vệ worktree dirty.
- **26 test nghiệm thu** (`parallel self-test`, sandbox temp repo): race atomic tuần tự + CONCURRENT đúng-1-thắng, crash giữa queue → resume, dirty-repo không mất dữ liệu, STALE vẫn chặn, target branch không bị đụng, integration nhận đủ 2 lot. Self-test bắt được 1 bug thật khi build: lock mồ côi do `process.exit` bỏ qua `finally` → fix bằng exit-handler.
- **Hook claim fast gate** (`CLAIMS_CHECK=auto` trong pre-commit template): staged path ∩ write_paths của claim thuộc branch khác → BLOCK tại commit-time (fencing cho lease) + 2 fixture self-test; chỉ chạy khi registry tồn tại — repo không parallel: 0 chi phí.
- **Doctor**: claims STALE/orphan/JSON-hỏng → WARN (guarded). **Init**: `--profile tiny` (chỉ CLAUDE.md — R19) + auto-detect repo < 10 file gợi ý tiny (R18).
- **NEW: `templates/learn.command.md.template`** (`/learn`) — cầu [ACTIVE] của NT12 v3 vòng B: dựng evidence chain từ git, filter defect-vs-preference, enum bằng chứng, promote 3 mức kèm last_verified + rollback condition.
- Doc 13 banner SPEC → OPERATIONAL; bảng Enforced vs Advisory cập nhật theo cái máy THẬT SỰ chặn.

## v1.2.0 — 2026-07-28 (vNext docs: 13 nguyên tắc, 5 lớp — Collaboration + Learning)

Docs-first release theo `docs/adr/001-vnext-git-native-parallel-self-evolving.md` (thiết kế qua hội đồng phản biện 3 reviewer, 19 amendments R1–R19). Cơ chế deterministic (CLI `parallel *`, claim gate trong hook, scripts learning) là roadmap Phase 2–5 — CHƯA ship trong bản này.

- **NEW: nguyên tắc 13 — Git-Native Parallel Sessions** (`methodology/13`, trạng thái SPEC có status banner): lot MECE theo business entity + DAG/waves, admission gate, claim JSON có lease trong `GIT_COMMON_DIR` (CLI-managed, contract cho Phase 2), worktree per lot, integration branch + merge queue viết đúng Git-reality (READY = nhả worktree, journal, ancestry check, FAILED/ABANDONED fail-eject), coordination states CLEAR/CONFLICT/STALE/PROTECTED tách khỏi RED, shared zones single-writer (lockfile = generated-at-integration), crash recovery, bảng Enforced vs Advisory, non-goals. Tầng 0 "bảo vệ repo hiện hữu" (cấm stash/reset đè, dirty work user = PROTECTED) áp dụng NGAY cả single-session.
- **Nguyên tắc 12 → v3** (3 vòng): giữ vòng A (coupling map); thêm vòng B học từ accepted diffs (evidence chain SHA, enum bằng chứng thay confidence số, acceptance có tầng — survival là vé promote, filter defect-vs-preference, chống echo-chamber, learned rule có last_verified/SUSPECT) + vòng C skill evolution (branch + regression + rollback; forward-test là CONTRACT Phase 5); metric = survival/correction rate đo từ git; nhãn ACTIVE vs CONTRACT từng bước; phối hợp NT12↔NT13 (worker không ghi global generated/telemetry); state taxonomy 6 loại.
- **Nguyên tắc 07 → v2**: hợp nhất vào vòng B làm fast-path `explicit-instruction` — một pipeline, một ladder, một nơi ghi; giữ format entry + lifecycle; explicit thắng inferred cùng scope.
- **Nguyên tắc 04**: phát biểu lại invariant — behavior↔test, documented-change↔doc (hợp thức hóa hook covers-based); deferred-doc-at-integration cho doc shared-zone trong parallel mode.
- **SKILL.md viết lại** theo progressive disclosure (~2K token): 7 profiles (thêm tiny), workflow 16 bước + đường tắt "Core + GREEN = 1→4→5→8→9→13", 13 nguyên tắc 1 dòng, hard safety rules, guard NT13 chống gọi CLI ma.
- **Audit đổi sang applicability**: bỏ điểm trần /120 → `earned/applicable_max × 100`, mỗi nguyên tắc APPLICABLE/NOT_APPLICABLE/DEFERRED; row 12 v3 + row 13.
- Router/fl template: thêm cổng conflict (NT13, chỉ hoạt động khi registry tồn tại, CLEAR = im lặng); 08 document fast/heavy gate split (p95 ≤ 500ms) + claim fast gate là hạng mục Phase 2 ưu tiên cao nhất.

## v1.1.0 — 2026-06-13 (npm CLI)

- **NEW: npm package `ai-simple`** — CLI zero-dependency đóng gói lớp máy: `init` (cài
  hook + doc-health + templates + workflow theo stack supabase/prisma/custom, set hooksPath,
  self-test), `doctor` (khám setup + phát hiện version drift qua marker `ai-simple-version`),
  `update` (nâng cấp giữ nguyên CONFIG người dùng, backup .bak), `doc-status`, `doc-health --ci`.
  Giải bài toán template-drift: N repo copy tay = N bản drift; CLI = 1 nguồn + 1 lệnh sync.
- Version marker trong hook + report để doctor/update so drift
- Fix tự bắt khi test CLI: `$'` trong chuỗi replacement của String.replace() nhân bản file
  (dùng replacer function); index của app-map README template đổi sang plain text (link hóa
  khi file tồn tại) + ví dụ cross-ref tự tham chiếu — repo mới init không còn fail CI oan
- LICENSE (MIT), package.json, `npm test` chạy self-test 2 template từ package

## v1.0.0 — 2026-06-13 (release đầu tiên)

Trạng thái: 12 nguyên tắc, 15 templates, 2 script tự test (report 12 fixtures + hook 6 fixtures), đạt 99/100 sau 11 vòng adversarial review + 2 vòng đối chiếu nghiên cứu khoa học.

### Optimization layer — nguyên tắc 12 v2 (các commit v4.0–v4.3)
- Coupling map: mỗi doc gắn code khai `covers:` / `last_verified:` / `ttl_days:` → trạng thái VERIFIED/SUSPECT/ORPHANED máy tính từ git
- Cổng GHI: hook chặn commit đổi code trong covers mà doc không được sửa/re-verify cùng commit
- Cổng ĐỌC: doc-status.md regenerate mỗi commit, router gắn cờ (fail-closed), marker trong chính doc, agent phải đối chiếu code trước khi tin doc SUSPECT
- Chống laundering: commit chore chạm doc không rửa được SUSPECT (attestation phải gate-1-shaped hoặc `re-verify(...)`)
- Symbol-level rot: doc nhắc hàm đã xóa → SUSPECT (tìm toàn repo, loại *.md) → CI fail
- Doc-lag + escaped-drift thay drift% (proxy gameable); hotspot = route-freq × covers-churn
- Ranh giới lời bảo đảm nêu tường minh trong 12 §gates — mọi residual có tên + audit check

### Ops layer — nguyên tắc 11 (v2.2–v3.0)
- Runbook per service, state registry, schedules + external-services registry (4/4 templates)
- Routing "sự cố → runbook trước code"; fix sự cố → update runbook cùng commit

### Scale layer — nguyên tắc 08–10 (v2–v2.1)
- Pre-commit hook versioned (.githooks + core.hooksPath), --self-test, encoding guard (BOM/mojibake)
- Generated vs authored docs (`_generated/`), cross-repo contract + bảng SYNC + path convention
- doc-health-report: --ci fail PR, --status sinh doc-status, --self-test, --fast

### Core layer — nguyên tắc 01–07 (v1–v3)
- Hierarchical context (root <6K tokens + root diet), app-map pattern (>20 file → domain hóa)
- Context routing /fl + context-router; LOGIC vs REQUEST
- Risk tiers GREEN/YELLOW/RED (06 v3): reversible tự làm + Assumptions cuối task, RED mới hỏi 1 câu gộp
- Doc+Test sync invariant; memory as feedback

### Bài học được mã hóa thành cơ chế (lịch sử lỗi → fixture)
- Hook hỏng vì `{{X|default}}` bị sh hiểu là pipe → --self-test pattern-exercise
- PowerShell 5.1 phá UTF-8 tiếng Việt (BOM khi ghi, ANSI khi đọc) 2 lần → encoding guard trong hook
- Multi-covers parser mù, same-day false SUSPECT, sibling-path overmatch → 12 fixtures
- SUSPECT laundering qua commit chore → attestation semantics + fixture
- "Doc 90 ngày không ai đọc → khai tử" bị user veto đúng → RETIRE chỉ cho doc mồ côi; doc lạnh = check router + verify, không xóa
