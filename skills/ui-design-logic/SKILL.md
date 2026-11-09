---
name: ui-design-logic
description: Thiết kế UI/UX top-down hướng-người-dùng: sinh design-spec (thang người dùng, screen map, ma trận trạng thái) rồi build UI, kết bằng QA screenshot; luật anti-AI-slop ép ở pre-commit. Kích hoạt: thiết kế màn/dashboard/landing/form, build UI, thêm màn hình, màn xấu/rối/nhìn như AI, redesign giữ chức năng, làm cho đẹp. KHÔNG: defect app đang chạy (→ui-ux-triage), nhu cầu nghiệp vụ mới (→ba-flow-logic).
---

# UI Design Logic

## Triết lý

Design KHÔNG phải trang trí. Design là **chuỗi quyết định có logic, đi từ trên xuống**:

```
Ai dùng → họ đến để làm gì → cần bao nhiêu màn hình/flow
→ mỗi màn hình chứa gì (density budget) → dùng component nào (decision table)
→ trông ra sao (tokens, hoà màu logo) → chạy trên thiết bị nào (3 design con)
→ nghiệm thu bằng mắt (screenshot QA loop)
```

Cái đẹp là **hệ quả** của tính nhất quán + mật độ đúng + quyết định có lý do.
Cái xấu "lệch lệch khó tả" đến từ quyết định tuỳ hứng: title lúc dài lúc ngắn,
badge dùng bừa, popup vô tội vạ, logo chỏi màu. Skill này diệt sự tuỳ hứng.

## 0. Vị trí trong hệ 5-skill (ĐỌC TRƯỚC)

```
BA (nhu cầu→ba-spec) → [ui-design-logic] (→design-spec) → build → ui-ux-triage (vận hành/sửa)
        │←──────────── security-logic rà soát CẮT NGANG mọi pha (code/doc/dep — NT14) ────────────→│
        └──────────────── tất cả trên nền ai-simple (rail + truth + tier + memory + verify) ────────────┘
```

- **Skill này = pha THIẾT KẾ.** Nhận ba-spec (WHAT), quyết HOW-nhìn → design-spec; không đụng WHAT (→BA), không sửa defect app chạy (→triage).
- **Handoff sang security-logic**: màn LỘ DATA (hiển thị data nhạy cảm sai đối tượng trong user-ladder) hoặc design chạm UI auth/payment → chuyển `security-logic` review (NT14) trước khi chốt design-spec; nhận lại finding dạng ràng buộc hiển thị.

## 0b. Tám lỗi gốc của UI — kiểm TRƯỚC khi vẽ, ép ở design-spec [INV]

> v2 (2026-11-09), án lệ `docs/adr/003-an-le-ba-ui-tu-lich-su-commit.md`. Phần lớn công sửa UI của
> anh Long KHÔNG đến từ màu, spacing hay token. Nó đến từ 8 thói quen dưới đây. Luật ở phần sau vẫn
> giữ, nhưng **8 điều này kiểm trước**.

**G1 — Không thiết kế cho persona tưởng tượng.**
- Cỡ chữ, cỡ nút và mật độ dùng **mặc định nền tảng** (system font size, M3/HIG).
- CẤM luật "chữ to / nút to cho người lớn tuổi, tay ướt, ngoài nắng" nếu không có `[chủ dự án]` chốt.
- Muốn hỗ trợ chữ lớn thì làm **tuỳ chọn trong Cài đặt**, mặc định là "thường".
- Án lệ: SDMap `9f34159c`, ForFish `7c9f8cd9` (luật 18px/56px sống 4 tháng rồi bị ra lệnh xoá).

**G3 — Mỗi phần tử trên màn phải TRUY ĐƯỢC NGUỒN.**
- Áp cho: nút, tab, chip lọc, số đếm, badge, dòng chữ, hộp hỏi, bước.
- Phần tử phải chỉ ra được 1 AC, 1 câu chủ dự án, hoặc 1 nhu cầu điều hướng bắt buộc. Không chỉ ra được thì không vẽ.
- Mặc định: tab/chip/ô lọc **không kèm số đếm**. **Không lọc** nếu danh sách là feed. **Không dòng giải thích**.
- Án lệ: ForFish `42442c6f` ("facebook có lọc đâu?"), mkn-3 `0053649d` (bỏ số đếm toàn fe-admin), SDMap `921534b9`, `cb610882`.

