```yaml
profile_for: MVISTA
workops_version: v02
profile_version: v01
effective_date: 2026-08-19
timezone: "+07"
concurrency: single
```

> Cấu hình dự án. Luật chung ở `WORKOPS.md`.
> Mục nằm trong `invariant_rules` không bị yêu cầu trong phiên ghi đè.

---

# 1. Dự án

```yaml
project:
  code: MVISTA
  name: Tuyến cáp biển MViSTA — Việt Nam, Thái Lan, Malaysia, Singapore
```

---

# 2. Phạm vi — `scopes`

Tập giá trị ĐÓNG. Mọi Fact và mọi đầu ra phải mang đúng một giá trị.

| Scope | Dùng cho | Luật |
|---|---|---|
| `NHOM_A` | Hồ sơ thuần trong nước: đất đai, xây dựng, môi trường, IRC CLS | Chỉ SHT. Cấm nhắc liên danh |
| `NHOM_B` | GP-3b nộp Cục Viễn thông, Bộ KH&CN | **Bắt buộc khai AH1 90% + SHT 10%** |
| `NOI_BO` | Nội bộ SHT | Tự do trong khuôn khổ style_rules |
| `DOI_TAC_LIEN_DANH` | Gửi AH1 | Đủ vai theo §3 |
| `DOI_TAC_NHA_THAU` | Gửi OMS, Lit Up | Không tiết lộ nội dung nhóm A ngoài phần liên quan |
| `CONG_KHAI` | Website, thông cáo, hồ sơ năng lực | Chỉ số đã công bố |

**Chặn từ khóa cho `NHOM_A`** — quét trước khi xuất, trúng một từ là dừng:

```text
MViSTA · MVISTA · AsiaHub · AsiaHub One · AH1
OMS · Lit Up · LitUp · Midas
liên danh · consortium · joint venture
```

**Thiếu AH1 trong đầu ra `NHOM_B` là khai man.** Kiểm bắt buộc, không có ngoại lệ.

Soạn ra ngoài mà phạm vi Fact không khớp phạm vi đầu ra → dừng, hỏi.

---

# 3. Vai các bên — `roles`

Vai theo **văn bản đã ký**, không theo cách gọi trong hội thoại.

| Actor | Vai | Nguồn xác lập | Trạng thái |
|---|---|---|---|
| **AH1** — AsiaHub One Pte Ltd (Singapore) | Thành viên liên danh, chủ sở hữu **90%** | `<điền: văn bản liên danh + ngày>` | VERIFIED |
| **SHT** — Stavian Hightech | Thành viên liên danh **10%**, phụ trách phân đoạn VN | `<điền>` | VERIFIED |
| **OMS** (Malaysia) | **Nhà thầu EPC** do AH1 chỉ định. KHÔNG phải thành viên liên danh | `<điền>` | VERIFIED |
| **Lit Up** | **Nhà thầu CLS** SG/TH/MY · đối tác JV **49%** với SHT **51%** cho CLS VN. KHÔNG phải thành viên liên danh | `<điền>` | VERIFIED |
| **Midas** (quỹ Nhật Bản) | Chưa xác lập | Chưa có | **UNVERIFIED** |

**Luật vai:**

```text
1  Liên danh có ĐÚNG HAI thành viên: AH1 và SHT
2  Cách gọi trong hội thoại, mail nội bộ, slide KHÔNG làm đổi vai
   — kể cả khi người dùng gọi Lit Up hay Midas là "thành viên"
3  Vai chỉ đổi khi có văn bản ký mới → Decision + R1
4  Midas: cấm đưa vào mọi tài liệu ra ngoài cho tới khi có văn bản nguồn
```

---

# 4. Khối việc — `workstreams`

```text
GP3B   Giấy phép cáp biển GP-3b
IRC    IRC CLS An Ngãi
GPVT   Giấy phép viễn thông SHT
JV     Liên doanh CLS với Lit Up
ITT    Gói thầu vendor
KT     Kỹ thuật tuyến, CLS, BMH
SDP    DC Park
DN     Nội bộ doanh nghiệp
```

