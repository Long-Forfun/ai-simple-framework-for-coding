# CLAUDE.md — ai-simple (repo dev của chính phương pháp)

> Đây là repo NGUỒN của hệ ai-simple: 15 nguyên tắc, 5 skill, CLI `npx ai-simple`, hook template.
> Sản phẩm là PHƯƠNG PHÁP + MÁY THỰC THI — không phải app. Project tiêu thụ thật: C:/Code/ForFish.

## Tech Stack
- CLI: Node ≥ 18, zero-dependency (`bin/ai-simple.js`)
- Gate/verify: POSIX sh (chạy qua Git Bash trên Windows) — `templates/pre-commit.hook.template`, `skills/*/**.sh`
- Docs: Markdown tiếng Việt (methodology/, skills/, templates/)

## Cấu trúc
```
ai-simple--skill-product-dev/
├── bin/ai-simple.js        CLI: init/doctor/self-test/update/parallel...
├── methodology/01..15      15 nguyên tắc (nguồn lý lẽ — không phải nơi cất luật load-bearing)
├── skills/                 5 skill: ai-simple-product-dev (foundation), ba-flow-logic, ui-design-logic, ui-ux-triage, security-logic
├── templates/              thứ `init` cài vào project tiêu thụ (hook, CLAUDE.md, router...)
├── scripts/                gate: dogfood-gate, ship-gate, stranger-path, doc-health, rule-enforcer
└── docs/                   adr/, scoring.md
```

## Quy tắc viết code (nguyên tắc 15)
1. **Leo thang trước khi viết**, dừng ở bậc đầu tiên đủ dùng: (1) việc này có cần tồn tại không — không có dòng nào trong spec đòi thì bỏ · (2) repo đã có helper/type/pattern chưa · (3) thư viện chuẩn của ngôn ngữ · (4) nền tảng có sẵn (HTML/CSS/ràng buộc DB) — trừ các component đã chốt trong [STACK], chúng thắng bậc 4 · (5) dependency ĐÃ CÀI, cấm thêm dep mới cho việc vài dòng · (6) gói 1 dòng · (7) code tối thiểu chạy được. Không interface cho 1 implementation, không factory cho 1 sản phẩm, không wrapper chỉ để gọi tiếp; "để mở rộng sau" không phải lý do. Leo thang SAU khi đã đọc code bị chạm và lần đúng luồng thật.
2. Bậc 1 chỉ áp cho thứ AI tự nghĩ ra thêm. CẤM dùng nó để cắt thứ ba-spec/AC/design-spec đã ghi — đó là định nghĩa duy nhất của "được yêu cầu tường minh".
3. Sửa bug = sửa gốc: grep MỌI nơi gọi hàm đó trước, đặt guard ở hàm dùng chung, không vá từng caller. Trước khi thêm một hàm export mới: grep tên nó và grep việc nó làm — trùng nghĩa thì dùng lại hoặc gộp.
4. **KHÔNG cắt, dù thang bảo gì**: validate input ở ranh giới tin cậy · error handling chống mất dữ liệu · biện pháp bảo mật · ĐỦ MA TRẬN TRẠNG THÁI TRONG CODE (chưa login / role / trống / đang tải / lỗi / dữ liệu cực đoan) · touch target 44/48 · contrast 4.5:1 + dark mode · focus ring không bị huỷ trắng · hover không phải đường duy nhất · action → expectation (tạo xong thấy cái vừa tạo, xoá xong có Undo).
5. Gặp hành vi chưa có trong spec: CẤM bỏ qua im lặng. Trạng thái thuộc ma trận mục 4 → làm mặc định an toàn nhất + ghi `## Assumptions` + bổ sung 1 dòng vào spec CÙNG COMMIT; hành vi nghiệp vụ → handoff ngược BA; HOW-nhìn → handoff design.
6. Vùng miễn test giữ đúng 3 ca của nguyên tắc 04 (pure UI tweak / config-only / doc-only). "Sửa 1 dòng nên khỏi test" KHÔNG phải một ca.
7. Cắt góc có trần biết trước → để lại `// nợ: <trần là gì>, <điều kiện nâng cấp>`. Thiếu vế thứ hai thì nợ sẽ mục.
8. Riêng repo này: mọi script gate mới PHẢI có `--self-test`. **Auto-discover chỉ áp cho `skills/*/*-verify.sh|*-lane.sh`** — script trong `scripts/` phải được THÊM TAY vào mảng `jobs` của `cmdSelfTest` (audit độc lập 2026-08-16 bắt lỗi over-claim "auto-discover" ở đây; 4 script gate hiện chạy qua `npm run gates` chứ không qua `npm test`). Sửa `templates/pre-commit.hook.template` thì `.githooks/pre-commit` đồng bộ CÙNG COMMIT (dogfood-gate so nội dung sau khi bỏ version-stamp); văn bản load-bearing ship xuống project (`templates/*.command.md.template`) sửa thì bản cài `.claude/commands/*.md` đồng bộ CÙNG COMMIT + `update` tự refresh. Số bản sắc (15 nguyên tắc / 6 lớp / 5-skill) chỉ đổi kèm identity-manifest guard trong `bin/ai-simple.js` + `system-manifest.json`.

