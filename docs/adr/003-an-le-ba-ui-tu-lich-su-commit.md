# ADR 003 — Án lệ BA + UI/UX rút từ lịch sử commit 8 repo (2026-11-09)

> Nguồn lý lẽ cho bản viết lại `ba-flow-logic` + `ui-design-logic` v2 (v1.26.0).
> Phương pháp: quét `git log` từ 03/2026 của ForFish, SDMap, IUU-REPORT, mkn-3, AMS---Aqua,
> AI-Assistant, SHT-CRM, forlife-web (~6.000 commit). Đọc thân + diff khoảng 80 commit sửa
> BA/UI, kèm toàn bộ ba-spec/design-spec. Thân commit thường trích nguyên văn lời anh Long hoặc BA khách,
> nên phần lớn bằng chứng là lời người thật. Mã commit dưới đây lấy theo repo tương ứng.

## Phát hiện tổng

1. **Skill cũ kiểm HÌNH THỨC, lỗi thật nằm ở NỘI DUNG.** 25 commit gần nhất của repo này gần như
   toàn bộ là hạ tầng gate. Gate chỉ đếm xem có đủ mục, có `Test:`, có `Assert` hay chưa. Không gate nào
   hỏi "câu này lấy từ đâu", "ai đòi cái này", "số 0 này là 0 thật hay chưa khai".
2. **Spec biến thành nhật ký sửa lỗi, không còn là quyết định trước khi build.**
   - IUU `12-ba-spec` có 122 comment `re-verified`, `11-design-spec` có 214.
   - SDMap `07-design-spec` dài 3782 dòng, mở đầu bằng "lỗi chủ dự án báo".
   - AMS `18-design-spec` có ô bảng dài khoảng 2000 ký tự.
   - AC trùng ID (IUU AC-18..20) và Flow NV8 bị định nghĩa 2 lần.
3. **Duyệt spec dài không chặn được lỗi.** ForFish spec 17 (471 dòng) được duyệt "Theo đề xuất, build"
   ngày 03/11. Trong 6 ngày sau đó có 6 commit phải sửa logic vai. Chỉ khi thấy màn thật mới nhận ra sai.
4. **Template mời AI bịa.** Bảng "User registry", "Thang người dùng", "Success metric" có ô trống thì
   AI lấp bằng khẩu hiệu hoặc khuôn mẫu. Ví dụ "ngư dân 40–60 tuổi, tay ướt" đẻ ra luật chữ to, và luật đó
   có test canh suốt 4 tháng.

## 12 lỗi gốc (mỗi lỗi một luật mới, ép bởi gate hoặc checklist)

