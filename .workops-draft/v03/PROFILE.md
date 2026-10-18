# PROFILE — MViSTA

```yaml
project: MVISTA
workops: v03
date: 2026-08-19
mui_gio: "+07"
```

Cấu hình dự án. Luật chung ở `WORKOPS.md`.

---

## 1. Máy và thư mục

```text
MAY1  C:\Users\Envy\Documents\Claude\Projects\Stavian
MAY2  D:\Stavian

Sổ         <gốc máy>\_so\
Drive      MViSTA_MASTER  (ID: <điền>)
             ├── _so\              bản copy cho Chat đọc
             ├── _INBOX.md         Chat ghi vào đây
             └── BANG_DIEU_KHIEN.md
```

Máy mới → thêm dòng vào bảng này **trước khi** lưu file đầu tiên.

---

## 2. Khối

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

## 3. Loại tài liệu

```text
CV TT PA BG DT HD PL MOU BB BC SL YCKT HSMT HSDT HSNL GP MAU MAIL
```

---

## 4. Phạm vi dùng — tập ĐÓNG

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

---

## 5. Vai các bên

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
Vai chỉ đổi khi có văn bản ký mới → ghi QUYETDINH + sửa bảng này
```

---

## 6. Nguồn thẩm quyền

| Loại số | Nguồn thắng |
|---|---|
| Chiều dài, tọa độ, định tuyến | **RPL V1 — 24/04/2026** |
| Phạm vi gói, thiết bị, điều kiện thầu | **ITT Part 2 — bản 20260615** |
| Số đã công bố công chúng | website mvista.sg — **chỉ dùng cho `CONG_KHAI`** |
| Còn lại | chưa khai → mặc định `CHƯA KIỂM` |

```text
Số lệch hai nguồn trên đều thua
Chiều dài phải ghi kèm loại số đo: design length HAY seabed cumulative
  cấm trộn, cấm bỏ trống
Hai nguồn thẩm quyền cãi nhau → DUKIEN trạng thái MÂU THUẪN, cấm tự chọn
Bản mới thay bản cũ CHỈ KHI có mail hoặc biên bản xác nhận
```

Đang treo: website ghi `2.500+ km` không kèm loại số đo → `DUKIEN`, phạm vi `CONG_KHAI`, cấm dùng cho hồ sơ nhà nước.

---

## 7. Thuật ngữ và hình thức

```text
Dùng:     Bộ Khoa học và Công nghệ (Cục Viễn thông)
Không:    Bộ Thông tin và Truyền thông, Bộ TT&TT

Ngoại lệ: trích nguyên văn văn bản trước 2025 thì GIỮ tên cũ, đặt trong ngoặc kép.
          Sửa tên trong trích dẫn là sửa văn bản gốc.
```

**Văn bản chính thức**

```text
Cấm ký tự:  —  –  ~  →  ≈
Cấm làm tròn — giữ đúng số chữ số thập phân của DUKIEN
  cần làm tròn thì ghi "làm tròn từ <giá trị gốc>"
Tiếng Việt văn phong hành chính
Tài liệu ITT tiếng Anh: font Arial
```

**Biểu mẫu nhà nước**

```text
Không xóa dòng · không đảo mục · ô trống ghi "Không áp dụng" hoặc "Không có"
```

**Mô tả phối hợp giữa các bên**

```text
Dùng sự kiện + ngày:  "đã gửi 12/08, chưa nhận phản hồi tính tới 19/08"
Cấm động từ quy kết thái độ: từ chối · phản đối · né tránh · trì hoãn
Áp cho mọi bên.
```

---

## 8. Hạn rà lại

```text
Giá và điều khoản thương mại   30 ngày
Dữ kiện còn lại                90 ngày
Giấy phép sắp hết hạn          cảnh báo trước 90 và 30 ngày
Mục _INBOX chưa nạp            cảnh báo sau 7 ngày
```

---

## 9. Không được ghi đè trong phiên

Bốn mục sau **không** bị một câu yêu cầu trong phiên ghi đè:

```text
§4 phạm vi (gồm từ cấm và bắt buộc AH1)
§5 vai các bên
§6 nguồn thẩm quyền
§7 thuật ngữ
```

Muốn đổi thì sửa file này ở một phiên riêng, ghi `QUYETDINH`.

---

## 10. Còn thiếu — điền trước khi chạy thật

```text
[ ] Nguồn văn bản xác lập vai 4 bên      §5
[ ] ID folder Drive MViSTA_MASTER        §1
[ ] Xác nhận MAY1/MAY2, khai máy thứ ba  §1
[ ] Nguồn thẩm quyền cho loại số còn lại §6
```

Chưa điền → dữ kiện liên quan giữ `CHƯA KIỂM`. Hệ tự chặn, không cần nhớ.
