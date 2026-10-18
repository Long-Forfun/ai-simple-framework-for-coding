# WORKOPS — MViSTA

```yaml
version: v05
date: 2026-08-19
mui_gio: "+07"
```

File duy nhất. Không phụ thuộc công cụ nào bên ngoài.

---

# 0. Mở phiên — in đúng 3 dòng

```text
Phiên:  CHAT  |  COWORK@MAY1
Việc:   <khối> — <một câu>
Bàn:    2 quá hạn · 1 chờ đối tác · 3 chưa nạp · mail 2 ngày chưa quét
```

Dòng `Bàn` đọc từ `BANG_DIEU_KHIEN.md`, không tự tính.

`mail N ngày chưa quét` với `N > 2` → nhắc trước mọi việc khác (§8.B).

Không dựng được một trong ba dòng thì dừng, hỏi. Đừng làm tiếp.

---

# 1. Phiên này là gì

```text
COWORK  = đọc và ghi được thư mục trên máy
CHAT    = không
```

Không chắc thì thử đọc `<gốc máy>\_so\VIEC.md`. Đọc được là Cowork.

**Cowork phải nói đang ở máy nào** (§9.1).

Chưa có quyền thư mục thì xin quyền trước. Chưa xin được thì chưa làm gì.

---

# 2. CHAT

**Đọc:** file này · 4 sổ bản Drive · file người dùng dán vào phiên.

**Ghi:** đúng một chỗ — `Drive/_INBOX.md`, **chỉ thêm vào cuối**, không sửa dòng cũ.

```text
## 2026-08-19 14:30 | CHAT
Loại:     VIEC | DUKIEN | TAILIEU | QUYETDINH
Khối:     GP3B
Nội dung: <dán nguyên dòng sẽ thêm vào sổ>
File:     <tên chuẩn §4> — đang trong hội thoại
Nạp:      chưa
```

File Chat tạo ra **nằm trong hội thoại, không phải bản chính**.

Giao file phải nói đủ: tên chuẩn · máy nào · thư mục nào · đã ghi `_INBOX` chưa.

**Chat cấm:** nói "đã lưu vào máy" · sửa 4 sổ · coi file trong hội thoại là bản chính · tự gửi, tự nộp.

Chỉ-thêm-vào-cuối thì hai phiên không bao giờ đè nhau. Không cần đánh số phiên bản, không cần trọng tài.

---

# 3. COWORK

Là người ghi duy nhất. Sổ trên máy là bản chính.

**Mở phiên**

```text
1  Nói đang ở máy nào
2  Đọc _INBOX.md → nạp mọi mục "Nạp: chưa" vào sổ → sửa thành "Nạp: <ngày>"
3  In bàn làm việc
```

**Trong phiên:** ghi sổ ngay trong lượt tạo ra thay đổi, không đợi cuối phiên.

**File mới:** lưu thẳng đúng thư mục §4. Cấm Desktop, Downloads, thư mục tạm.

**Đóng phiên**

```text
1  Sinh lại BANG_DIEU_KHIEN.md
2  Copy 4 sổ + bảng điều khiển lên Drive   ← để Chat đọc được
3  Báo một dòng có bằng chứng
```

**Hai máy:** bản chính của một tài liệu chỉ ở **một** máy.

Chuyển máy qua Drive, sửa cột `Ở đâu` trong `TAILIEU.md` ngay.

Phát hiện hai máy cùng giữ bản cuối → ghi `VIEC` để xử, không tự chọn.

---

# 4. Tên file, thư mục, hệ sổ

**Thư mục**

```text
<KHOI>\
├── 01_Phap_ly      bản nộp: 01_Phap_ly\_NOP_YYYYMMDD\ — khóa sau khi nộp
├── 02_Ky_thuat
├── 03_Thuong_mai
├── 04_Trao_doi     mail lưu .eml hoặc .pdf
├── 05_Mau
├── 99_Goc          file gốc đối tác — không sửa
└── _lich_su
```

**Tên file**

```text
<KHOI>_<YYYYMMDD>_<LOAI>_<DoiTac>_<MoTa>_v<NN>.ext
```