**G4 — Tự làm thay vì bắt user làm.**
- Suy được (tỉnh từ vị trí, chủ đề từ nội dung) thì tự suy, cho sửa.
- Tải được thì tự tải, không hỏi [Tải]/[Để sau].
- Hành động đảo ngược được thì làm luôn kèm Undo, không hộp xác nhận.
- Chỉ hỏi khi việc đó không đảo ngược được.
- Án lệ: SDMap `b92ac04f` ("tự down đi, đừng có hỏi"), ForFish `20d70cae`, `45213b24`.

**G5 — Chép MẪU QUEN, không chế tương tác.**
- Mỗi màn trong Screen map khai **Mẫu tham chiếu**: app mà user mở hằng ngày (Facebook, Zalo, Google Maps, Messenger, MarineTraffic…) và **chép điều gì**.
- Lệch khỏi mẫu phải có lý do.
- Trước khi tạo màn hay component mới, tìm trong repo xem đã có cái tương tự chưa (`grep` route và component), rồi tái dùng.
- Án lệ: SDMap `9c8d7b30` ("xoá hết đi viết lại" thành luồng kiểu Google), ForFish `ee799e39` ("inline chứ đừng nhảy"), `ebf57cc9` ("tham khảo các bên khác").

**G10 — Chỉ đổi ĐÚNG thứ được yêu cầu.**
- Yêu cầu "sắp xếp lại" thì không đổi viền, mật độ hay menu.
- Mockup hay ảnh tham khảo: tách **ý chính** (thứ user nói thành lời) khỏi **minh hoạ** (phần còn lại trong ảnh). Chỉ làm ý chính.
- Đổi lớn: làm lát mỏng, gửi screenshot, rồi mới làm rộng.
- Án lệ: AMS GD-11 `a8e43aea`/`4b45374b` (trả lại kiểu cũ cùng ngày), GD-12; mkn-3 `8396989a`→`4d392262`.

**G11 — Không lộ ruột hệ thống.**
- Không hiện id, uuid, mã enum, mã lỗi, tên bảng, `[object Object]`, `undefined`, `NaN`.
- Mọi enum đi qua 1 bảng nhãn. Mọi lỗi đi qua 1 hàm thông báo thân thiện dùng chung. Sửa ở hàm chung, không vá từng chỗ.
- Án lệ: mkn-3 `ebac43bf`, `f7d9b00b`, `1869db90`; SHT-CRM `50b592f`; AI-Assistant `f74f2d4`.

**G12 — Mỗi con số, màu hay khuyến nghị khai "đọc xong user sẽ LÀM gì".**
- Có dữ liệu chống lưng; không có thì không hiện.
- Không dẫn user tới vi phạm (ví dụ vẽ vùng cá ngoài ranh giới).
- Không hiện % hay điểm giả chính xác.
- Xếp hạng, màu đỏ hay tô theo độ lớn chỉ dùng khi có ngưỡng do chủ dự án chốt. Mặc định là màu trung tính hoặc màu định danh.
- Án lệ: ForFish `9e707896`, `910c54e4`, `b37eb0a3`; IUU `25ff923`, `a69e382`.

**G13 — Đường về là bắt buộc.**
- Design-spec có bảng **Điều hướng**: mỗi màn có Back làm gì, và đường về gốc.
- Back đóng lớp trên cùng (sheet, dialog) trước, và **giữ chữ đang gõ**.
- Màn đầu tiên không có Back.
- Hành động phá huỷ (đăng xuất, xoá) có Undo hoặc xác nhận.
- Án lệ: ForFish `5b5ba990` ("làm sao quay về?"), audit `f4d8fea2` X1/X6; SDMap `bdf5167c`.

