# Bộ nhớ theo vai của agent chuyên gia
<!-- ai-simple-version: 1.28.0 -->

> Mỗi agent chuyên gia (`.claude/agents/*-expert.md`, `verifier.md`) có MỘT file ở đây: `docs/agent-memory/<tên-agent>.md`.
> File nằm trong git: mọi máy, mọi phiên, mọi công cụ AI đọc cùng một bản; sửa sai bằng `git revert`.
> Đây là nguồn DUY NHẤT của giao thức — file agent chỉ trỏ về đây, không chép lại.

## Hai tầng nhớ (v1.28.0)

| Tầng | Ở đâu | Nhớ gì | Đồng bộ |
|---|---|---|---|
| **Gu của user** | `.claude/ai-simple-user/agent-memory/<vai>.md` (liên kết tới `~/.ai-simple-user/`, `init` tạo) | Cách user muốn vai này làm, **không gắn với project hay khách hàng nào**: "bảng admin luôn dày đặc", "không dùng bóng đổ trang trí" | Mọi repo trên MÁY NÀY. Không lên GitHub (owner chốt 2026-11-26); có git local để hoàn tác |
| **Chuyện của repo** | `docs/agent-memory/<vai>.md` | Thứ riêng của project này: domain, khách hàng, brand, bẫy đã dính | Trong git của repo: mọi máy, mọi phiên |

- **Mâu thuẫn → tầng repo thắng** (NT12 thứ tự ưu tiên: spec/domain của project > gu của user > skill mặc định). Ví dụ gu chung là "dày đặc" nhưng ForFish cho ngư dân ngoài trời ghi "chữ to, thưa" → ở ForFish làm theo ForFish.
- **Lên tầng gu của user khi**: user nói thẳng kiểu "từ giờ luôn…/ở đâu cũng…" (`explicit-instruction`), HOẶC cùng một lần sửa lặp lại ở ≥ 2 repo khác nhau. Một lần sửa ở một repo → chỉ ghi tầng repo. Quyết định do khách hàng/brand ép → CẤM lên tầng user.
- **Sửa tầng user xong phải commit vào git local** của nó, để lần sau máy so được lịch sử và còn đường hoàn tác:
  `git -C .claude/ai-simple-user add -A && git -C .claude/ai-simple-user commit -qm "<vai>: <mã> <tóm tắt>"`
- Cổng máy kiểm cả hai tầng: `ai-simple doctor` (tầng user), `agent-memory-verify.sh` (tầng repo).
- **Chỗ hở nêu tên**: tầng user không có trên máy khác (PC GPU có kho riêng, không tự đồng bộ). Hai kho lệch nhau là chuyện được chấp nhận theo lựa chọn "chỉ trên máy".

## Thứ gì được nhớ

Chỉ nhớ thứ **riêng của vai đó ở project này** mà phiên sau sẽ làm sai nếu không biết:
bẫy đã dính, quyết định user đã chốt cho vai này, quy ước project lệch khỏi mặc định của skill.

KHÔNG nhớ ở đây:
- Luật chung của nghề → đã ở trong skill. Thấy skill thiếu thì đề xuất sửa skill (xem "Lớn lên").
- Sự thật về code/nghiệp vụ mà vai khác cũng cần → app-map, ba-spec, design-spec. Hai nơi cùng ghi một sự thật là hai nơi sẽ lệch nhau.
- Nhật ký việc đã làm, trạng thái task → git log.

## Dạng một mục (mỗi mục MỘT dòng, máy kiểm được)

```text
- [M-007] <khẳng định kiểm chứng được> | scope: <project|domain:x|component:y> | evidence: <SHA | path:dòng | event> | last_verified: YYYY-MM-DD | bỏ khi: <điều kiện mục này hết đúng>
```

- `evidence` phải truy được: commit, dòng trong spec, hoặc câu user nói (ghi event bằng `/learn`). Không có bằng chứng thì không ghi.
- `bỏ khi` là điều kiện xoá. Mục không nói được khi nào hết đúng thì sẽ sống mãi và thành tiền đề cũ.
- Mã `M-NNN` tăng dần trong từng file, không tái dùng mã đã xoá (máy chặn: mã mới phải lớn hơn mã lớn nhất ở HEAD).
- **Sửa từng dòng, không viết lại cả file.** Mỗi lần chỉ thêm, sửa hoặc xoá đúng mục cần đổi. Để AI viết lại cả file sau mỗi việc là cách nhanh nhất làm mòn chi tiết và mất bằng chứng (máy cảnh báo khi một lần sửa làm mất quá nửa số mục).

## Vòng đời

| Lúc | Việc | Ai |
|---|---|---|
| Agent bắt đầu việc | Đọc file bộ nhớ của mình. Mục sắp dùng mà quá 180 ngày hoặc code liên quan đã đổi → đối chiếu lại rồi mới tin, sửa `last_verified` | Agent |
| Agent xong việc | Có điều đáng nhớ và đủ bằng chứng → thêm 1 mục. Mục đã sai → xoá ngay (git giữ lịch sử). Không có gì mới → không ghi | Agent |
| User chỉnh bản agent làm | `/learn` ghi event; quyết định thuộc riêng một vai → promote vào file của vai đó | AI + user |
| Trước commit / `doctor` | `sh .claude/skills/ai-simple-product-dev/agent-memory-verify.sh` | Máy |
| Đo xuyên repo | `MEM_DIR=.claude/ai-simple-user/agent-memory MEM_EVENTS=.claude/ai-simple-user/learning/events.jsonl sh .claude/skills/ai-simple-product-dev/agent-memory-verify.sh --stats` (chạy ở gốc repo) — số lần user sửa từng vai, gộp MỌI repo trên máy, theo tháng | AI + user |
| Mỗi quý (`/audit`) | Soát mục SUSPECT; mục lặp ở nhiều project → hồ sơ đề xuất đưa vào skill. Chạy `agent-memory-verify.sh --stats`: số lần user sửa từng vai theo tháng phải giảm; vai nào không giảm sau một quý thì soát lại bộ nhớ và skill của vai đó | AI + user duyệt |

## Lớn lên theo thời gian (không phình)

Trần 40 mục mỗi vai. Chạm trần là tín hiệu phải làm một trong ba việc, theo thứ tự:
1. Mục đã thành luật ổn định của project → chuyển sang spec/app-map/CLAUDE.md rồi xoá khỏi bộ nhớ.
2. Cùng một mục xuất hiện ở từ ba project khác lĩnh vực → hồ sơ đề xuất sửa skill (NT12 vòng C, owner duyệt).
3. Mục hết đúng theo `bỏ khi` → xoá.

## Ranh giới của lời bảo đảm

Máy kiểm được **hình dạng** của mục (mã, bằng chứng có ghi, ngày, điều kiện bỏ, trần, không tái dùng mã) và cảnh báo hai dấu hiệu xấu (viết lại cả file; cùng một khẳng định nằm ở hai vai — sự thật chung phải lên spec/app-map). Máy không kiểm được bằng chứng có **đúng** không — phần đó là việc của agent `verifier` và của người duyệt diff. Bộ nhớ là nội dung nạp thẳng vào AI: duyệt diff của thư mục này kỹ như duyệt code.