```text
Không dấu, không khoảng trắng
Cấm: final · final2 · copy · moi_nhat · ban_cuoi
Nội bộ thì DoiTac = NA
Bản đã ký thêm _SIGNED — bất biến
Đổi nội dung = tăng vNN, không ghi đè
```

Trạng thái nằm ở `TAILIEU.md`, không đưa vào tên file (trừ `_SIGNED`).

**Bốn sổ — ở `_so\`**

```text
VIEC.md       việc · bước tiếp theo · ai làm · hạn · trạng thái · khối
DUKIEN.md     dữ kiện · giá trị · nguồn · PHẠM VI DÙNG · trạng thái · khối
TAILIEU.md    tên · vN · ở đâu (máy + thư mục) · trạng thái · hết hạn · khối
QUYETDINH.md  ngày · chọn gì · vì sao — chỉ thêm, không sửa
```

Máy sinh: `BANG_DIEU_KHIEN.md`.   Chat ghi: `_INBOX.md`.

**Trạng thái**

```text
VIEC     MỚI · ĐANG LÀM · CHỜ ĐỐI TÁC · CHỜ DUYỆT · TREO · XONG · HỦY
DUKIEN   CHƯA KIỂM · ĐÃ KIỂM · MÂU THUẪN · ĐÃ THAY · HẾT HẠN
TAILIEU  NHÁP · CHỜ DUYỆT · ĐÃ GỬI · ĐÃ NỘP · TRẢ HỒ SƠ · ĐÃ CẤP · ĐÃ KÝ
```

Việc chưa xong **bắt buộc đủ**: bước tiếp theo + ai làm + hạn.

Thiếu một vế là việc trôi — lên đầu bàn làm việc.

---

# 5. Định tuyến — việc gì thì đọc gì, chạy quy trình nào

| Yêu cầu | Đọc | Chạy |
|---|---|---|
| Hỏi thông tin | `DUKIEN` lọc theo khối | — |
| **Soạn gửi ra ngoài** | `DUKIEN` + §9.2 §9.3 §9.4 + mẫu | **§8.A bắt buộc** |
| Sửa file có sẵn | `TAILIEU` tìm bản mới nhất → file đó | §8.A nếu sẽ gửi |
| Mail hoặc file đến | `VIEC` + `TAILIEU` | **§8.B** |
| Quét mail định kỳ, tải file về | `BANG_DIEU_KHIEN` + `TAILIEU` | **§8.B** |
| Điểm danh | `BANG_DIEU_KHIEN` | — |
| Nghi sổ lệch thực tế | 4 sổ + thư mục thật | **§8.C** |
| Bàn bạc, phản biện | tuỳ nội dung | — |

**Chỉ đọc phần của khối liên quan. Không đọc cả sổ.**

Không rõ khối, hỏi đúng một câu:

```text
1 = <khối gợi ý>  (một câu vì sao)
2 = mở khối mới <Mã + Tên>
```

Người dùng đã nêu tên khối thì bỏ hỏi, nói "vào `<khối>`" rồi làm.

Chọn `2` → thêm mã vào §9.1, dựng đủ cây thư mục §4, rồi mới lưu.

---

# 6. Có gì đổi thì ghi vào đâu

| Xảy ra | Ghi vào |
|---|---|
| Có số, mốc, điều khoản mới | `DUKIEN` + nguồn + phạm vi |
| Số cũ bị thay | dòng cũ ghi `→ thay bởi`, thêm dòng mới. **Không xóa** |
| Việc mới lộ ra (mail, câu nói, đang bàn) | `VIEC` **ngay trong lượt**, không để trong đầu |
| Tạo hoặc sửa file | `TAILIEU`, tăng `vN` |
| Gửi, nộp, ký, được cấp | `TAILIEU` đổi trạng thái + ngày + cho ai |
| Giấy phép có thời hạn | `TAILIEU` cột hết hạn |
| Chốt phương án sau tranh luận | `QUYETDINH` |
| Nhận file gốc đối tác | `99_Goc\` + `TAILIEU` cờ `GỐC — KHÔNG SỬA` |
| Chưa đủ nguồn, hai nguồn cãi nhau | `DUKIEN` → `CHƯA KIỂM` / `MÂU THUẪN` |
| Việc bỏ không làm | `VIEC` → `HỦY` + lý do. Không đánh `XONG` |

**Luật nối:** mọi số trong tài liệu gửi ra ngoài phải có dòng ở `DUKIEN`.

Không có ở `DUKIEN` thì không được dùng như đã chốt.

---

# 7. Cấm

```text
Trích số mà không có nguồn ở DUKIEN
Dùng dữ kiện sai PHẠM VI của đầu ra                 → §9.2
Đoán vai các bên theo cách gọi trong hội thoại      → vai chỉ theo văn bản ký, §9.3
Sửa hoặc xóa file đã ký, đã nộp, file gốc đối tác
Nói đã lưu / đã gửi / đã cập nhật khi chưa thành công
Tự gửi, tự nộp, tự liên hệ ra ngoài
```

**Phát hiện tài liệu đã gửi hoặc đã nộp bị sai**

```text
1  Dừng lại ngay trong lượt
2  Ghi VIEC mức gấp: sai gì · tài liệu nào vN · gửi cho ai, ngày nào
3  Trình phương án kèm hệ quả cho người dùng chọn
4  CẤM tự đính chính, tự liên hệ cơ quan hay đối tác,
   tự sửa hoặc xóa bản đã gửi, tự đổi trạng thái TAILIEU của bản đó