**Sổ đã chốt (chống hỏng lại — G9).**
- Mỗi lần chủ dự án sửa UI ("bỏ cái X", "đừng Y"), ghi 1 dòng vào `## Sổ đã chốt` của design-spec: ngày, lời nguyên văn, luật, thứ canh.
- Đọc sổ trước khi đụng vùng đó.
- Án lệ: mkn-3 `07f252e7` (ẩn) → D149 (mở lại) → `e1ef3320` (ẩn lần nữa).
- Design-spec ghi **trạng thái hiện tại**. Lịch sử để git. Không tường `re-verified` (SDMap design-spec dài 3782 dòng, AMS có ô bảng 2000 ký tự).

## Khi nào kích hoạt

- User yêu cầu build/design bất kỳ UI nào (web, app, dashboard, landing, form, report)
- User chê UI hiện tại "xấu", "rối", "không đồng nhất", "chỏi" → diagnose bằng checklist 06
- Thêm màn hình/feature vào app đã có → đọc DESIGN-SPEC.md hiện có trước, tuân theo budget
- User đưa logo/brand color → chạy quy trình hoà màu (04)
- Landing/marketing page (`Type: marketing-public`), UI bị chê "nhìn như AI", user đưa
  screenshot/URL tham khảo → đọc 08 (route theo Type; gate anti-slop đã nội hoá trong 06 §2 +
  hook 1d; màn `product` thì công cụ visual ngoài KHÔNG được đụng, xử lý bằng 06 §3)

## Pipeline 7 bước — BẮT BUỘC theo thứ tự, không nhảy cóc

```
0. Sự thật     → ĐỌC: Sổ đã chốt (design-spec + ba-spec), lời chủ dự án (chat/memory/thân commit vùng này),
                 màn + component ĐANG CÓ (tái dùng trước — G5), ba-spec (user/flow/AC/Từ vựng/Từ điển đại lượng).
                 KHÔNG có ba-spec → tự thu brief, mọi khẳng định về user gắn nguồn; [GIẢ ĐỊNH] không thành luật (G1)
1. IA + hành vi → THANG USER (loại × 3 câu — TIẾP NỐI từ ba-spec nếu có, không dựng lại) → object model, flow map, screen map + BUDGET, entry/step-tiếp/trạng thái/action→expectation → viết DESIGN-SPEC.md
2. Layout       → grid, density budget từng màn hình, quy tắc collapse/expand
3. Components   → tra decision table: component nào, text viết sao
4. Tokens       → màu (hoà logo), font, spacing — stack khoá React+Tailwind+shadcn
5. Platforms    → desktop/tablet/mobile = 3 design con; iOS theo HIG, Android theo Material
6. QA loop      → chạy preview, screenshot từng màn hình ở 3 kích thước, check, sửa, lặp.
                 Trước khi báo xong, soi từng screenshot theo §0b: phần tử nào không truy được nguồn (G3)?
                 chỗ nào bắt user làm việc máy làm được (G4)? có lộ id/enum/mã lỗi (G11)? Back có đóng lớp
                 trên cùng và giữ chữ đang gõ (G13)? Có làm gì ngoài phạm vi được yêu cầu (G10)?
```

**DESIGN-SPEC.md là chốt chặn**: chưa có spec (bước 1) thì CHƯA được viết code UI.
Spec nhỏ cho task nhỏ — thêm 1 màn hình thì spec là 10 dòng, nhưng phải có,
vì nó ép trả lời "màn hình này tồn tại để user làm gì" trước khi vẽ.

**Cổng máy `design-verify.sh`** (anh em với `ba-verify.sh` / `triage-verify.sh`): cơ giới hoá
"spec chưa đủ = chưa được code". BLOCK khi design-spec thiếu frontmatter coupling, thiếu thang
user, thiếu screen map (hoặc bảng 0 dòng / header thiếu cột Vào từ·Goal·Step tiếp·Primary),
hoặc thiếu ma trận trạng thái. Lint SPEC, KHÔNG lint code (check px/màu ở code thuộc pre-commit
hook, ref 07 §5 — tránh 2 cơ chế cùng việc). Dùng: `sh design-verify.sh [--staged|--self-test]`.
Wire: hook template v1.8.0 mục 1d2 TỰ GỌI qua junction `.claude/skills/ui-design-logic/`
(`ai-simple init` tạo junction). Project không dùng ai-simple thì wire tay:
`if ! sh .claude/skills/ui-design-logic/design-verify.sh --staged; then FAIL=1; fi`

