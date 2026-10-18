---
name: phat-hanh
description: Bảng kiểm bắt buộc trước khi gửi, nộp, ký hoặc công bố bất kỳ tài liệu nào ra ngoài SHT. Dùng khi sắp gửi mail có đính kèm cho đối tác, nộp hồ sơ cơ quan nhà nước, trình ký, hoặc đưa số liệu ra ngoài.
---

# Phát hành tài liệu ra ngoài

Chạy TRƯỚC khi tài liệu rời khỏi SHT. Không chạy sau.

## Bước 1 — xác định

```text
Tài liệu:  <tên chuẩn + vN>
Phạm vi:   NHOM_A | NHOM_B | LIEN_DANH | NHA_THAU | CONG_KHAI
Gửi cho:   <ai, tổ chức nào>
Khối:      <mã>
```

Không xác định được phạm vi → **dừng, hỏi**. Cấm đoán.

## Bước 2 — in bảng kiểm, từng dòng, kèm chứng minh

Bắt buộc in ra. Cấm thay bằng câu "đã kiểm".

```text
[ ]  1  Mọi số trong tài liệu có dòng ở DUKIEN
        → liệt kê: <số> = <dòng DUKIEN> | <nguồn>

[ ]  2  Phạm vi mọi dữ kiện khớp phạm vi tài liệu

[ ]  3  NHOM_A: quét sạch danh sách từ cấm ở PROFILE §4
        → in kết quả quét, không nói "đã quét"

[ ]  4  NHOM_B: có khai AH1 90% + SHT 10%
        → trích nguyên văn câu khai

[ ]  5  Vai các bên đúng PROFILE §5
        → OMS là nhà thầu EPC, Lit Up là nhà thầu CLS + JV, không ai là thành viên liên danh

[ ]  6  Số kỹ thuật khớp nguồn thẩm quyền §6 và có kèm loại số đo

[ ]  7  Tên cơ quan: Bộ Khoa học và Công nghệ (Cục Viễn thông)

[ ]  8  Không có ký tự cấm, không làm tròn ngoài khai báo

[ ]  9  Biểu mẫu nhà nước: đủ dòng, đúng thứ tự, ô trống đã điền

[ ] 10  Mục lục khớp 1:1 file thực tế

[ ] 11  File gốc đối tác đính kèm còn nguyên vẹn

[ ] 12  Giấy phép được viện dẫn còn hiệu lực tại ngày gửi
        → tra cột hết hạn ở TAILIEU

[ ] 13  Bản này khớp bản đã duyệt nội bộ
```

Dòng không áp dụng ghi `— không áp dụng` kèm lý do một câu.

## Bước 3 — chốt

```text
Có một dấu ✗  →  KHÔNG phát hành.
                 Ghi VIEC: thiếu gì, ai bổ sung, hạn.
Tất cả ✓      →  trình người dùng duyệt.
```

**AI không tự gửi, không tự nộp, không tự liên hệ ra ngoài.**

Người dùng thực hiện việc gửi.

## Bước 4 — sau khi đã gửi

```text
TAILIEU  → trạng thái ĐÃ GỬI / ĐÃ NỘP + ngày + cho ai
Bản nộp  → chép vào 01_Phap_ly\_NOP_YYYYMMDD\ rồi khóa, không sửa nữa
Nháp cũ  → chuyển _lich_su\
VIEC     → cập nhật bước tiếp theo và ngày chờ
```

Ghi lại danh sách số đã dùng ở bước 2 dòng 1 vào ghi chú của `TAILIEU`.

Sau này một dữ kiện đổi giá trị thì tra được ngay tài liệu nào đã phát hành đang mang số cũ.
