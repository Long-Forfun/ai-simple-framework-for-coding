---
name: ba-flow-logic
description: Phân tích nghiệp vụ hướng-người-dùng, pha đầu pipeline BA→design→build→triage: nhu cầu mơ hồ thành ba-spec (USER → nghiệp vụ → handoff → flow Input/Output → acceptance criteria làm oracle). Kích hoạt: làm BA, phân tích nghiệp vụ, viết yêu cầu/spec, vẽ hoặc tối ưu flow, tính năng mới còn mơ hồ. KHÔNG: thiết kế UI (→ui-design-logic), defect app đang chạy (→ui-ux-triage). Dừng ở WHAT+WHY.
---

# BA Flow Logic v2 — phân tích nghiệp vụ từ SỰ THẬT, không từ trí tưởng tượng

> v2 (2026-11-09) viết lại theo án lệ `docs/adr/003-an-le-ba-ui-tu-lich-su-commit.md`.
> Rà ~6.000 commit ở 8 repo: lỗi BA không đến từ việc thiếu mục trong spec. Lỗi đến từ chỗ AI
> **lấp chỗ trống bằng đoán mò** rồi viết thành luật: bịa vai, bịa persona, tự chốt luật chặn/xoá,
> đếm sai đại lượng. Spec v1 đủ mục mà vẫn sai, vì gate chỉ đếm mục.

```
SỰ THẬT (lời chủ dự án · code đang chạy · dữ liệu thật · văn bản luật) → USER → nghiệp vụ → handoff
→ flow Input/Output → TỪ ĐIỂN ĐẠI LƯỢNG → AC chạy trên số thật → ba-spec NGẮN + Quyết định cần chủ dự án
```

## 0. Vị trí trong hệ 5-skill

```
[ba-flow-logic] (nhu cầu→ba-spec) → ui-design-logic (→design-spec) → build → ui-ux-triage (vận hành/sửa)
        │←──────────── security-logic rà soát CẮT NGANG mọi pha (code/doc/dep — NT14) ────────────→│
        └──────────────── tất cả trên nền ai-simple (rail + truth + tier + memory + verify) ────────────┘
```

- **Pha PHÂN TÍCH.** Chưa có code. Biến nhu cầu thành **oracle hành vi** (`ba-spec`) ở `docs/app-map/*ba-spec*.md`, có frontmatter coupling.
- `ui-design-logic` đọc user và flow từ đây. `ui-ux-triage` dùng AC làm oracle.
- **Defer sang ai-simple**: risk-tier #06, memory #07, coupling/verify #12, doc+test #04. Không tự chế lại.
- **Nhận handoff ngược**: từ triage ("code khớp spec mà vẫn sai"), từ design (spec thiếu hành vi), từ security (AC cho phép hành vi không an toàn). Khi đó sửa spec, không sửa code (§8).

## 1. Trigger / non-trigger

Kích hoạt khi:
- Có các cụm "làm BA", "phân tích nghiệp vụ", "viết spec/SRS", "vẽ flow", "tối ưu quy trình", "acceptance criteria".
- Có nhu cầu hoặc tính năng mới còn mơ hồ.
- Nhận handoff ngược (như trên).

KHÔNG kích hoạt:
- Màn hình, layout, làm đẹp, chọn component → **ui-design-logic**.
- Defect trên app đang chạy → **ui-ux-triage**.
- Đổi nhỏ đã rõ (đổi text, sửa 1 rule có sẵn) → build thẳng.
- Lọc hay sắp xếp dữ liệu đã có → design.
- DB migration → ai-simple #06 RED.

Tie-breaker: WHAT (user, rule, hành vi) là BA. HOW-nhìn là design.

---

## 2. Bảy lỗi gốc của BA — kiểm TRƯỚC khi viết từng dòng spec [INV]

Mỗi lỗi có mã G (theo ADR 003) và bằng chứng commit thật. Vi phạm là bug của spec.

**G1 — Mọi khẳng định về user/nghiệp vụ phải có NGUỒN.**
- Gắn 1 trong 5 nhãn: `[chủ dự án]` (lời nguyên văn hoặc tóm tắt có ngày), `[code]` (path), `[dữ liệu]` (bảng/truy vấn/số thật), `[văn bản]` (luật, quy chế, hợp đồng), `[GIẢ ĐỊNH]`.
- `[GIẢ ĐỊNH]` KHÔNG được sinh luật cứng, token, test hay ràng buộc thiết kế. Nó chỉ được sinh mặc định nhẹ, đảo ngược được, và nằm trong §Quyết định cần chủ dự án.
- Án lệ: persona "ngư dân 40–60 tuổi, tay ướt" đẻ ra luật chữ to, có test canh 4 tháng, rồi anh Long ra lệnh xoá (SDMap `9f34159c`, ForFish `7c9f8cd9`).
- Cấm mô tả user bằng nhân khẩu học tưởng tượng. Thay bằng **bối cảnh quan sát được**: thiết bị gì, đang làm việc gì, online hay offline bao nhiêu phần trăm thời gian (có nguồn).

