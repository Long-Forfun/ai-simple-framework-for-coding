# §9 — bản điền cho Stavian Hightech / MViSTA

> Dán khối này thay cho §9 của `WORKOPS_CHUAN.md`.
> Không sửa gì ngoài §9.

---

## 9.1 Công ty, máy, thư mục

```text
Mã công ty:   SHT
Tên đầy đủ:   Stavian Hightech
Ta là ai:     thành viên liên danh 10%, phụ trách phân đoạn Việt Nam
              của tuyến cáp biển MViSTA (VN - TH - MY - SG)

MAY1  C:\Users\Envy\Documents\Claude\Projects\Stavian
MAY2  D:\Stavian

Sổ      <gốc công ty>\_so\
Drive   MViSTA_MASTER  (ID: <điền>)
          ├── _so\
          ├── _INBOX.md
          └── BANG_DIEU_KHIEN.md
```

## 9.2 Khối việc và loại tài liệu

```text
KHỐI
GP3B  Giấy phép cáp biển GP-3b        IRC   IRC CLS An Ngãi
GPVT  Giấy phép viễn thông SHT        JV    Liên doanh CLS với Lit Up
ITT   Gói thầu vendor                 KT    Kỹ thuật tuyến, CLS, BMH
SDP   DC Park                         DN    Nội bộ doanh nghiệp

LOẠI TÀI LIỆU
CV TT PA BG DT HD PL MOU BB BC SL YCKT HSMT HSDT HSNL GP MAU MAIL
```

Cây 6 thư mục con theo mặc định §4.

## 9.3 Phạm vi dùng — tập ĐÓNG

| Phạm vi | Cho | Luật riêng |
|---|---|---|
| `NHOM_A` | Hồ sơ trong nước: đất đai, xây dựng, môi trường, IRC CLS | **Chỉ SHT.** Cấm nhắc liên danh |
| `NHOM_B` | GP-3b nộp Cục Viễn thông, Bộ KH&CN | **Bắt buộc khai AH1 90% + SHT 10%** |
| `NOI_BO` | Trong SHT | |
| `LIEN_DANH` | Gửi AH1 | |
| `NHA_THAU` | Gửi OMS, Lit Up | Không đưa nội dung nhóm A ngoài phần liên quan |
| `CONG_KHAI` | Website, hồ sơ năng lực | Chỉ số đã công bố |

**Từ cấm**

```text
NHOM_A:  MViSTA · MVISTA · AsiaHub · AsiaHub One · AH1
         OMS · Lit Up · LitUp · Midas
         liên danh · consortium · joint venture
```

**Bắt buộc phải có**

```text
NHOM_B:  khai AH1 chủ sở hữu 90% + SHT thành viên 10%.
         THIẾU AH1 LÀ KHAI MAN. Không ngoại lệ.
```

## 9.4 Các bên và vai

| Bên | Vai | Đầu mối | Ta cần gì ở họ | Họ cần gì ở ta | Nguồn xác lập |
|---|---|---|---|---|---|
| **AH1** — AsiaHub One Pte Ltd (SG) | Thành viên liên danh, chủ sở hữu **90%** | `<điền>` | `<điền>` | `<điền>` | `<điền>` |
| **SHT** — Stavian Hightech | Thành viên liên danh **10%**, phụ trách phân đoạn VN | ta | — | — | `<điền>` |
| **OMS** (Malaysia) | Nhà thầu **EPC** do AH1 chỉ định. **Không** phải thành viên liên danh | `<điền>` | `<điền>` | `<điền>` | `<điền>` |
| **Lit Up** | Nhà thầu **CLS** SG/TH/MY · JV **49%** với SHT **51%** cho CLS VN. **Không** phải thành viên liên danh | `<điền>` | `<điền>` | `<điền>` | `<điền>` |
| **Midas** (quỹ Nhật) | Chưa xác lập — **CHƯA KIỂM** | — | — | — | chưa có |

```text
Liên danh có ĐÚNG HAI thành viên: AH1 và SHT
Midas: cấm đưa vào tài liệu ra ngoài cho tới khi có văn bản
```