**Quan hệ với ba-spec (nếu dùng `ba-flow-logic`)**: ba-spec là oracle HÀNH VI (user→nghiệp vụ→flow→AC),
design-spec là oracle GIAO DIỆN (screen→token). Design ĐỌC ba-spec, KHÔNG phân tích user lại từ đầu —
chỉ tiếp nối: nghiệp vụ/flow của ba-spec → màn hình; AC của ba-spec → ràng buộc "màn này phải làm được gì".
Hai file riêng, hai oracle riêng cho `ui-ux-triage`. Không có ba-spec (task UI thuần) → design tự thu brief như cũ.

## Quy tắc — 3 mức, xử theo nhãn (hội đồng 2026-08-13: hết trộn invariant với gu với stack)

Mỗi quy tắc mang đúng 1 nhãn. Vi phạm xử THEO NHÃN, không theo cảm giác:

- **[INV]** — bất biến usability/cấu trúc. Vi phạm là bug, BLOCK, không ngoại lệ.
- **[DEF]** — mặc định có căn cứ. Làm khác ĐƯỢC, nhưng phải có dòng trong design-spec mục
  `## Ngoại lệ đã duyệt` (template 01 §7) với lý do **AUDIENCE** hoặc **KỸ THUẬT**
  ("user thích/thấy gớm" không phải lý do — gu cấp project sống ở mục Anti-references của spec).
  Không có dòng ngoại lệ = vi phạm.
- **[STACK]** — convention của stack đã chọn. Chỉ áp khi project dùng stack đó.

**Kiến trúc & hành vi:**
- [INV] 1 màn hình = 1 nhiệm vụ chính = đúng 1 primary button
- [INV] Không design cho "user chung chung": spec khai báo **thang user** (public / mới / quen / power × role/tier), mỗi loại trả lời đủ 3 câu — *muốn thấy gì / sản phẩm truyền tải gì / thúc đẩy action tiếp theo gì*. Màn hình phục vụ ≥ 2 loại → có biến thể, cấm bản "trung bình cộng"
- [INV] Mỗi màn hình tối đa 1 nudge thăng cấp (upsell/mời đăng ký); cái USER CẦN luôn đứng trước cái SẢN PHẨM MUỐN
- [DEF] Phân bố info khi màn phục vụ ≥ 2 loại user: dùng công thức trọng số 0–3 của 01 §1b làm **công cụ tư duy** sinh biến thể — không phải gate; gate đo được là density budget (02 §1) và checklist 06
- [INV] Mỗi màn hình khai báo trong spec: **vào từ đâu → muốn gì → step tiếp theo mong muốn** — và step tiếp theo đó phải là element nổi bật nhất màn hình
- [INV] Màn hình chưa định nghĩa đủ trạng thái (chưa login / role / trống / đang tải / lỗi / dữ liệu cực đoan) = mới design một nửa
- [INV] Mỗi hành động chính có dòng "user kỳ vọng thấy gì ngay sau đó" (action → expectation) — tạo xong phải thấy cái vừa tạo, xoá xong phải có Undo
- [INV] Mobile bottom tabs / top nav hiển thị: ≤ 5 mục (M3 hard max). [DEF] Desktop sidebar: 5–7 mục cấp 1 + nhóm section collapse được — giới hạn thật là SỐ NHÓM và ĐỘ SÂU (≤ 2 cấp), không phải số link (NN/g: menu là recognition, broad-shallow thắng deep-narrow). Tab trong page: 2–6 tab, KHÔNG tab lồng tab
- [DEF] Core action của app: user chạm tới trong ≤ 3 click/tap từ màn hình chính