| # | Lỗi gốc | Bằng chứng | Luật mới |
|---|---|---|---|
| G1 | **Giả định người dùng thành luật cứng** | SDMap `9f34159c` "xoá hết các ghi chú về thiết kế to cho ngư dân"; ForFish `79b065dd`→`7c9f8cd9` (luật 18px/56px sống 4 tháng) | Mỗi khẳng định về user/nghiệp vụ gắn **nguồn**. `[GIẢ ĐỊNH]` không được sinh luật cứng, token hay test. |
| G2 | **Bịa vai + quyền cho "linh hoạt"** | ForFish `fbfac1b6` (4 vai tự chọn, đổi không giới hạn) → `5b5ba990`, `09506094`; `f4de5247` (thuyền trưởng xem giám sát); mkn-3 `93680999`→`79ba054b` sau 4 giờ | Vai/quyền suy từ **tiền + trách nhiệm pháp lý + ai bảo lãnh**. Mặc định: ít vai nhất, vai đặc quyền phải có người duyệt, vai không đổi tự do. |
| G3 | **Thêm thứ không ai đòi** (tính năng, lọc, số đếm, tuỳ chọn, bước, hộp hỏi) | ForFish `42442c6f` "facebook có lọc đâu?", `0fd250c6` (quy dầu ra tiền); SDMap `921534b9` "<5% thì bỏ"; mkn-3 `0053649d` (bỏ số đếm toàn fe-admin) | **Truy nguồn từng phần tử**: mỗi thứ trên màn hoặc trong flow phải chỉ ra được câu chủ dự án hoặc AC. Không chỉ ra được thì không làm. |
| G4 | **Bắt user thao tác thay vì tự làm** | SDMap `b92ac04f` "tự down đi, đừng có hỏi"; ForFish `20d70cae` (tự chọn tỉnh), `45213b24` (tự đoán chủ đề) | Suy được thì tự suy. Tải được thì tự tải. Chỉ hỏi khi việc đó không đảo ngược được. |
| G5 | **Tự chế tương tác thay vì dùng mẫu quen** | SDMap `9c8d7b30` "xoá hết đi viết lại" (bảng trượt → luồng kiểu Google); ForFish `ee799e39` "inline chứ đừng nhảy", `ebf57cc9` "tham khảo các bên khác" | Mỗi màn khai **Mẫu tham chiếu**: app user dùng hằng ngày + điều chép. Tái dùng màn/component có sẵn trong repo trước. |
| G6 | **Đại lượng mơ hồ: null/0, đơn vị đếm, đếm trùng, kỳ, ×1000** | IUU `51f403a` (ô tổng luôn 0, kê trung thực bị điểm thấp), `a14f6ec` (cộng đôi mẫu số), `05a6a15` (đếm 2 lần), `3b33fba` (×1000), `2455252` (dòng ≠ vụ); AMS `ffcda6af` | **Từ điển đại lượng**: đơn vị đếm · kỳ · nguồn · null ≠ 0 · khoá chống trùng · đơn vị tiền. Có ít nhất 1 AC chạy trên số thật. |
| G7 | **AI tự chốt luật thay chủ dự án** (chặn/xoá/tính điểm) | IUU `b759645` (chặn quá chặt → warning), `630c79e` (BA đảo 5 quyết định); AMS NV3 (chặn → cảnh báo); mkn-3 `a6dec537` (dựng xoá, bị chốt "KHÔNG xoá") | Chỗ mơ hồ: mặc định **NHẸ và đảo ngược được** (cảnh báo, không chặn; ẩn, không xoá), rồi đưa lên mục **Quyết định cần chủ dự án**. |
| G8 | **Từ vựng và luồng vào app trôi** | SDMap `2b19b261` "lúc thì boat lúc thì monitor"; `/setup` đổi 4 lần trong 3 ngày; `62b58ef7` | Một bảng **Từ vựng chuẩn**: 1 khái niệm = 1 tên, cấm đồng nghĩa. Luồng vào app chốt bằng 1 sơ đồ duy nhất. |
| G9 | **Quyết định đã chốt bị làm hỏng lại** | mkn-3 `07f252e7` (ẩn BORDER_NEAR) → D149 mở lại → `e1ef3320` ẩn lần nữa | **Sổ đã chốt**: ngày, lời nguyên văn, luật, thứ canh (test/grep). Đọc sổ trước khi sửa vùng đó. |
| G10 | **Làm quá phạm vi, đọc mockup theo nghĩa đen** | AMS `a8e43aea`/`4b45374b` GD-11 (chỉ muốn đổi sắp xếp, AI đổi cả viền và mật độ), GD-12; mkn-3 `8396989a`→`4d392262` | Tách **ý chính** khỏi **minh hoạ**. Chỉ đổi đúng thứ được yêu cầu. Đổi lớn thì làm lát mỏng và gửi ảnh trước. |
| G11 | **Lộ ruột hệ thống ra UI** | mkn-3 `ebac43bf` (UUID), `f7d9b00b` (enum), `1869db90` (OUT_OF_SCOPE); SHT-CRM `50b592f` (lỗi PostgREST thô); AI-Assistant `f74f2d4` `[object Object]` | [INV] Không hiện id, uuid, enum, mã lỗi thô. Mọi enum có nhãn. Lỗi đi qua 1 hàm thân thiện dùng chung. |
| G12 | **Số liệu/màu/khuyến nghị dẫn tới hành vi sai** | ForFish `9e707896` (cá ngoài ranh giới → bà con chạy ra vi phạm), `910c54e4` (câu không có dữ liệu); IUU `25ff923` (tô theo độ lớn), `a69e382` (bỏ xếp hạng đỏ) | Mỗi con số, màu hay khuyến nghị khai **"đọc xong user sẽ làm gì"** và có dữ liệu chống lưng. Không dẫn user tới vi phạm. Xếp hạng hay màu đỏ chỉ dùng khi có ngưỡng do chủ dự án chốt. |

**Thêm 2 lỗi về điều hướng và quy trình duyệt** (đã có luật một phần, nay siết lại):

- **Thiếu đường về.** ForFish `5b5ba990` "làm sao quay về?". Audit `f4d8fea2`: Back thoát trang thay vì đóng sheet, làm mất chữ đang gõ; Đăng xuất 1 chạm là xoá dữ liệu.
  Luật mới: bảng **Điều hướng** bắt buộc. Back đóng lớp trên cùng trước và giữ dữ liệu đã gõ.
- **Spec dài được duyệt mù.** Luật mới: đầu spec có **Quyết định cần chủ dự án** tối đa 7 dòng. Đó là những thứ không hiển nhiên: vai, quyền, chặn hay cảnh báo, ai trả tiền, cái bị bỏ. Spec ghi trạng thái hiện tại; lịch sử để git giữ.

## Điều KHÔNG đổi (bằng chứng cho thấy đang chạy tốt)
- Rules R1..Rn cụ thể, test được (IUU `12-ba-spec` §9). Handoff có "điểm kết khi không ai nhận" (mkn-3 spec 08 H1–H4).
- Flow optimization log khi so phương án có căn cứ văn bản luật (AMS spec 19 §6).
- Toàn bộ BLOCK cũ của `ba-verify` / `design-verify` giữ nguyên: không đổi format mà project tiêu thụ đang dùng.

## Cơ chế ép (YELLOW: không chặn oan spec cũ)
- Spec tạo từ template mới mang dấu `<!-- spec-format: 2 -->`. Chỉ spec có dấu này mới bị BLOCK nếu thiếu mục mới (opt-in). Spec cũ không bị ảnh hưởng.
- Mọi spec, cũ hay mới, bị WARN nếu có hơn 20 comment `re-verified` (spec thành nhật ký) hoặc có heading Flow trùng.
- Nhận xét từ AMS: các skill grill-me, to-questionnaire, prototype không có bằng chứng cho BA tốt hơn. Chỉ **nội hoá ý tưởng** "đẩy câu chưa trả lời được cho đúng người quyết" và "lát mỏng trước spec dài". Viết lại, không chép (NOTICE.md).