## 9.5 Nguồn thẩm quyền theo loại dữ kiện

| Loại dữ kiện | Nguồn thắng |
|---|---|
| Chiều dài, tọa độ, định tuyến | **RPL V1 — 24/04/2026** |
| Phạm vi gói, thiết bị, điều kiện thầu | **ITT Part 2 — bản 20260615** |
| Số đã công bố công chúng | website mvista.sg — **chỉ cho `CONG_KHAI`** |
| Còn lại | chưa khai → mặc định `CHƯA KIỂM` |

```text
Chiều dài phải ghi kèm loại số đo: design length HAY seabed cumulative
```

Đang treo: website ghi `2.500+ km` không kèm loại số đo → `DUKIEN`, phạm vi `CONG_KHAI`, cấm dùng cho hồ sơ nhà nước.

## 9.6 Thuật ngữ và hình thức

```text
BẮT BUỘC DÙNG      Bộ Khoa học và Công nghệ (Cục Viễn thông)
CẤM DÙNG           Bộ Thông tin và Truyền thông · Bộ TT&TT
Ngoại lệ trích dẫn trích nguyên văn văn bản trước 2025 thì GIỮ tên cũ,
                   đặt trong ngoặc kép. Sửa tên trong trích dẫn là sửa văn bản gốc.

VĂN BẢN CHÍNH THỨC
Cấm ký tự:      —  –  ~  →  ≈
Quy tắc số:     cấm làm tròn, giữ đúng số chữ số thập phân của DUKIEN
                cần làm tròn thì ghi "làm tròn từ <giá trị gốc>"
Văn phong:      tiếng Việt hành chính
Font:           tài liệu ITT tiếng Anh dùng Arial

BIỂU MẪU NHÀ NƯỚC
Không xóa dòng · không đảo mục · ô trống ghi "Không áp dụng" hoặc "Không có"

MÔ TẢ QUAN HỆ CÁC BÊN
Dùng sự kiện + ngày: "đã gửi 12/08, chưa nhận phản hồi tính tới 19/08"
Động từ cấm: từ chối · phản đối · né tránh · trì hoãn · không hợp tác
Áp cho mọi bên.
```

## 9.7 Nhịp và hạn

```text
Quét mail                      mỗi ngày làm việc, nhắc khi quá 2 ngày
Quét folder Drive đối tác      mỗi phiên Cowork
Giá và điều khoản thương mại   30 ngày
Dữ kiện còn lại                90 ngày
Giấy phép sắp hết hạn          cảnh báo trước 90 và 30 ngày
Mục _INBOX chưa nạp            cảnh báo sau 7 ngày
Ngày tính theo ngày lịch, múi giờ +07

Sổ mã thư:  ThongKe_Email_MViSTA_theo_luong (2 cột KHỐI + MÃ VIỆC)
            mã dạng #L-<số>, đang chạy tới <điền>
```

## 9.8 Dòng kiểm riêng — cộng vào §8.A

```text
[ ] 12  NHOM_A: quét sạch danh sách từ cấm §9.3 → IN kết quả quét
[ ] 13  NHOM_B: có khai AH1 90% + SHT 10% → trích nguyên văn câu khai
[ ] 14  Biểu mẫu nhà nước đủ dòng, đúng thứ tự, ô trống đã điền
[ ] 15  Có số công văn đi
```

## 9.9 Không được ghi đè trong phiên

```text
§9.3 phạm vi — gồm từ cấm và bắt buộc AH1
§9.4 vai các bên
§9.5 nguồn thẩm quyền
§9.6 thuật ngữ bắt buộc và cấm
```

## 9.10 Còn thiếu

```text
[ ] Nguồn văn bản xác lập vai 4 bên            §9.4
[ ] Đầu mối + ta cần gì / họ cần gì cho từng bên  §9.4
[ ] ID folder Drive MViSTA_MASTER              §9.1
[ ] Xác nhận MAY1 / MAY2, khai máy thứ ba      §9.1
[ ] Nguồn thẩm quyền cho loại dữ kiện còn lại  §9.5
[ ] Mã thư #L đang chạy tới số bao nhiêu       §9.7
```