## Commit convention
```
<type>: <subject tiếng Việt, present tense>   — types: feat, fix, refactor, test, docs, chore
Thân commit ghi rõ hội đồng/án lệ nếu quyết định đến từ đó.
```

## Risk tiers (nguyên tắc 06)
- 🟢 GREEN (reversible bằng git: code/doc/test/template): đi thẳng, không hỏi
- 🟡 YELLOW (đổi hành vi gate — có thể chặn oan project tiêu thụ): tự làm + fixture chống-oan + ghi `## Assumptions`
- 🔴 RED (đổi format spec/frontmatter mà project tiêu thụ đã dùng, xoá gate đang chạy, đổi số bản sắc): đúng 1 câu confirm gộp

## KHÔNG ĐƯỢC phép
- Hardcode secret / API key (secret-scan của chính hook sẽ chặn — fixture secret phải lắp lúc chạy)
- Thêm gate mà không có fixture chống-BLOCK-oan (bài học: design-verify từng BLOCK oan chính dogfood)
- Copy nội dung từ skill/tool ngoài (Hallmark/Impeccable/Ponytail...) — chỉ nội hoá Ý TƯỞNG, viết lại, ghi nguồn + người ép (xem NOTICE.md + `scripts/rule-enforcer-gate.js`)
- WARN kéo `FAIL=1` trong hook (WARN là WARN)
- Đổi luật trong skills/ mà không sync evals + references trỏ chéo

## BẮT BUỘC phải
- `npm test` + `node scripts/dogfood-gate.js` xanh trước khi coi là xong
- Sửa gate → chạy thử trên project tiêu thụ thật (ForFish) trước khi land
- Luật mới trong skills/ mang nhãn [INV]/[DEF]/[STACK] + dòng "ép bởi <enforcer>"

## Bảo trì — self-optimization (nguyên tắc 12 v2)
| Trigger | Việc | Ai |
|---|---|---|
| Mỗi commit | hook: covers-sync, secret-scan, encoding, budget | Máy |
| Mỗi PR | `npm run gates` (self-test + dogfood + ship + rule-enforcer) | Máy/CI |
| Quý | `/audit` ở project tiêu thụ; so NOTICE.md với HEAD các nguồn (1 dòng kết luận) | AI + user duyệt |

## Quick commands
```bash
npm run test:fast              # tier NHANH cho vòng lặp sửa-chạy (bỏ hook self-test + mutation full)
npm test                       # FULL — bắt buộc trước khi land (hook, report, verify/lane, identity, mutation)
npm run gates                  # test + ship + dogfood + rule-enforcer (đúng thứ CI chạy)
node scripts/dogfood-gate.js   # hook tự cài + template đồng bộ + docs không over-claim
node scripts/ship-gate.js      # require-coverage + link-check trên tarball
node bin/ai-simple.js doctor   # sức khoẻ setup (chạy được ở cả đây lẫn project tiêu thụ)
```

## Memory (cross-session preferences)
- Trả lời user bằng tiếng Việt; văn bản repo bằng tiếng Việt
- Mọi claim về hành vi công cụ ngoài phải đo bằng máy trước khi ghi vào docs (án lệ hội đồng 2026-08-13/14)

## Context window management
- File này < 6000 tokens; chi tiết ở methodology/ + skills/, tham chiếu thay vì paste

---

**Last Updated**: 2026-08-14