**Nhất quán text:**
- [DEF] Title cùng cấp = cùng ngữ pháp (cùng là danh từ hoặc cùng là động từ), luôn 1 dòng, không chấm câu cuối
- [INV] **Nhóm ngang hàng = đồng bộ HÌNH DẠNG label**: các label trong cùng 1 nhóm (1 hàng tab, 1 hàng button, 1 menu, 1 lưới card) phải cùng số dòng render (tất cả 1 dòng — hoặc tất cả 2 dòng nếu buộc phải thế) và cùng cỡ từ (chốt budget cho cả nhóm: ví dụ tab = 2 từ ≤ 10 ký tự, rồi CHỌN TỪ NGỮ cho vừa budget — đổi từ, viết tắt, cắt bớt). 1 nhãn không nhét vừa → sửa TỪ, không chấp nhận nhãn đó wrap riêng. Cấm trong cùng 1 nhóm: cái 1 dòng cái 2 dòng, cái 1 từ cái 4 từ, cái cụt lủn cái dài ngoằng — từ ngữ là biến thiết kế, không phải cái có sẵn phải chịu
- [DEF] Sentence case mọi nơi. Badge ≤ 2 từ. [INV] Số liệu luôn format theo locale

**Mật độ & thao tác:**
- [DEF] **Thang SPACING** (khoảng cách: padding/margin/gap) chỉ dùng 4/8/12/16/24/32/48/64/80/96px — số ngoài thang là bug (80/96 dành riêng cho khoảng giữa section lớn/landing). **Thang SIZING là thang riêng, KHÔNG phải vi phạm spacing**: chiều cao hàng table 40/48/56, touch target 44/48, control 36/40 — grep cổng máy chỉ soi prefix spacing (07 §5), cấm blanket-block mọi arbitrary px (hội đồng 2026-08-13: blanket từng đếm `min-h-[2.75rem]` = touch target 44px BẮT BUỘC thành "vi phạm")
- [DEF] "Nén trong widget, thoáng giữa widget": thông tin luôn đọc cùng nhau (hiện có/tổng, số/%, giá trị/xu hướng) nằm CÙNG 1 widget; 1 câu hỏi của user không được cần 2 widget để trả lời
- [DEF] 1 hàng button ≤ 3 cái; còn lại vào menu ⋯
- [INV] Hover KHÔNG BAO GIỜ là cách duy nhất làm một việc (touch không có hover)
- [INV] Touch target ≥ 44×44pt (iOS) / 48×48dp (Android); desktop được phép dày hơn mobile
- [INV] **Focus ring là bất khả xâm phạm**: `outline: none`/`focus:outline-none` CHỈ hợp lệ khi cùng element có vòng thay thế (`focus-visible:ring-*` hoặc outline khác 0). Dùng `:focus-visible` chứ không `:focus`; vòng focus không transition. Người dùng bàn phím không có con trỏ — huỷ trắng focus là chặn hẳn họ. *(nguồn ý tưởng HM∩IMP-focus · ép bởi hook 1d-e BLOCK + 06 §2)*
- [INV] **Thứ bấm được phải là thẻ bấm được**: `onClick` trên `div/span/li/td` thiếu `role`+`tabIndex`+`onKeyDown` là vi phạm — và cách sửa mặc định là đổi sang `<button type="button">`, không phải dán `role="button"` cho đủ lễ. *(nguồn ý tưởng IMP-semantic-html · ép bởi hook 1d-f BLOCK + 06 §2)*

**Visual:**
- [DEF] 1 neutral ramp + 1 accent + 4 màu semantic (+ 1 categorical palette RIÊNG cho chart nếu app có chart nhiều series — 04 §1). Logo xử lý theo 04, không nhét thô
- [INV] Text contrast ≥ 4.5:1 (chữ lớn ≥ 24px: ≥ 3:1). Dark mode phải được kiểm tra, không phải "để sau"
- [DEF] **FONT — mặc định SYSTEM FONT STACK**: `-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif` (native, có sẵn tiếng Việt, không tải Google Fonts). Số: system mono + tabular-nums. UI nghiệp vụ/nội bộ: không serif/display trang trí, không font "cá tính".
  **Đường làm khác (đúng cơ chế [DEF], không thương lượng bằng mồm):** font riêng chỉ khi (a) user chỉ đích danh font, HOẶC (b) design-spec có dòng `## Ngoại lệ đã duyệt` với lý do audience/kỹ thuật đọc được — vd ForFish: subset `vietnamese` đủ dấu + nét đậm cho UI chữ to ≥18px ngoài nắng. Lý do "trendy/đẹp" → từ chối, giữ system stack.
  Gu của user cụ thể ("thấy gớm font X" — 2026-07: Be Vietnam Pro / Plus Jakarta Sans / Fraunces) ghi vào mục **Anti-references** của design-spec project đó — KHÔNG phải luật toàn cục: cùng font đó ở project khác với audience khác có thể là lựa chọn đúng (hội đồng 2026-08-13, case ForFish).
