# WorkOps — luật vận hành

```yaml
version: v03
date: 2026-08-19
```

Đọc file này mỗi phiên. Cấu hình dự án ở `PROFILE.md`.

---

## 0. Mở phiên — in đúng 3 dòng

```text
Phiên:  CHAT  |  COWORK@MAY1
Việc:   <khối> — <một câu>
Bàn:    2 quá hạn · 1 chờ đối tác · 3 chưa nạp
```

Dòng `Bàn` đọc từ `BANG_DIEU_KHIEN.md`, không tự tính.

Sai một dòng là dừng, hỏi lại. Đừng làm tiếp.

---

## 1. Phiên này là gì

```text
COWORK  = đọc và ghi được thư mục trên máy
CHAT    = không
```

Không chắc thì thử đọc `<gốc máy>\_so\VIEC.md`.

Đọc được là Cowork. Lỗi là Chat.

**Cowork phải nói đang ở máy nào** (`MAY1` / `MAY2`, khai ở `PROFILE`).

Chưa có quyền thư mục thì **xin quyền trước**, chưa xin được thì chưa làm gì cả.

---

## 2. CHAT làm gì

**Đọc:** `PROFILE` · 4 sổ bản Drive · file người dùng dán vào phiên.

**Ghi:** đúng một chỗ duy nhất — `Drive/_INBOX.md`, **chỉ thêm vào cuối**, không sửa dòng cũ.

Mỗi thứ cần lưu, thêm một khối:

```text
## 2026-08-19 14:30 | CHAT
Loại:    VIEC | DUKIEN | TAILIEU | QUYETDINH
Khối:    GP3B
Nội dung: <dán nguyên dòng sẽ thêm vào sổ>
File:    <tên chuẩn §4> — đang trong hội thoại
Nạp:     chưa
```

**File Chat tạo ra nằm trong hội thoại, không phải bản chính.**

Giao file phải nói đủ: tên chuẩn · máy nào · thư mục nào · đã ghi `_INBOX` chưa.

**Chat cấm:**

```text
Nói "đã lưu vào máy"
Sửa 4 sổ
Coi file trong hội thoại là bản chính
Tự gửi, tự nộp
```

Chỉ thêm vào cuối một file thì hai phiên không bao giờ đè nhau. Không cần đánh số phiên bản, không cần trọng tài.

---

## 3. COWORK làm gì

**Là người ghi duy nhất.** Sổ trên máy là bản chính.

**Mở phiên:**

```text
1  Nói đang ở máy nào
2  Đọc _INBOX.md → nạp mọi mục "Nạp: chưa" vào sổ → sửa thành "Nạp: <ngày>"
3  In bàn làm việc
```

**Trong phiên:** ghi sổ ngay trong lượt tạo ra thay đổi, không đợi cuối phiên.

**File mới:** lưu thẳng đúng thư mục §4. Cấm Desktop, Downloads, thư mục tạm.

**Đóng phiên:**

```text
1  Sinh lại BANG_DIEU_KHIEN.md
2  Copy 4 sổ + bảng điều khiển lên Drive  ← để Chat đọc được
3  Báo một dòng: đã ghi gì, ở đâu, còn chờ gì
```

**Hai máy:** bản chính của một tài liệu chỉ nằm ở **một** máy.

Chuyển máy qua Drive, sửa cột `Ở đâu` trong `TAILIEU.md` **ngay**.

Phát hiện hai máy cùng giữ bản cuối → ghi vào `VIEC` để xử, không tự chọn.

---

## 4. Tên file, thư mục, hệ sổ

**Thư mục**

```text
<KHOI>\
├── 01_Phap_ly      (bản nộp: 01_Phap_ly\_NOP_YYYYMMDD\ — khóa lại sau khi nộp)
├── 02_Ky_thuat
├── 03_Thuong_mai
├── 04_Trao_doi     (mail lưu .eml/.pdf)
├── 05_Mau
├── 99_Goc          (file gốc đối tác — không sửa)
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
Bản đã ký thêm _SIGNED — bất biến, không sửa nữa
Đổi nội dung = tăng vNN, không ghi đè
```

Trạng thái nằm ở `TAILIEU.md`, **không** đưa vào tên file (trừ `_SIGNED`).