**G2 — Vai và quyền suy từ TIỀN + TRÁCH NHIỆM, không từ "cho linh hoạt".**
- Với mỗi vai, trả lời 3 câu: *ai trả tiền · ai chịu trách nhiệm pháp lý hoặc tài sản · ai bảo lãnh danh tính*.
- Mặc định an toàn:
  - Số vai ít nhất có thể.
  - Vai có đặc quyền (đại lý, thu mua, quản trị, cán bộ) do **người duyệt cấp**, không tự chọn.
  - Vai đã chọn **không đổi tự do**: đổi được là dữ liệu rối.
  - Quyền xem/sửa dữ liệu của một tài sản chỉ thuộc về **chủ tài sản**.
  - Người đã vào app thì không bắt đăng nhập lại cho một nghiệp vụ con.
- Án lệ: ForFish `fbfac1b6` (4 vai tự chọn, "đổi không giới hạn"), `f4de5247` (thuyền trưởng xem giám sát); mkn-3 `93680999`→`79ba054b` (tách nhóm quyền rồi 4 giờ sau gộp lại).

**G3 — Không nghiệp vụ, không bước, không tuỳ chọn nào mà không truy được nguồn.**
- Mỗi nghiệp vụ, bước hay rule ghi rõ ai đòi: `[chủ dự án]`, `[văn bản]` hoặc hệ quả bắt buộc của một thứ đã có nguồn. Không truy được thì bỏ.
- "Cho đầy đủ", "người dùng có thể muốn", "để mở rộng sau" không phải nguồn.
- Án lệ: ForFish `0fd250c6` ("ko cần quy dầu ra tiền đâu"), spec 14 AC03 lọc bị gạch bỏ.

**G4 — Đại lượng phải vào TỪ ĐIỂN trước khi vào AC.** Với mỗi con số mà nghiệp vụ tính, đếm hay hiển thị, khai đủ 6 ô:

| Ô | Câu hỏi | Án lệ khi bỏ trống |
|---|---|---|
| Đơn vị đếm | đếm cái gì: tàu, lượt, vụ hay dòng? | IUU `2455252` (dòng ≠ vụ), `630c79e` (2.369 lượt so với 330 tàu) |
| Kỳ | trong kỳ hay luỹ kế? mốc giờ nào (giờ VN)? | IUU `d8e576d` (5.1 phải luỹ kế) |
| Nguồn | bảng hoặc cột nào, suy từ đâu | IUU `a14f6ec` (cộng đôi mẫu số) |
| Null ≠ 0 | chưa khai thì hiện gì? (**không bao giờ là 0**) | IUU `51f403a` (ô tổng luôn 0, kê trung thực bị điểm thấp) |
| Chống trùng | khoá duy nhất là gì, cái gì được mang sang | IUU `05a6a15` (Hà Tĩnh 9 vụ thật ra là 4) |
| Đơn vị đo/tiền | đồng hay nghìn đồng, kg hay tấn | IUU `3b33fba`, `5b12100` (bị nhân 1000) |

Nghiệp vụ có con số thì phải có **≥1 AC chạy trên mẫu số liệu thật**: một tỉnh, một tàu hay một kỳ cụ thể, kèm con số kỳ vọng.

**G5 — Chỗ mơ hồ: chọn mặc định NHẸ + đảo ngược được, rồi đưa lên cho chủ dự án.**
- Gặp luật chưa rõ mức độ, theo thang sau:
  - **cảnh báo** chứ không chặn,
  - **ẩn** chứ không xoá,
  - **lưu nháp** chứ không nộp,
  - **cho qua kèm ghi nhận** chứ không từ chối.
- Ghi điểm đó vào §0 "Quyết định cần chủ dự án".
- CẤM viết "quyết định BA" cho luật **chặn, xoá, tính điểm, tiền hay quyền**.
- Án lệ: IUU `b759645` (chặn nộp quá chặt), AMS spec 19 NV3 (BA tự chọn "chặn" → chủ dự án đổi sang "chỉ cảnh báo"), mkn-3 `a6dec537` (dựng tính năng xoá, bị chốt "KHÔNG xoá").