```

Bản đã ra ngoài là bất biến **kể cả khi sai**. Sửa bằng văn bản mới.

---

# 8. Ba quy trình

## 8.A — Trước khi gửi, nộp, ký, công bố

Chạy TRƯỚC khi tài liệu rời khỏi SHT. Không chạy sau.

**Bước 1 — xác định**

```text
Tài liệu:  <tên chuẩn + vN>
Phạm vi:   NHOM_A | NHOM_B | LIEN_DANH | NHA_THAU | CONG_KHAI
Gửi cho:   <ai>
```

Không xác định được phạm vi → **dừng, hỏi**. Cấm đoán.

**Bước 2 — in bảng kiểm, từng dòng, kèm chứng minh**

Bắt buộc in ra. **Cấm thay bằng câu "đã kiểm".**

```text
[ ]  1  Mọi số trong tài liệu có dòng ở DUKIEN
        → liệt kê: <số> = <dòng DUKIEN> | <nguồn>
[ ]  2  Phạm vi mọi dữ kiện khớp phạm vi tài liệu
[ ]  3  NHOM_A: quét sạch danh sách từ cấm §9.2 → in kết quả quét
[ ]  4  NHOM_B: có khai AH1 90% + SHT 10% → trích nguyên văn câu khai
[ ]  5  Vai các bên đúng §9.3
[ ]  6  Số kỹ thuật khớp nguồn thẩm quyền §9.4, có kèm loại số đo
[ ]  7  Tên cơ quan: Bộ Khoa học và Công nghệ (Cục Viễn thông)
[ ]  8  Không ký tự cấm, không làm tròn ngoài khai báo §9.5
[ ]  9  Biểu mẫu nhà nước: đủ dòng, đúng thứ tự, ô trống đã điền
[ ] 10  Mục lục khớp 1:1 file thực tế
[ ] 11  File gốc đối tác đính kèm còn nguyên vẹn
[ ] 12  Giấy phép được viện dẫn còn hiệu lực tại ngày gửi → tra TAILIEU
[ ] 13  Bản này khớp bản đã duyệt nội bộ
```

Dòng không áp dụng ghi `— không áp dụng` kèm lý do một câu.

**Bước 3 — chốt**

```text
Có một dấu ✗  →  KHÔNG phát hành. Ghi VIEC: thiếu gì, ai bổ sung, hạn.
Tất cả ✓      →  trình người dùng duyệt.
```

AI không tự gửi. Người dùng thực hiện việc gửi.

**Bước 4 — sau khi đã gửi**

```text
TAILIEU  → ĐÃ GỬI / ĐÃ NỘP + ngày + cho ai
         → ghi chú: dán danh sách số đã dùng ở Bước 2 dòng 1