**Hệ sổ — 4 file, ở `_so\`**

```text
VIEC.md       việc · bước tiếp theo · ai làm · hạn · trạng thái · khối
DUKIEN.md     dữ kiện · giá trị · nguồn · PHẠM VI DÙNG · trạng thái · khối
TAILIEU.md    tên · vN · ở đâu (máy + thư mục) · trạng thái · hết hạn · khối
QUYETDINH.md  ngày · chọn gì · vì sao — chỉ thêm, không sửa
```

Máy sinh: `BANG_DIEU_KHIEN.md`.  Chat ghi: `_INBOX.md`.

**Trạng thái**

```text
VIEC     MỚI · ĐANG LÀM · CHỜ ĐỐI TÁC · CHỜ DUYỆT · TREO · XONG · HỦY
DUKIEN   CHƯA KIỂM · ĐÃ KIỂM · MÂU THUẪN · ĐÃ THAY · HẾT HẠN
TAILIEU  NHÁP · CHỜ DUYỆT · ĐÃ GỬI · ĐÃ NỘP · TRẢ HỒ SƠ · ĐÃ CẤP · ĐÃ KÝ
```

Việc chưa xong **bắt buộc đủ**: bước tiếp theo + ai làm + hạn.

Thiếu một vế là việc trôi — lên đầu bàn làm việc.

---

## 5. Định tuyến — đọc gì cho việc gì

Trước khi làm, xác định **khối**. Bảng khối ở `PROFILE`.

| Yêu cầu | Đọc |
|---|---|
| Hỏi thông tin | `DUKIEN` lọc theo khối |
| Soạn gửi ra ngoài | `DUKIEN` + `PROFILE` §phạm vi §nguồn + mẫu → chạy skill `phat-hanh` |
| Sửa file có sẵn | `TAILIEU` tìm bản mới nhất → file đó |
| Mail hoặc file đến | skill `quet-mail` |
| Điểm danh | `BANG_DIEU_KHIEN` — không mở file nghiệp vụ |
| Rà soát toàn bộ | skill `ra-soat` |

**Chỉ đọc phần của khối liên quan. Không đọc cả sổ.**

Không rõ khối, hỏi đúng một câu:

```text
1 = <khối gợi ý>  (một câu vì sao)
2 = mở khối mới <Mã + Tên>
```

Người dùng đã nêu tên khối rồi thì bỏ hỏi, nói "vào `<khối>`" rồi làm.

Chọn `2` → thêm mã vào `PROFILE`, dựng đủ cây thư mục §4, rồi mới lưu.

---

## 6. Có gì đổi thì ghi vào đâu

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
| Chưa đủ nguồn, hai nguồn cãi nhau | `DUKIEN` trạng thái `CHƯA KIỂM` / `MÂU THUẪN` |
| Việc bỏ không làm | `VIEC` → `HỦY` + lý do. Không đánh `XONG` |

**Luật nối:** mọi số trong tài liệu soạn ra ngoài phải có dòng ở `DUKIEN`.

Không có ở `DUKIEN` thì không được dùng như đã chốt.

---

## 7. Cấm

```text
Trích số mà không có nguồn ở DUKIEN
Dùng dữ kiện sai PHẠM VI của đầu ra              → xem PROFILE §phạm vi
Tự đoán vai các bên theo cách gọi trong hội thoại → vai chỉ theo văn bản ký
Sửa hoặc xóa file đã ký, đã nộp, file gốc đối tác
Nói đã lưu / đã gửi / đã cập nhật khi thao tác chưa thành công
Tự gửi, tự nộp, tự liên hệ ra ngoài
```

**Phát hiện tài liệu đã gửi hoặc đã nộp bị sai:**

```text
1  Dừng lại
2  Ghi VIEC mức gấp: sai gì · tài liệu nào vN · gửi cho ai ngày nào
3  Trình phương án cho người dùng chọn
4  CẤM tự đính chính, tự liên hệ, tự sửa hay xóa bản đã gửi
```

Bản đã ra ngoài là bất biến kể cả khi sai. Sửa bằng văn bản mới.

---

## 8. Đóng phiên

Một dòng, có bằng chứng, không nói chung chung:

```text
COWORK: đã ghi VIEC + TAILIEU · file tại MAY1\GP3B\01_Phap_ly\... · đã copy Drive · chờ anh duyệt §5.2
CHAT:   đã thêm 2 mục vào _INBOX (VIEC, DUKIEN) · 1 file trong hội thoại chờ Cowork lưu
HỎI ĐÁP: không đổi gì
```
