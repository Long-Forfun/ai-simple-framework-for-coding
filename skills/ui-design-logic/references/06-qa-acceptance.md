# 06 — QA & Acceptance: chưa nhìn thấy bằng mắt = chưa xong

Code UI viết xong mới đi được nửa đường. Lovable đẹp ổn định vì có vòng lặp render-nhìn-sửa;
skill này bắt buộc vòng lặp đó. **Cấm tuyên bố "xong" khi chưa screenshot.**

## 1. Quy trình screenshot loop

```
1. Chạy app (dev server / preview tool có sẵn trong môi trường)
2. Với MỖI màn hình trong screen map: screenshot ở 1440×900, 768×1024, 375×812
   + dark mode ở viewport chính (nếu app có dark mode)
   + SPOT-CHECK 320×568 (không cần đủ ma trận): chỉ soi scroll ngang, label wrap 2 dòng,
   heading tràn — 3 lỗi chỉ lộ ở bề rộng hẹp nhất
3. Chấm theo checklist mục 2 — nhìn ảnh thật, không nhìn code mà đoán. Vòng CUỐI (trước khi báo xong)
   do **Critic context sạch** chấm, không phải người dựng: subagent mới chỉ nhận screenshot + design-spec
   (+ ảnh tham chiếu ở mục Hướng hình nếu có) — KHÔNG nhận code, KHÔNG nhận lời giải thích. Critic trả
   DANH SÁCH ĐIỂM LỆCH (lệch spec / lệch checklist §2 / lệch tham chiếu ở điểm nào), không chấm điểm số
   (điểm của judge LLM nhiễu — NT12). Runtime không có subagent → chấm ở lượt riêng chỉ mở ảnh + spec.
   Ghi vào design-spec mục Nghiệm thu: `Phản biện <ngày>: <n> điểm lệch · sửa <a> · giữ <b> (lý do)`
4. Có lỗi BLOCK/MAJOR → sửa → screenshot lại vùng đã sửa → chấm lại
5. Lặp đến khi hết BLOCK/MAJOR (thường 2–3 vòng). MINOR còn lại: liệt kê cho user quyết
```

Task nhỏ (sửa 1 component): chỉ cần screenshot màn hình chứa nó ở viewport chính + mobile; miễn Critic.
Task mới cả app: đủ ma trận màn hình × viewport.

## 2. Checklist nghiệm thu

**BLOCK — phá chức năng hoặc phá tin cậy, sửa ngay:**
- [ ] Text tràn/đè lên nhau, element vỡ khỏi container ở bất kỳ viewport nào
- [ ] Contrast text < 4.5:1 (kiểm tra cả badge, placeholder, text trên ảnh)
- [ ] Touch target < 44px trên mobile cho action chính
- [ ] Dark mode: text tàng hình, nền trắng chói trong dark, border biến mất
- [ ] Hover-only action không có đường thay thế trên touch
- [ ] Primary action nằm dưới fold hoặc trong vùng collapse
- [ ] Scroll ngang trên mobile ở bất kỳ viewport nào, kể cả 320px (Hallmark gate 34)
- [ ] Số liệu/metric/testimonial BỊA trên UI — "+47% conversion", "10.000+ khách" không có nguồn:
      dùng số thật, "—" kèm nhãn "chờ số liệu", hoặc bỏ khối đó (Hallmark gate 46)
- [ ] Focus ring bị huỷ trắng: `outline-none` mà không có vòng thay thế trên cùng element —
      người dùng bàn phím bị chặn hẳn (SKILL.md [INV]; hook 1d-e cũng BLOCK, đây là lưới thứ hai)
- [ ] `onClick` trên `div/span/li/td` không role/tabIndex/onKeyDown — sửa mặc định: đổi sang
      `<button>` (SKILL.md [INV]; hook 1d-f)
- [ ] Control tương tác thiếu bộ trạng thái sàn 5 (mặc định/hover/focus/active/disabled;
      +loading nếu gọi mạng, +lỗi nếu nhận input); border-width đổi giữa state làm xô layout;
      ô lỗi không giữ chỗ đẩy cả form (03 §6)
- [ ] Contrast đo theo CẶP thực tế sau kế thừa — soi riêng: chữ trong card đổi nền, dark mode,
      chữ trên accent (04 §1); chữ gradient = BLOCK vì không đo được