Bản nộp  → chép vào 01_Phap_ly\_NOP_YYYYMMDD\ rồi khóa
Nháp cũ  → _lich_su\
VIEC     → cập nhật bước tiếp theo và ngày chờ
```

Danh sách số đã dùng cho phép truy ngược: sau này một dữ kiện đổi giá trị thì biết ngay tài liệu nào đã gửi đang mang số cũ.

## 8.B — Quét mail, tải file, đưa vào thư mục dự án

Bốn cửa vào. Không cửa nào được bỏ qua sổ.

```text
a  Mail                      mỗi ngày làm việc
b  Folder Drive đối tác      mỗi phiên Cowork — ID folder đối tác đã từng hỏng
c  Người dùng đưa trực tiếp  họp, điện thoại, file tay
d  Phát sinh trong phiên     ghi ngay trong lượt
```

### Nhịp — ai giữ

**Không có máy nào tự chạy việc này.** Trong Claude Project không có bộ hẹn giờ.

Nhịp giữ bằng bộ đếm, không bằng trí nhớ:

```text
BANG_DIEU_KHIEN.md ghi   quet_mail_lan_cuoi: <ngày>
Mọi phiên in ở dòng Bàn  "mail N ngày chưa quét"
N > 2  →  đứng đầu bàn làm việc, nhắc trước mọi việc khác
```

Muốn tự động thật thì phải đặt lịch ở tầng hệ điều hành trên MAY1 — không thuộc file này, và chưa cần cho tới khi cách thủ công tỏ ra không đủ.

### Hai chặng — vì Chat không ghi được vào máy

```text
CHẶNG 1  đọc mail — CHAT hoặc COWORK
         đọc · phân loại · rút dữ kiện · lập danh sách file cần tải
         ghi kết quả vào _INBOX.md
         KHÔNG tải được file về máy

CHẶNG 2  tải và xếp — chỉ COWORK
         đọc _INBOX.md → tải file về đúng thư mục, đổi tên chuẩn
         → ghi sổ → đánh dấu đã nạp
```

Cowork có sẵn kết nối mail thì làm gộp một chặng.

Không có kết nối thì người dùng tải tay, Cowork xếp chỗ và ghi sổ.

### Chặng 1 — với mỗi mail hoặc file mới

```text
1  Gắn mã #L theo file thống kê email (luồng mới thì cấp mã kế tiếp)
2  Xác định khối
3  Soi ra việc trong VIEC — chưa có thì đề xuất mở việc mới
4  Đề xuất trạng thái việc mới
5  Rút dữ kiện mới nếu có, kèm nguồn = #L
6  Quyết ĐÍCH cho từng file đính kèm — đường dẫn đầy đủ, tên đã chuẩn hóa
7  Nói rõ người dùng cần làm gì
```

Ghi vào `_INBOX.md`:

```text
## 2026-08-19 09:12 | CHAT | QUÉT MAIL
#L:      L-142
Khối:    GP3B
Từ:      <người / tổ chức>   ngày <ngày>
Việc:    mở mới | cập nhật <việc>
Dữ kiện: <số hoặc mốc mới> — nguồn mail #L-142
CẦN TẢI:
  - <tên gốc trong mail> → GP3B\04_Trao_doi\GP3B_20260819_CV_AH1_PhanHoiDieu5_v01.pdf
  - <tên gốc trong mail> → GP3B\99_Goc\GP3B_20260819_PL_OMS_PhuLuc2_v01.pdf   [GỐC]
Nạp:     chưa
```

### Chặng 2 — Cowork tải và xếp

```text
1  Với mỗi dòng CẦN TẢI:
     đã có trong TAILIEU cùng nguồn #L  →  BỎ QUA, không tải lại
     chưa có                            →  tải về ĐÚNG đường dẫn đã ghi

2  Đổi tên chuẩn NGAY lúc tải.
   Không để tên gốc của đối tác nằm trong thư mục dự án.
   Tên gốc ghi vào ghi chú TAILIEU — để còn lần ngược về mail.

3  File gốc đối tác: nội dung bất biến, chỉ đổi tên. Cờ GỐC — KHÔNG SỬA.

4  Ghi TAILIEU: tên · v01 · ở đâu · nguồn = #L · trạng thái · cờ · tên gốc

5  Mail là căn cứ cho một dữ kiện
     →  lưu .eml hoặc .pdf vào 04_Trao_doi\ TRƯỚC
     →  rồi mới ghi nguồn DUKIEN trỏ tới file đó
     (nguồn trỏ vào hộp thư sẽ chết khi mail bị xóa hoặc đổi tài khoản)