- [DEF] **KHÔNG viết chữ giải thích kiểu AI trên UI** — bỏ subtitle/hint/marketing dạng câu văn thuyết minh. UI sản phẩm thật chỉ có NHÃN chức năng ngắn (nút, tiêu đề, cột), không có văn diễn giải "cái này để làm gì". Empty state theo câu chuẩn 03 §4: 1 cụm ngắn + 1 CTA, cấm văn thuyết minh (bậc user Mới được checklist onboarding).
- [DEF] **IA — tổ chức theo ĐỐI TƯỢNG/BỘ PHẬN, không theo khái niệm trừu tượng** (user 2026-07: "phòng điều khiển nhà máy là quần què gì"). Hệ nội bộ nhiều phòng ban → mỗi bộ phận là 1 không gian làm việc có Dashboard KPI riêng (con số bộ phận đó quản lý) + thao tác vào/ra của nó; lãnh đạo có 1 Dashboard tổng rollup. Đừng ép user vào mô hình flow trừu tượng của mình.

## Tài liệu chi tiết — đọc đúng file theo bước đang làm

- `references/01-information-architecture.md` — object model, flow map, budget page/tab/button, template DESIGN-SPEC
- `references/02-layout-and-density.md` — grid, density budget, thang progressive disclosure, quy tắc collapse/expand
- `references/03-component-decision-rules.md` — bảng tra: table vs list vs card vs map; badge vs tag; modal vs drawer vs page; quy tắc title/text/số
- `references/04-visual-tokens.md` — token đầy đủ, thuật toán hoà màu logo, shadcn theming
- `references/05-platform-adaptation.md` — 3 design con, biến đổi nav theo thiết bị, iOS vs Android vs desktop, chuột vs chạm
- `references/06-qa-acceptance.md` — checklist nghiệm thu, quy trình screenshot loop, phân cấp lỗi
- `references/07-integration-ai-simple.md` — ĐỌC KHI project dùng ai-simple-product-dev: DESIGN-SPEC vào app-map, routing task UI, sync invariant UI⇄spec⇄screenshot, risk tier cho design, hook check UI, drift routes vs screen map
- `references/08-landing-and-external-sources.md` — ĐỌC KHI task chạm landing/marketing (`Type: marketing-public`), UI bị chê "nhìn như AI", hoặc cân nhắc công cụ visual ngoài: route theo Type + precedence luật-của-ta-thắng + handoff Ngôn ngữ hình + cửa tuỳ chọn có điều kiện (gate anti-slop đã NỘI HOÁ vào 06 §2 + hook 1d — v1.9.0, NOTICE.md)

## Stack — [STACK] convention, áp khi project đã chọn stack này

React + Tailwind CSS + shadcn/ui (mặc định cho project mới không ràng buộc). Component chuẩn
(button, card, dialog, form, table, tabs, sheet, dropdown) BẮT BUỘC dùng shadcn — cấm tự viết lại từ đầu.
Lý do: floor quality. Component shadcn đã được con người tinh chỉnh spacing/contrast/states;
tự viết là mở cửa cho sự tuỳ hứng quay lại. Chỉ custom khi shadcn không có loại đó
(chart, map, canvas) — và khi custom thì phải tuân token 04.

Dự án không phải React (HTML tĩnh, Vue): vẫn áp dụng nguyên pipeline + token,
thay shadcn bằng component tự viết theo đúng spec trong 03/04.