Việc mới chưa thuộc khối nào → hỏi đúng một câu hai lựa chọn:

```text
1 = lưu vào <khối>\<thư mục con>   (kèm một câu vì sao)
2 = mở khối mới <Mã + Tên đề xuất>
```

Chọn 2 → thêm mã vào bảng này, dựng đủ cây thư mục §9, khai R2, mở Work, rồi mới lưu.

Khớp hiển nhiên (người dùng đã nêu tên khối) → bỏ hỏi, nói "lưu vào `<khối>`" rồi làm.

---

# 5. Nguồn thẩm quyền — `source_authority`

Theo **từng loại dữ kiện**, không có thứ tự chung toàn hệ.

| Loại dữ kiện | Nguồn thắng | Ghi chú |
|---|---|---|
| Chiều dài, tọa độ, định tuyến | **RPL V1 — 24/04/2026** | Bắt buộc ghi kèm loại số đo |
| Phạm vi gói, thông số thiết bị, điều kiện thầu | **ITT Part 2 — bản 20260615** | |
| Số đã công bố ra công chúng | Website mvista.sg | **Chỉ dùng cho scope `CONG_KHAI`** |
| Còn lại | Chưa khai — mặc định `UNVERIFIED` | |

**Luật nguồn:**

```text
1  Số lệch hai nguồn thẩm quyền trên đều thua
2  Chiều dài ghi kèm loại số đo: design length HAY seabed cumulative
   — cấm trộn, cấm bỏ trống
3  Hai nguồn thẩm quyền mâu thuẫn NGOÀI hai lớp đã phân trên
   → Exception SOURCE_CONFLICT, cấm tự chọn bên nào
4  Bản mới thay bản cũ CHỈ KHI có mail hoặc biên bản xác nhận
   → Decision + Fact "→ thay bởi". Trước đó bản cũ vẫn là thẩm quyền
```

Ví dụ đang treo: website công bố `2.500+ km` không kèm loại số đo → `F-MVISTA-001`, scope `CONG_KHAI`, cấm dùng cho `NHOM_A` / `NHOM_B`.

---

# 6. Thuật ngữ — `terminology`

| Dùng | Không dùng |
|---|---|
| Bộ Khoa học và Công nghệ (Cục Viễn thông) | Bộ Thông tin và Truyền thông, Bộ TT&TT |

**Ngoại lệ bắt buộc:** trích nguyên văn văn bản ban hành **trước 2025** thì giữ nguyên tên tại thời điểm đó, đặt trong ngoặc kép.

Cấm "hiện đại hóa" tên cơ quan trong trích dẫn — đó là sửa văn bản gốc.

---

# 7. Hình thức — `style_rules`

**Văn bản chính thức**

```text
Cấm ký tự: — – ~ → ≈ ⇒ ↔
Cấm làm tròn: giữ đúng số chữ số thập phân của Fact
  Cần làm tròn thì ghi rõ "làm tròn từ <giá trị gốc>"
Tiếng Việt văn phong hành chính
```

**Tài liệu tiếng Anh ITT**

```text
Font Arial
```

**Biểu mẫu nhà nước**

```text
Không xóa dòng
Không đảo mục
Ô trống ghi "Không áp dụng" hoặc "Không có"
```

**Mô tả phối hợp giữa các bên**

```text
Dùng sự kiện + ngày:
  "đã gửi 12/08, chưa nhận phản hồi tính tới 19/08"

Cấm động từ quy kết thái độ cho bất kỳ bên nào:
  từ chối · phản đối · né tránh · trì hoãn · không hợp tác

Áp cho mọi bên, không riêng OMS.
```

---

# 8. Luật không được ghi đè — `invariant_rules`

```text
scopes            §2 toàn bộ, gồm chặn từ khóa và bắt buộc AH1 ở NHOM_B
roles             §3 toàn bộ
source_authority  §5 luật 1, 2, 3
terminology       §6
```

Yêu cầu trong phiên **không** ghi đè được bốn mục trên.

Đổi = sửa Profile này ở một phiên riêng + một Decision.

---

# 9. Lưu trữ — `storage`