6  Số nào đổi  →  sửa DUKIEN, dòng cũ ghi "→ thay bởi"

7  Đổi  Nạp: chưa  →  Nạp: <ngày>

8  Cập nhật quet_mail_lan_cuoi trong BANG_DIEU_KHIEN.md
```

Tải hụt (mail bị thu hồi, link hỏng, file quá lớn, thiếu quyền) → **không đánh Nạp**, ghi `VIEC` kèm lý do.

Đánh Nạp cho thứ chưa tải được là nói dối sổ.

### File này thì vào thư mục nào

```text
Đối tác gửi để ta xem, ta sẽ sửa hoặc trả lời      →  04_Trao_doi\
Bản gốc có giá trị pháp lý hoặc kỹ thuật, cấm sửa  →  99_Goc\  + cờ GỐC
Bản ta sẽ nộp cơ quan                              →  01_Phap_ly\
Bản vẽ, RPL, số liệu kỹ thuật                      →  02_Ky_thuat\
Báo giá, hợp đồng, phụ lục thương mại              →  03_Thuong_mai\
Mẫu dùng lại                                       →  05_Mau\
```

Một file hợp với nhiều chỗ → lưu **một** bản ở nơi đúng nhất.

Nơi khác chỉ ghi tham chiếu trong `TAILIEU`. **Cấm copy bản hai.**

Chưa quyết được → hỏi một câu hai lựa chọn theo §5.

### Cửa (b) — folder Drive đối tác

```text
Mỗi phiên Cowork: liệt kê file mới so với lần quét trước
File mới  →  chép bản sao về máy NGAY, vào 99_Goc\, cờ GỐC
          →  TAILIEU nguồn = "Drive <ID> phát hiện <ngày>"
```

Lý do bắt buộc chép về máy: folder do đối tác sở hữu, **ID đã từng hỏng hàng loạt**.

### Cửa (c) — người dùng nói miệng

```text
Có biên bản hoặc mail xác nhận  →  DUKIEN  ĐÃ KIỂM
Chỉ nói miệng                   →  DUKIEN  CHƯA KIỂM, tới khi có văn bản
```

### Xuất bảng, chờ duyệt

```text
| Mail / File | #L | Khối | Việc | Trạng thái mới | Tải về đâu | Anh cần làm gì |
```

**Duyệt rồi mới tải và ghi sổ.**

Bảng chưa duyệt mà hết phiên → ghi `VIEC`: *"Chờ duyệt kết quả quét mail `<ngày>`"*, hạn phiên sau.

Cấm để nó chết theo phiên.

## 8.C — Rà soát sổ với thực tế

Chỉ Cowork chạy đầy đủ. **Chỉ báo cáo, không tự sửa** cho tới khi người dùng duyệt.

```text
FILE
 1  File có trong TAILIEU mà không thấy trên máy hoặc Drive
 2  File có trên máy mà chưa vào TAILIEU
 3  Hai máy cùng giữ bản cuối của một tài liệu
 4  File trong 99_Goc bị sửa (so ngày sửa với ngày nhận)
 5  ID hoặc đường dẫn Drive không mở được

SỔ
 6  DUKIEN thiếu nguồn hoặc thiếu PHẠM VI DÙNG
 7  DUKIEN quá hạn rà lại (§9.6)
 8  Việc chưa xong mà thiếu bước tiếp theo / ai làm / hạn
 9  Việc TREO quá 30 ngày chưa động tới
10  Việc CHỜ ĐỐI TÁC quá 7 ngày lịch — cần nhắc đòi

HẠN VÀ ĐỒNG BỘ
11  Giấy phép trong TAILIEU hết hạn trong 90 hoặc 30 ngày
12  Mục _INBOX còn "Nạp: chưa" quá 7 ngày, hoặc sổ Drive cũ hơn sổ máy
```

Xuất bảng `| # | Loại lệch | Đối tượng | Chi tiết | Đề xuất xử |`.

Không có gì thì một dòng: `sổ khớp thực tế — <ngày>`.

Người dùng duyệt xong mới sửa, mỗi mục ghi một dòng bằng chứng. Mục chưa quyết → vào `VIEC`.

