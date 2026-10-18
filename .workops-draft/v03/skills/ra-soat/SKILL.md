---
name: ra-soat
description: Đối chiếu 4 sổ với thực tế trên máy và Drive, tìm chỗ lệch. Dùng khi nghi sổ không khớp thực tế, sau một đợt làm nhiều, hoặc định kỳ mỗi quý. Chỉ báo cáo, không tự sửa.
---

# Rà soát sổ và thực tế

Chỉ Cowork chạy được đầy đủ (cần đọc thư mục máy).

**Chỉ báo cáo. Không tự sửa gì cho tới khi người dùng duyệt.**

## Kiểm 12 điều

```text
FILE
 1  File có trong TAILIEU mà không thấy trên máy hoặc Drive
 2  File có trên máy mà chưa vào TAILIEU
 3  Hai máy cùng giữ bản cuối của một tài liệu
 4  File trong 99_Goc bị sửa (so ngày sửa với ngày nhận)
 5  ID hoặc đường dẫn Drive không mở được

SỔ
 6  Dòng DUKIEN thiếu nguồn, hoặc thiếu PHẠM VI DÙNG
 7  Dòng DUKIEN quá hạn rà lại  (PROFILE §8)
 8  Việc chưa xong mà thiếu: bước tiếp theo / ai làm / hạn
 9  Việc TREO quá 30 ngày chưa động tới
10  Việc CHỜ ĐỐI TÁC quá 7 ngày lịch — cần nhắc đòi

HẠN VÀ ĐỒNG BỘ
11  Giấy phép trong TAILIEU hết hạn trong 90 hoặc 30 ngày
12  Mục _INBOX còn "Nạp: chưa" quá 7 ngày
    Bản sổ trên Drive cũ hơn bản trên máy
```

## Xuất

```text
| # | Loại lệch | Đối tượng | Chi tiết | Đề xuất xử |
```

Không có gì thì ghi một dòng: `sổ khớp thực tế — <ngày>`.

## Sau khi người dùng duyệt

Sửa từng mục đã duyệt, mỗi mục ghi một dòng bằng chứng đã sửa gì ở đâu.

Mục nào người dùng chưa quyết → ghi vào `VIEC` để không rơi.

## Định kỳ — mỗi quý

Ngoài 12 điều trên, đọc lại các dòng `CHƯA KIỂM` và `MÂU THUẪN` trong `DUKIEN`:

```text
Cùng một loại lệch xuất hiện ≥ 3 lần  →  thiếu một luật, đề xuất thêm vào PROFILE
Cùng một câu hỏi lặp ≥ 2 lần          →  thiếu một mục cấu hình, đề xuất thêm
```

Ghi kết luận vào `QUYETDINH`.
