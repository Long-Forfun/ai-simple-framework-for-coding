# Bộ nhớ theo vai của agent chuyên gia
<!-- ai-simple-version: 1.27.0 -->

> Mỗi agent chuyên gia (`.claude/agents/*-expert.md`, `verifier.md`) có MỘT file ở đây: `docs/agent-memory/<tên-agent>.md`.
> File nằm trong git: mọi máy, mọi phiên, mọi công cụ AI đọc cùng một bản; sửa sai bằng `git revert`.
> Đây là nguồn DUY NHẤT của giao thức — file agent chỉ trỏ về đây, không chép lại.

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
- Mã `M-NNN` tăng dần trong từng file, không tái dùng mã đã xoá.

## Vòng đời

| Lúc | Việc | Ai |
|---|---|---|
| Agent bắt đầu việc | Đọc file bộ nhớ của mình. Mục sắp dùng mà quá 180 ngày hoặc code liên quan đã đổi → đối chiếu lại rồi mới tin, sửa `last_verified` | Agent |
| Agent xong việc | Có điều đáng nhớ và đủ bằng chứng → thêm 1 mục. Mục đã sai → xoá ngay (git giữ lịch sử). Không có gì mới → không ghi | Agent |
| User chỉnh bản agent làm | `/learn` ghi event; quyết định thuộc riêng một vai → promote vào file của vai đó | AI + user |
| Trước commit / `doctor` | `sh .claude/skills/ai-simple-product-dev/agent-memory-verify.sh` | Máy |
| Mỗi quý (`/audit`) | Soát mục SUSPECT; mục lặp ở nhiều project → hồ sơ đề xuất đưa vào skill | AI + user duyệt |

## Lớn lên theo thời gian (không phình)

Trần 40 mục mỗi vai. Chạm trần là tín hiệu phải làm một trong ba việc, theo thứ tự:
1. Mục đã thành luật ổn định của project → chuyển sang spec/app-map/CLAUDE.md rồi xoá khỏi bộ nhớ.
2. Cùng một mục xuất hiện ở từ ba project khác lĩnh vực → hồ sơ đề xuất sửa skill (NT12 vòng C, owner duyệt).
3. Mục hết đúng theo `bỏ khi` → xoá.

## Ranh giới của lời bảo đảm

Máy kiểm được **hình dạng** của mục (mã, bằng chứng có ghi, ngày, điều kiện bỏ, trần). Máy không kiểm được bằng chứng có **đúng** không — phần đó là việc của agent `verifier` và của người duyệt diff. Bộ nhớ là nội dung nạp thẳng vào AI: duyệt diff của thư mục này kỹ như duyệt code.