```yaml
storage:
  POLICY:            "Claude Project / WORKOPS.md"
  PROFILE:           "Claude Project / PROJECT_PROFILE_MViSTA.md"
  STATE_CANONICAL:   "MAY1:\\Stavian\\_state\\"
  SOURCE_CANONICAL:  "<khối>\\99_Nguon_goc\\"
  ARTIFACT_CANONICAL:"<khối>\\<thư mục con>\\"
  TEMPLATE:          "<khối>\\05_Mau_dung_lai\\"
  GENERATED:         "MAY1:\\Stavian\\_generated\\"
  EXCHANGE:          "Drive: MViSTA_MASTER"
  CHAT_INBOX:        "Drive: MViSTA_MASTER\\_inbox\\"
  SNAPSHOT:          "Drive: MViSTA_MASTER\\_snapshot\\"
  ARCHIVE:           "<khối>\\_lich_su\\"

machines:
  MAY1: "C:\\Users\\Envy\\Documents\\Claude\\Projects\\Stavian"
  MAY2: "D:\\Stavian"

drive_folder_id: "<điền ID folder MViSTA_MASTER>"
```

Máy mới → khai thêm dòng vào `machines` TRƯỚC khi lưu file đầu tiên.

**Cây mỗi khối**

```text
01_Phap_ly       (bản nộp: 01_Phap_ly\_NOP_YYYYMMDD\ — khóa sau khi nộp)
02_Ky_thuat
03_Thuong_mai
04_Trao_doi      (.eml / .pdf của mail là nguồn)
05_Mau_dung_lai
99_Nguon_goc     (bản gốc đối tác — bất biến, có hash)
_lich_su
```

**Chống phân mảnh**

```text
File thuộc khối nào lưu gốc khối đó. Nơi dùng chỉ tham chiếu, không copy bản hai.
Cấm hai máy cùng giữ hai bản canonical.
  Phát hiện → Exception DUAL_CANONICAL
  Phân xử: vN cao thắng · vN bằng thì ngày mới thắng · cả hai bằng thì KHÔNG tự chọn
Chuyển máy qua exchange:// hoặc copy tay, R2 đổi vị trí canonical ngay.
```

---

# 10. Tên file — `file_naming`

```text
<MaKhoi>_YYYYMMDD_<LOAI>_<DoiTac>_<MoTa>_vNN[_SIGNED].ext
```

```text
LOAI:  CV TT PA BG DT HD PL MOU BB BC SL YCKT HSMT HSDT HSNL GP MAU MAIL
```

**Chỉ `_SIGNED` được vào tên file** (bản bất biến, thuộc danh tính bản ký).

`DRAFT` và `SENT` sống ở R2, cấm đưa vào tên — hai nơi giữ trạng thái là hai nơi lệch nhau.

```text
Không dấu · không khoảng trắng · không final / copy / moi_nhat
DoiTac để NA khi nội bộ
```

Tài liệu trong Claude Project giữ hệ tên cũ `Ten_file_vN_YYYYMMDD` (chuẩn hóa 18/08).

---

# 11. Cửa vào — `intake_channels`

| Kênh | Nhịp | Mã tham chiếu | Xử lý |
|---|---|---|---|
| Mail | Hằng ngày | `#L` theo `ThongKe_Email_MViSTA_theo_luong` (2 cột KHỐI + WORK ID) | §11.1 |
| Folder Drive đối tác | Mỗi phiên Cowork | ID folder + ngày phát hiện | §11.2 |
| Người dùng đưa trực tiếp | Ngay khi phát sinh | — | §11.3 |
| Phiên làm việc | Trong lượt | Session ID | Theo WorkOps §4 |

## 11.1 Mail

```text
Gắn #L (luồng mới cấp mã kế tiếp)
→ soi ra Work, chưa có thì đề xuất mở
→ đề xuất trạng thái mới
→ ghi rõ người dùng cần làm gì

Đính kèm: lưu đúng khối theo §10
  bản trao đổi   → 04_Trao_doi\
  gốc đối tác    → 99_Nguon_goc\ , bất biến, tính hash
  R2 nguồn = #L
  làm đổi dữ kiện → sửa R3 ngay

Xuất bảng:  Mail · #L · Work · Trạng thái mới · Lưu đâu · Cần làm gì
Duyệt rồi mới ghi sổ.
```