**G6 — Một khái niệm = một tên. Chốt TỪ VỰNG trước khi viết flow.**
- Bảng Từ vựng chuẩn gồm: tên dùng, nghĩa, tên CẤM dùng (đồng nghĩa đã lỡ dùng).
- Flow, AC, nhãn UI và tên biến đều dùng đúng tên này.
- Án lệ: SDMap `2b19b261` ("lúc thì boat lúc thì monitor rối tùm lum"; 1 vai có 4 tên).

**G7 — Spec ghi TRẠNG THÁI HIỆN TẠI, ngắn, duyệt được trong 2 phút.**
- §0 "Quyết định cần chủ dự án": ≤7 dòng, gồm mọi thứ không hiển nhiên (vai, quyền, chặn/cảnh báo, ai trả tiền, cái bị bỏ, giả định đang gánh).
  Chủ dự án chỉ cần đọc mục này là đủ duyệt. Án lệ: ForFish spec 17 dài 471 dòng, được duyệt mù, sau đó 6 commit phải sửa vai.
- Lịch sử để git giữ. CẤM tường comment `re-verified` (IUU có 122–214 comment).
- Sửa thì **thay** câu cũ, không chồng thêm "ĐÍNH CHÍNH".
- Có quyết định chủ dự án đã chốt thì ghi vào §Sổ đã chốt (ngày, lời nguyên văn, luật, thứ canh), không rải khắp spec.
- Nghiệp vụ lớn hoặc chưa chắc: đề xuất **lát mỏng chạy được + ảnh màn** trước, rồi mới viết spec đầy đủ. Chủ dự án quyết đúng nhất khi đã thấy thứ chạy thật.

---

## 3. Pipeline — theo thứ tự, không nhảy cóc

```
B0 Sàng        → nhu cầu mơ hồ/mới → chạy; đổi nhỏ rõ → trả về build
B1 Gom sự thật → ĐỌC: lời chủ dự án (chat/memory/commit body), code + màn đang chạy, dữ liệu thật,
                 văn bản luật/quy chế, Sổ đã chốt của spec cũ. Ghi nguồn (G1). KHÔNG viết gì chưa đọc.
B2 Từ vựng     → bảng Từ vựng chuẩn (G6)
B3 User + vai  → registry có nguồn; vai/quyền theo 3 câu tiền-trách nhiệm-bảo lãnh (G2)
B4 Nghiệp vụ   → mỗi nghiệp vụ đúng 1 owner + nguồn đòi (G3); cross-user handoff có người nhận +
                 điều kiện + điểm kết khi treo
B5 Flow        → Input → Steps → Output · start/end rõ · không dead-end · ≥2 biến thể khi flow có
                 cross hoặc chuyên môn, loại biến thể có ghi lý do
B6 Đại lượng   → Từ điển đại lượng đủ 6 ô (G4) cho mọi con số
B7 AC + chốt   → G/W/T + Test + Assert định lượng; ≥1 AC số thật/nghiệp vụ có số; viết §0 ≤7 dòng (G7);
                 chỗ mơ hồ theo G5 → `ba-verify.sh` PASS
```

`ba-spec` là chốt chặn: chưa có thì chưa sang design. Việc nhỏ thì spec ngắn, nhưng §0, Từ vựng và các dòng có nguồn thì luôn phải có.
Template: `templates/ba-spec.md.template` (format 2). Chi tiết: `references/01..06`.

---

## 4. Team-agent — chỉ khi đáng (không nghi lễ)

Spawn khi có ≥3 nghiệp vụ cross-user, có nghiệp vụ chuyên môn (kế toán, kho, thanh toán, pháp lý, chấm điểm), hoặc user yêu cầu "tối ưu flow". Còn lại thì chạy tuần tự.

| Agent | Việc | Đầu ra bắt buộc |
|---|---|---|
| **Fact-Finder** | B1: đọc code, dữ liệu, lời chủ dự án, văn bản | danh sách sự thật kèm nguồn; câu nào chưa có nguồn thì ghi rõ |
| **Domain-Specialist** (động) | soi chuẩn nghiệp vụ, **veto** biến thể sai chuẩn | lý do veto trích văn bản hoặc chuẩn ngành |
| **Red-Team BA** | đóng vai chủ dự án khó tính. Với từng dòng spec, hỏi: *ai đòi? lấy từ đâu? số 0 này là gì? vai này ai duyệt?* | danh sách dòng không có nguồn hoặc vi phạm G1–G7 |
| **BA-Orchestrator** | ráp spec, trọng tài cuối, viết §0 | spec + §0 |

