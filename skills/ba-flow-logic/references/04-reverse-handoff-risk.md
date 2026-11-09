# 04 — Reverse handoff từ triage + risk-tier cho thay đổi spec

## Reverse handoff — "code khớp spec mà vẫn sai"

`ui-ux-triage` (§4c của nó) đẩy về đây khi: code **khớp** ba-spec nhưng **hành vi** vẫn sai — lỗi
nằm ở SPEC HÀNH VI → BA sửa ba-spec, **không** sửa code, không tự triage. Payload nhận theo format
4c của triage: `HANDOFF | to=BA | spec=... | ca=... | bằng-chứng=... | đề-xuất=...`.
(Ca "code khớp *design-spec* mà GIAO DIỆN vẫn sai" KHÔNG về đây — triage đẩy thẳng
`ui-design-logic`; BA bị cấm đụng UI.)

**Đường nhận thứ 2 — từ `ui-design-logic` (06 §3 case C, TRƯỚC khi có code):** design đang làm màn
thì phát hiện spec THIẾU hành vi (màn cần trạng thái/nghiệp vụ mà ba-spec không có). Tiền đề khác
bảng 3-ca dưới (chưa có code để "khớp spec"), nhưng hành động trùng ca **Nhu cầu thiếu**: quay
B4–B6 cho đúng nghiệp vụ đó, bump `last_verified`, rồi trả spec về cho design chạy tiếp.

Phân loại 3 ca:

| Ca | Dấu hiệu | Hành động | Tier |
|---|---|---|---|
| **Spec sai** | AC mô tả sai hành vi đúng-mong-đợi | Sửa AC/flow cho khớp nhu cầu thật | sửa AC mà design/build/triage đang dựa = **RED** |
| **Nhu cầu thiếu** | Có ca thật chưa AC nào phủ | Thêm AC/flow mới (quay B4–B6 cho nghiệp vụ đó) | GREEN/YELLOW |
| **Nhu cầu mới** | Ngoài scope gốc | Quyết scope (B3 Priority): nhận thì thêm, không thì hoãn + ghi OUT | YELLOW |

Quy trình: nhận handoff → tái chạy đúng nghiệp vụ liên quan (không làm lại cả spec) → cập nhật AC/flow → **bump `last_verified`** + (format 2) THAY câu cũ, lời chủ dự án ghi vào Sổ đã chốt — lịch sử để git; format cũ: 1 dòng History → nếu hành vi đổi, kích lại `ui-design-logic`/build.

> Vòng này đóng pipeline: BA→design→build→triage→**BA**. Nó là lý do ba-spec phải `covers` UI code — code đổi thì ba-spec SUSPECT, triage biết oracle có thể cũ trước khi đổ lỗi cho code.

## Risk-tier cho thay đổi spec (defer ai-simple #06, áp cho AC/flow)

| Tier | Thay đổi | Hành xử |
|---|---|---|
| 🟢 GREEN | Thêm AC/flow MỚI cho nghiệp vụ chưa có; sửa Assumptions; làm rõ wording không đổi nghĩa | Làm thẳng, không hỏi |
| 🟡 YELLOW | Thêm nghiệp vụ/owner mới trong scope; đổi default flow (vẫn tương thích AC cũ); nhận "nhu cầu mới" nhỏ | Tự làm theo phương án an toàn + ghi **Assumptions** cuối |
| 🔴 RED | **Sửa/xoá AC mà downstream đang phụ thuộc** (design đã vẽ, code đã build, triage đang dùng làm oracle); đổi owner-user của nghiệp vụ đang chạy; phá invariant (§9) | Dừng — **1 câu ASK gộp** kèm phương án khuyến nghị, đợi trả lời |

Vì sao sửa AC cũ = RED: AC là **contract** 3 bên (design vẽ theo, code build theo, triage kiểm theo). Đổi nó âm thầm = phá đồng thời cả ba → đúng kiểu "irreversible across repos" của ai-simple #06.

## Memory (defer ai-simple #07)
User sửa **cùng một loại quyết định BA 2 lần** (vd: luôn ưu tiên flow ngắn hơn flow an toàn; luôn gộp tạo+sửa vào 1 nghiệp vụ) → ghi vào memory feedback theo format ai-simple, không hỏi lại lần 3. Không tự định nghĩa format memory — dùng của ai-simple.
