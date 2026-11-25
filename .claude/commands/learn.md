---
description: Ghi learning event từ diff được user chấp nhận (nguyên tắc 12 v3 vòng B — cầu thủ công cho tới khi scripts Phase 4)
argument-hint: [trống = quét phiên hiện tại | mô tả ngắn decision nếu đã rõ]
---
<!-- ai-simple-version: 1.8.0 -->

Bạn đang chạy `/learn` — cuối phiên có revision đáng nhớ. Làm đúng thứ tự, KHÔNG sáng tác:

## 1. Dựng evidence chain từ git (SHA là bằng chứng, không phải trí nhớ)

- `base_sha`: commit trước khi bắt đầu task (git log / reflog).
- `initial_sha`: commit chứa bản ĐẦU AI làm (nếu có).
- `accepted_sha`: commit/state cuối được user chấp nhận.
- `user_revisions`: QUOTE NGUYÊN VĂN các câu user yêu cầu chỉnh (từ hội thoại phiên này).

**1b. VERIFY bằng lệnh — không gõ tay, không sáng tác** (chi phí ≈ 0, chống evidence bịa):
```bash
git cat-file -e <base_sha> && git cat-file -e <accepted_sha>   # SHA phải TỒN TẠI — fail thì dừng, tìm lại
git diff --name-only <base_sha>..<accepted_sha>                 # changed_paths = DÁN NGUYÊN output này
```
Event có SHA không qua được `cat-file` hoặc `changed_paths` không khớp diff = event rác — audit sẽ spot-check.

## 2. Filter TRƯỚC khi ghi (chống học sai từ gốc — 12 v3 §filter)

- Revision trace được về vi phạm ba-spec/design-spec/AC → **DEFECT, DỪNG** — không sinh event (về triage).
- Quyết định do khách hàng/brand project ép → scope tối đa `project:`, cấm generalize.
- Decision phải viết được thành **assertion kiểm chứng được** ("admin screens dùng density compact") — cảm nhận ("đẹp hơn") thì bỏ.

## 3. Ghi event

Append vào `docs/learning/events.jsonl` (tạo nếu chưa có; **parallel mode**: ghi `docs/learning/events/<run>-<lot>.jsonl` trong lot mình — worker không đụng file global, NT13):

```json
{"at":"<ISO>","run":"<run|solo>","lot":"<lot|->","base_sha":"...","initial_sha":"...","accepted_sha":"...","user_revisions":["..."],"changed_paths":["..."],"inferred_decisions":[{"decision":"<assertion>","scope":"<component|domain:x|project:x|user>","evidence":"explicit-instruction|strong-accepted|medium-accepted|weak-inferred"}]}
```

`evidence` là ENUM — KHÔNG có confidence thập phân: explicit-instruction (user nói thẳng/lặp ≥2 lần) > strong-accepted (chốt/merge theo yêu cầu) > medium-accepted (im lặng+merge / xây tiếp lên trên) > weak-inferred (chỉ suy từ diff).

## 4. Promote nếu đủ ngưỡng (12 v3 §promotion — 3 mức)

- `explicit-instruction` → ghi luôn rule ở scope đúng (memory nếu user-scope theo format NT07; app-map nếu domain; design-system/CLAUDE nếu project).
- ≥ 2–3 case ĐỘC LẬP (khác session, cách nhau thời gian) cùng project → project rule.
- Quyết định thuộc RIÊNG một vai chuyên gia (BA / UI / security / verifier), vai khác không cần biết → ghi vào `docs/agent-memory/<vai>.md` theo dạng một-dòng trong `docs/agent-memory/README.md`, rồi chạy `sh .claude/skills/ai-simple-product-dev/agent-memory-verify.sh`. Vai khác cũng cần → KHÔNG ghi ở đó, ghi vào spec/app-map.
- Mỗi rule mới BẮT BUỘC kèm: evidence links (SHA/event), `last_verified: <date>`, rollback condition. Rule không có 3 thứ này = không được ghi.
- Chỉ 1 case + không explicit → dừng ở event, KHÔNG tạo rule. Ngoại lệ security/data-loss: assertion phải nêu RỦI RO CỤ THỂ + evidence tối thiểu `strong-accepted` — `weak-inferred` tự dán nhãn "security" không được đặc cách.
- Parallel mode: khai `docs/learning/events/<run>-<lot>.jsonl` vào write_paths khi claim (hoặc `parallel extend`) — event file cũng là file của lot, không nằm ngoài doctrine R2.
- **Gom cấp run (integrator, sau merge)**: khi gom events per-lot vào `events.jsonl`, REMAP `accepted_sha` = integration SHA sau merge của lot (SHA per-lot đã bị rebase thành orphan — giữ vào `lot_sha_pre_rebase`); chạy lại bước 1b trên SHA mới trước khi ghi.

## 5. Báo cáo 1 dòng cho user

`<n> event ghi, <m> rule promote (scope ...), <k> bỏ vì defect/không đủ bằng chứng` — không dài hơn.