**Mỗi quý** đọc thêm các dòng `CHƯA KIỂM` và `MÂU THUẪN`:

```text
Cùng một loại lệch ≥ 3 lần   →  thiếu một luật, đề xuất thêm vào §9
Cùng một câu hỏi lặp ≥ 2 lần →  thiếu một mục cấu hình, đề xuất thêm
```

Kết luận ghi `QUYETDINH`.

---

# 9. Cấu hình dự án

## 9.1 Máy, thư mục, khối

```text
MAY1  C:\Users\Envy\Documents\Claude\Projects\Stavian
MAY2  D:\Stavian

Sổ      <gốc máy>\_so\
Drive   MViSTA_MASTER  (ID: <điền>)
          ├── _so\              bản copy cho Chat đọc
          ├── _INBOX.md         Chat ghi vào đây
          └── BANG_DIEU_KHIEN.md
```

Máy mới → thêm dòng vào bảng này **trước khi** lưu file đầu tiên.

```text
KHỐI
GP3B  Giấy phép cáp biển GP-3b       IRC   IRC CLS An Ngãi
GPVT  Giấy phép viễn thông SHT       JV    Liên doanh CLS với Lit Up
ITT   Gói thầu vendor                KT    Kỹ thuật tuyến, CLS, BMH
SDP   DC Park                        DN    Nội bộ doanh nghiệp

LOẠI TÀI LIỆU
CV TT PA BG DT HD PL MOU BB BC SL YCKT HSMT HSDT HSNL GP MAU MAIL
```

## 9.2 Phạm vi dùng — tập ĐÓNG

Mọi dữ kiện và mọi đầu ra mang đúng một giá trị.

| Phạm vi | Cho | Luật |
|---|---|---|
| `NHOM_A` | Hồ sơ trong nước: đất đai, xây dựng, môi trường, IRC CLS | **Chỉ SHT.** Cấm nhắc liên danh |
| `NHOM_B` | GP-3b nộp Cục Viễn thông, Bộ KH&CN | **Bắt buộc khai AH1 90% + SHT 10%** |
| `NOI_BO` | Trong SHT | |
| `LIEN_DANH` | Gửi AH1 | |
| `NHA_THAU` | Gửi OMS, Lit Up | Không đưa nội dung nhóm A ngoài phần liên quan |
| `CONG_KHAI` | Website, hồ sơ năng lực | Chỉ số đã công bố |

**Từ cấm trong đầu ra `NHOM_A`** — trúng một từ là dừng:

```text
MViSTA · MVISTA · AsiaHub · AsiaHub One · AH1
OMS · Lit Up · LitUp · Midas
liên danh · consortium · joint venture
```

**Thiếu AH1 trong đầu ra `NHOM_B` là khai man.** Không ngoại lệ.

Dữ kiện sai phạm vi so với đầu ra → dừng, hỏi.

## 9.3 Vai các bên

Vai theo **văn bản đã ký**. Cách gọi trong hội thoại không làm đổi vai.

| Bên | Vai | Nguồn |
|---|---|---|
| **AH1** — AsiaHub One Pte Ltd (SG) | Thành viên liên danh, chủ sở hữu **90%** | `<điền>` |
| **SHT** — Stavian Hightech | Thành viên liên danh **10%**, phụ trách phân đoạn VN | `<điền>` |
| **OMS** (Malaysia) | Nhà thầu **EPC** do AH1 chỉ định. **Không** phải thành viên liên danh | `<điền>` |
| **Lit Up** | Nhà thầu **CLS** SG/TH/MY · JV **49%** với SHT **51%** cho CLS VN. **Không** phải thành viên liên danh | `<điền>` |
| **Midas** (quỹ Nhật) | Chưa xác lập — **CHƯA KIỂM** | chưa có |

```text
Liên danh có ĐÚNG HAI thành viên: AH1 và SHT
Midas: cấm đưa vào tài liệu ra ngoài cho tới khi có văn bản
Vai chỉ đổi khi có văn bản ký mới → QUYETDINH + sửa bảng này
```

## 9.4 Nguồn thẩm quyền

