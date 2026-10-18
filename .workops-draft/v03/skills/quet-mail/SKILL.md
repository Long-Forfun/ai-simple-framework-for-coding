---
name: quet-mail
description: Xử một lô mail, file đính kèm, file mới trong folder Drive đối tác, hoặc thông tin người dùng đưa trực tiếp. Biến chúng thành việc, dữ kiện, tài liệu trong sổ. Dùng khi quét mail hằng ngày hoặc khi nhận một lô file mới.
---

# Nhận thông tin vào công ty

Mọi thông tin vào công ty qua đúng bốn cửa. Không cửa nào được bỏ qua sổ.

```text
a  Mail                      quét hằng ngày
b  Folder Drive đối tác      quét mỗi phiên Cowork  (ID folder đối tác đã từng hỏng)
c  Người dùng đưa trực tiếp  họp, điện thoại, file tay
d  Phát sinh trong phiên     ghi ngay trong lượt
```

## Với mỗi mail hoặc file

```text
1  Gắn mã #L theo file thống kê email (luồng mới thì cấp mã kế tiếp)
2  Xác định khối
3  Soi ra việc trong VIEC — chưa có thì đề xuất mở việc mới
4  Đề xuất trạng thái việc mới
5  Nói rõ người dùng cần làm gì
```

## File đính kèm

```text
Bản trao đổi thường  →  <KHOI>\04_Trao_doi\
File gốc đối tác     →  <KHOI>\99_Goc\  + cờ GỐC — KHÔNG SỬA
Mail là nguồn        →  lưu .eml hoặc .pdf vào 04_Trao_doi\
Khai TAILIEU với nguồn = #L
Làm đổi một con số   →  sửa DUKIEN ngay, dòng cũ ghi "→ thay bởi"
```

## Cửa (c) — người dùng nói miệng

```text
Có biên bản hoặc mail xác nhận  →  DUKIEN trạng thái ĐÃ KIỂM
Chỉ nói miệng                   →  DUKIEN trạng thái CHƯA KIỂM
                                   cho tới khi có văn bản
```

## Xuất bảng, chờ duyệt

```text
| Mail / File | #L | Khối | Việc | Trạng thái mới | Lưu đâu | Anh cần làm gì |
```

**Duyệt rồi mới ghi sổ.**

Bảng chưa được duyệt mà hết phiên → ghi một dòng vào `VIEC`:

```text
"Chờ duyệt kết quả quét mail <ngày>" — hạn: phiên sau
```

Cấm để nó chết theo phiên.

## Chat chạy skill này

Không ghi sổ được. Xuất bảng, rồi thêm các mục vào `_INBOX.md` theo `WORKOPS.md` §2, đánh `Nạp: chưa`.