**MAJOR — vi phạm spec/budget, sửa trước khi giao:**
- [ ] Màn hình vượt density budget đã khai trong DESIGN-SPEC (đếm khối, không cảm tính)
- [ ] Step tiếp theo mong muốn (theo screen map) KHÔNG phải element nổi bật nhất màn hình
- [ ] Màn hình phục vụ ≥ 2 loại user nhưng chỉ có 1 bản "trung bình cộng" (user mới và power user thấy y hệt nhau)
- [ ] (chỉ khi spec CÓ bảng trọng số — 01 §1b là công cụ tư duy, không bắt buộc) Vị trí/cỡ element không khớp bảng: item W3 nằm dưới fold; item W1 chiếm chỗ to bậc 0; item W0 vẫn hiện; > 2 item W3/màn hình/**loại user** (đúng phạm vi 01 §1b)
- [ ] Quá 1 nudge thăng cấp/màn hình, hoặc upsell chen lên trên job chính của user
- [ ] Thiếu trạng thái: empty không CTA, không skeleton, lỗi không lối thoát, chưa-login chưa quyết định
- [ ] Sau hành động chính, màn hình hiện ra KHÔNG khớp bảng action → expectation (tạo xong không thấy cái vừa tạo)
- [ ] Demo bằng lorem ipsum/dữ liệu đẹp thay vì dữ liệu thật cực đoan (tên dài, số 0, list dài)
- [ ] Spacing ngoài thang 4/8/12/16/24/32/48/64/80/96 — grep arbitrary CHỈ trên prefix spacing
      (p/m/gap/space, xem 07 §5); sizing 40/44/48/56 (row height, touch target) là thang RIÊNG,
      không tính vi phạm (SKILL.md, hội đồng 2026-08-13)
- [ ] Cột số trong table thiếu `tabular-nums` hoặc không căn phải; hero KPI không đạt 2–3× cỡ label
- [ ] 2 primary button trong 1 màn hình; hàng > 3 button
- [ ] Title cùng cấp lệch ngữ pháp / có cái 2 dòng / lệch casing
- [ ] Nhóm ngang hàng (1 hàng tab/button, menu, lưới card) lệch hình dạng label: trộn 1 dòng với 2 dòng, lệch > 1 từ giữa label dài nhất và ngắn nhất — check ở 375px trong ma trận VÀ spot-check 320px (§1; fail ở 320 cũng là MAJOR), sửa bằng ĐỔI TỪ NGỮ theo budget nhóm (03 §4)
- [ ] Badge sai bảng màu trạng thái đã chốt, hoặc badge > 2 từ
- [ ] Card cùng hàng lệch chiều cao; cột số không căn phải; lệch trục căn trái
- [ ] Số/ngày chưa format locale hoặc format lẫn lộn 2 kiểu
- [ ] Logo vi phạm quy tắc 04 (trên nền accent, thiếu khoảng thở, bị đổi màu)
- [ ] Mobile: table scroll ngang thay vì biến thành list card; form 2 cột
- [ ] Empty state trống trơn không có hành động; ô table trống không có "—"
- [ ] Button/nav link/breadcrumb/CTA wrap 2 dòng ở bất kỳ viewport nào — clickable text
      luôn 1 dòng, sửa bằng đổi từ ngữ theo budget nhóm (03 §4; Hallmark gate 49)
- [ ] Fake chrome vẽ tay: browser bar giả (URL pill + 3 chấm), khung điện thoại giả,
      cửa sổ code giả — dùng screenshot thật trong `<figure>` hoặc bỏ (Hallmark gate 47)
- [ ] Heading in nghiêng (italic) hoặc từ nhấn `<em>` nghiêng trong heading — nhấn bằng
      weight/màu accent, italic chỉ sống trong body text (Hallmark gate 38a)
- [ ] Grid chứa ẢNH dùng `1fr` trần làm ảnh phình/đẩy vỡ hàng — dùng `minmax(0,1fr)`;
      check bằng MẮT trong screenshot, máy grep không phân biệt được grid-có-ảnh (Hallmark gate 50 —
      07 §5 và 08 §4 trỏ về đúng dòng này)
- [ ] Gradient trang trí vô cớ (không mã hoá thông tin gì) hoặc bố cục "hero + 3 card giống hệt"
      kiểu template AI — thay bằng nội dung thật hoặc bỏ khối (triệu chứng case B của §3, chấm tại đây)
- [ ] Card lồng card — một tầng chứa duy nhất; ranh giới trong dùng divider (03 §1)
- [ ] Hàng ngang trộn phần tử khác chiều cao mà không căn giữa dọc — icon/badge "trôi" so với
      baseline chữ (02 §6)
- [ ] Màn `product` có sequence animation lúc tải / scroll-reveal / nội dung thật nằm ẩn chờ JS —
      trạng thái nghỉ của DOM phải là đã hiện (04 §6; check bằng mắt + tắt JS thử, KHÔNG grep
      `opacity-0` — đã đo oan 100%)
- [ ] Emoji làm icon chức năng / trộn ≥ 2 bộ icon trong 1 màn (04 §3)

**MINOR — ghi nhận, sửa nếu còn thời gian:**
- [ ] Transition giật/thiếu cho overlay; focus ring thiếu trên vài element
- [ ] Tooltip thiếu cho icon-only button phụ
- [ ] Cắt chuỗi truncate chưa có tooltip full text

## 3. Diagnose UI có sẵn (user chê "xấu", "rối", "chỏi")

**Phân loại NGUYÊN NHÂN trước khi sửa — "xấu" có 4 loại, mỗi loại một cửa:**

| Xấu vì gì | Dấu hiệu | Đi đâu |
|---|---|---|
| (A) Nghiệp vụ đúng, giao diện rối | Flow/AC chạy đúng; rối layout, density, component, title | Chạy ngược checklist §2 — chính mục này |
| (B) Nhìn như AI/slop/template | Metric bịa, fake chrome, hero+3-card generic, gradient vô cớ | §2 gate anti-slop; landing cần chấm sâu → contract 08 |
| (C) "Xấu" nhưng thật ra THIẾU hành vi | Màn thiếu trạng thái/nghiệp vụ mà spec cũng không có | KHÔNG sửa UI — handoff BA (ba-flow-logic), spec sai/thiếu |
| (D) App thật đang lỗi chức năng | Button không bấm được, sai dữ liệu, sai role, treo | ui-ux-triage (test như user thật, phân bucket) |

**Đo trước khi sửa case B** (v1.28.0): chạy `npx ai-simple ui-fingerprint` — in số họ màu đang dùng so với luật 04 §1 và mật độ
các mẫu hay gặp ở UI do máy sinh (gradient, họ tím, bo góc lớn, bóng nặng, kính mờ, emoji, màu rời) trên mỗi 1000 dòng.
Ghi con số TRƯỚC vào báo cáo, sửa, chạy lại ghi con số SAU — "đỡ giống AI hơn" phải là một hiệu số, không phải cảm giác.
Đây là báo cáo (luôn exit 0): repo dùng token thuần ra 0 họ màu là đúng; bo góc lớn có trong design-system đã chốt thì
không phải lỗi — đối chiếu với mục Ngoại lệ đã duyệt trước khi coi là vi phạm.

**Guardrail redesign (case A/B): đổi HOW nhìn, giữ WHAT chạy.** Được đổi: layout, spacing,
component, hierarchy, density, mobile adaptation. KHÔNG tự đổi: AC, permission, flow, dữ liệu,
trạng thái nghiệp vụ — muốn đổi là việc BA, handoff ngược. Đổi token toàn cục / tái cấu trúc nav
giữa chừng redesign vẫn là RED theo 07 §4 (1 câu confirm), không nằm trong "phạm vi redesign".
Đổi wording = sync design-spec cùng commit (oracle copy UI là design-spec; riêng THUẬT NGỮ
nghiệp vụ — tên đối tượng/trạng thái — phải khớp ba-spec, lệch thì hỏi BA chứ không tự đổi).

Chạy ngược checklist: screenshot hiện trạng → đánh dấu vi phạm theo 3 mức → báo cáo
"X BLOCK, Y MAJOR" kèm ảnh → đề xuất thứ tự sửa: BLOCK → căn hàng/spacing (mục MAJOR
hình học — rẻ mà hiệu quả nhất) → text/title → màu. Kinh nghiệm: 80% cảm giác "rối"
đến từ spacing ngoài thang + lệch trục + title lộn xộn, KHÔNG phải do màu. Đừng đổi màu trước.

## 4. Định nghĩa "xong"

1. DESIGN-SPEC.md tồn tại và khớp với cái đã build (screen map, density, quyết định đã chốt)
2. Ma trận screenshot đủ, không còn BLOCK/MAJOR
3. MINOR còn lại được liệt kê tường minh
4. Báo cáo cuối kèm screenshot before/after nếu là task sửa