**Bảng chưa được duyệt → Exception "chờ duyệt quét mail <ngày>".**

Cấm để nó chết theo phiên.

## 11.2 Folder Drive đối tác

```text
File mới → R2 với nguồn = "Drive <ID> phát hiện <ngày>"
  bất biến · tính hash · chép ngay bản sao về máy
```

Lý do có luật này: ID folder do đối tác sở hữu **đã từng hỏng hàng loạt**.

## 11.3 Người dùng đưa trực tiếp

```text
Có biên bản hoặc mail xác nhận → Fact VERIFIED / Work
Chỉ nói miệng                   → Fact UNVERIFIED, cho tới khi có văn bản
```

---

# 12. Bảng kiểm trước phát hành — `control_checks`

Tầng CHẶT của WorkOps §6 **bắt buộc in ra từng dòng** kèm chứng minh.

Một dấu `✗` là không phát hành.

```text
[ ] 1  Mục lục khớp 1:1 với file thực tế
[ ] 2  Đầu ra NHOM_B có khai AH1 90% + SHT 10%
[ ] 3  Đầu ra NHOM_A sạch toàn bộ danh sách chặn từ khóa §2
[ ] 4  Tên cơ quan đúng: Bộ Khoa học và Công nghệ (Cục Viễn thông)
[ ] 5  Mọi số khớp nguồn thẩm quyền §5, có kèm loại số đo
[ ] 6  Mọi số trích từ Fact có scope khớp scope đầu ra
[ ] 7  File gốc đối tác nguyên vẹn — hash không đổi
[ ] 8  Vai các bên đúng §3
[ ] 9  Không có ký tự cấm, không làm tròn ngoài khai báo §7
[ ] 10 Bản nộp khớp bản đã duyệt nội bộ, có số công văn đi
[ ] 11 Giấy phép viện dẫn còn hiệu lực tại ngày nộp
```

In kèm `facts_used` của Artifact Receipt.

---

# 13. Hạn rà lại — `freshness_rules`

```yaml
freshness_rules:
  fact_gia_thuong_mai: 30      # ngày
  fact_con_lai: 90             # ngày
  artifact_valid_until_canh: [90, 30]   # cảnh báo trước khi hết hiệu lực
  changeset_chua_nap_canh: 7
  pending_persist_canh: 3
```

---

# 14. Runtime — `runtime_capabilities`

```yaml
runtime_capabilities:
  COWORK:
    canonical_writer: true
    ghi_duoc: [state, artifact, source, template, generated, archive, snapshot]
    doc_ghi_may: "chỉ máy đang chạy"
  CHAT:
    canonical_writer: false
    ghi_duoc: [inbox, exchange, snapshot]
    cam: [state, artifact, source]
```

Lệnh ghi Drive cần người dùng duyệt trên giao diện.

Chưa chạy thành công thì **chưa tính là đã ghi** — nói rõ "đang chờ duyệt".

---

# 15. Khắc phục — `remediation`

```yaml
remediation:
  nguoi_quyet: "<điền: Trưởng ban / người có thẩm quyền>"
  phap_che: "<điền>"
  dau_moi_AH1: "<điền>"
```

Khi RECALL (WorkOps §12) kích hoạt, AI **chỉ** trình phương án.

Mọi liên hệ ra ngoài do người có thẩm quyền thực hiện.

---

# 16. Còn thiếu — điền trước khi chạy thật

```text
[ ] Nguồn văn bản xác lập vai cho AH1, SHT, OMS, Lit Up  (§3)
[ ] ID folder Drive MViSTA_MASTER                         (§9)
[ ] Xác nhận MAY1 / MAY2 còn đúng, khai máy thứ ba nếu có (§9)
[ ] Người quyết và pháp chế                               (§15)
[ ] Nguồn thẩm quyền cho các loại dữ kiện chưa khai       (§5)
```

Mục chưa điền → mọi Fact liên quan giữ `UNVERIFIED`.