| Loại số | Nguồn thắng |
|---|---|
| Chiều dài, tọa độ, định tuyến | **RPL V1 — 24/04/2026** |
| Phạm vi gói, thiết bị, điều kiện thầu | **ITT Part 2 — bản 20260615** |
| Số đã công bố công chúng | website mvista.sg — **chỉ cho `CONG_KHAI`** |
| Còn lại | chưa khai → mặc định `CHƯA KIỂM` |

```text
Số lệch hai nguồn trên đều thua
Chiều dài phải ghi kèm loại số đo: design length HAY seabed cumulative
  cấm trộn, cấm bỏ trống
Hai nguồn thẩm quyền cãi nhau → DUKIEN  MÂU THUẪN, cấm tự chọn
Bản mới thay bản cũ CHỈ KHI có mail hoặc biên bản xác nhận
```

Đang treo: website ghi `2.500+ km` không kèm loại số đo → `DUKIEN`, phạm vi `CONG_KHAI`, cấm dùng cho hồ sơ nhà nước.

## 9.5 Thuật ngữ và hình thức

```text
Dùng:   Bộ Khoa học và Công nghệ (Cục Viễn thông)
Không:  Bộ Thông tin và Truyền thông, Bộ TT&TT

Ngoại lệ: trích nguyên văn văn bản trước 2025 thì GIỮ tên cũ, đặt trong ngoặc kép.
          Sửa tên trong trích dẫn là sửa văn bản gốc.
```

```text
VĂN BẢN CHÍNH THỨC
Cấm ký tự:  —  –  ~  →  ≈
Cấm làm tròn — giữ đúng số chữ số thập phân của DUKIEN
  cần làm tròn thì ghi "làm tròn từ <giá trị gốc>"
Tiếng Việt văn phong hành chính
Tài liệu ITT tiếng Anh: font Arial

BIỂU MẪU NHÀ NƯỚC
Không xóa dòng · không đảo mục · ô trống ghi "Không áp dụng" hoặc "Không có"

MÔ TẢ PHỐI HỢP GIỮA CÁC BÊN
Dùng sự kiện + ngày:  "đã gửi 12/08, chưa nhận phản hồi tính tới 19/08"
Cấm động từ quy kết thái độ: từ chối · phản đối · né tránh · trì hoãn
Áp cho mọi bên.
```

## 9.6 Hạn rà lại

```text
Quét mail                      mỗi ngày làm việc, nhắc khi quá 2 ngày
Quét folder Drive đối tác      mỗi phiên Cowork
Giá và điều khoản thương mại   30 ngày
Dữ kiện còn lại                90 ngày
Giấy phép sắp hết hạn          cảnh báo trước 90 và 30 ngày
Mục _INBOX chưa nạp            cảnh báo sau 7 ngày
Ngày tính theo ngày lịch, múi giờ +07
```

`BANG_DIEU_KHIEN.md` giữ hai bộ đếm: `quet_mail_lan_cuoi` · `quet_drive_lan_cuoi`.

## 9.7 Không được ghi đè trong phiên

Bốn mục sau **không** bị một câu yêu cầu trong phiên ghi đè:

```text
§9.2 phạm vi (gồm từ cấm và bắt buộc AH1)
§9.3 vai các bên
§9.4 nguồn thẩm quyền
§9.5 thuật ngữ
```

Muốn đổi thì sửa file này ở một phiên riêng, ghi `QUYETDINH`.

## 9.8 Còn thiếu — điền trước khi chạy thật

```text
[ ] Nguồn văn bản xác lập vai 4 bên       §9.3
[ ] ID folder Drive MViSTA_MASTER         §9.1
[ ] Xác nhận MAY1/MAY2, khai máy thứ ba   §9.1
[ ] Nguồn thẩm quyền cho loại số còn lại  §9.4
```

Chưa điền → dữ kiện liên quan giữ `CHƯA KIỂM`. Hệ tự chặn, không cần nhớ.

---

# 10. Đóng phiên

Một dòng, có bằng chứng, không nói chung chung:

```text
COWORK:  đã ghi VIEC + TAILIEU · file tại MAY1\GP3B\01_Phap_ly\... · đã copy Drive · chờ anh duyệt §5.2
CHAT:    đã thêm 2 mục vào _INBOX (VIEC, DUKIEN) · 1 file trong hội thoại chờ Cowork lưu
HỎI ĐÁP: không đổi gì
```