Bỏ kiểu "Optimizer tự chấm điểm flow mình đề xuất". Án lệ: ForFish spec 08 ghi "Bởi: Orchestrator", tức tự chấm cho chính mình. Đánh giá chỉ có giá trị khi người chấm có nguồn để đối chiếu.

---

## 5. Quy tắc cứng giữ từ v1 (đang chạy tốt theo án lệ)

- **WHAT/HOW**: BA chỉ nói user, nghiệp vụ, flow, rule và acceptance. Từ chỉ UI (`button|popup|modal|màn hình|nút bấm`…) xuất hiện trong AC là sai tầng (`ba-verify` BLOCK hoặc WARN).
- **Owner-user**: mỗi nghiệp vụ có đúng 1 owner. Không có owner là nghiệp vụ mồ côi. Cross-user khai tường minh, có điểm kết khi treo.
- **Rules R1..Rn** cụ thể và test được (mẫu tốt: IUU spec 12 §9).
- **AC**: G/W/T, atomic, map tới 1 flow, có `Test:` (e2e|integration|unit|manual) và `Assert` định lượng. AC-ID duy nhất.
- **Hỏi**: anh Long đã giao quyền tự quyết, nên không hỏi lặt vặt. Nhưng "tự quyết" nghĩa là **chọn mặc định nhẹ theo G5 và đưa lên §0**, không có nghĩa là tự chốt luật nặng. Chỉ RED mới dừng hỏi, gộp thành 1 câu.

## 6. Defer sang ai-simple

| Việc | Chủ | BA làm |
|---|---|---|
| Risk-tier | #06 | phân loại thay đổi AC/flow; chỉ RED mới ASK |
| Memory | #07 | lời chủ dự án lặp ≥2 lần → memory, và ghi vào Sổ đã chốt |
| Coupling/verify | #12 | frontmatter `covers/last_verified/ttl_days` |
| doc+test sync | #04 | AC = test; spec đổi CÙNG COMMIT với code |
| UI | ui-design-logic | gửi user + flow + Từ vựng + Từ điển đại lượng |

## 7. Exit gates (tick khi CHẠY xong)

- [ ] `sh ba-verify.sh --staged` exit 0. Spec format 2 bị BLOCK nếu thiếu §Quyết định cần chủ dự án, §Từ vựng chuẩn, §Từ điển đại lượng, §Sổ đã chốt, hoặc nếu §0 dài quá 7 dòng.
- [ ] Mọi dòng User/vai/nghiệp vụ có nhãn nguồn. Không `[GIẢ ĐỊNH]` nào sinh luật cứng (G1).
- [ ] Mỗi vai trả lời đủ tiền / trách nhiệm / bảo lãnh. Vai đặc quyền có người duyệt (G2).
- [ ] Không nghiệp vụ hay bước nào thiếu nguồn đòi (G3).
- [ ] Mọi con số có đủ 6 ô từ điển. Có AC chạy trên số thật (G4).
- [ ] Luật chặn/xoá/tiền/quyền mơ hồ đã hạ xuống mặc định nhẹ và nằm trong §0 (G5).
- [ ] 1 khái niệm = 1 tên (G6). §0 ≤7 dòng. Không tường re-verified (G7).
- [ ] KHÔNG viết code, KHÔNG đụng DB.

## 8. Reverse handoff

| Tình huống | Hành động | Tier |
|---|---|---|
| Spec sai | sửa AC/flow (thay câu cũ, không chồng thêm) | AC downstream phụ thuộc = RED |
| Thiếu ca | thêm AC | GREEN/YELLOW |
| Ngoài scope | quyết scope | YELLOW |
| Chủ dự án sửa một quyết định | ghi **Sổ đã chốt** + thứ canh (test/grep) để lần sau không hỏng lại (án lệ mkn-3 `07f252e7`→`e1ef3320`) | GREEN |

Sửa xong thì bump `last_verified`.

## 9. Cross-reference
- Án lệ: `docs/adr/003-an-le-ba-ui-tu-lich-su-commit.md` (repo nguồn ai-simple).
- `references/01` user/nghiệp vụ · `02` flow · `03` AC · `04` reverse/risk · `05` ai-simple · `06` **nguồn sự thật + từ điển đại lượng (v2)**.
- Template `templates/ba-spec.md.template` · eval `evals/evals.json` · cổng `ba-verify.sh`.
