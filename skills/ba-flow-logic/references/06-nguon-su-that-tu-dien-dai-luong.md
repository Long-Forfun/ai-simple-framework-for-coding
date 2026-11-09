# 06 — Nguồn sự thật + Từ điển đại lượng (v2, ADR 003 G1/G4/G5)

## 1. Gom sự thật trước (B1): đọc theo thứ tự, ghi nguồn

| Thứ tự | Nguồn | Đọc ở đâu | Nhãn |
|---|---|---|---|
| 1 | Lời chủ dự án | tin nhắn hiện tại, memory, **thân commit** (thường trích nguyên văn), Sổ đã chốt của spec cũ | `[chủ dự án YYYY-MM-DD]` |
| 2 | Văn bản | luật, quy chế, hợp đồng, biểu mẫu nhà nước | `[văn bản: tên §]` |
| 3 | Dữ liệu thật | bảng DB (đọc-only), file export, số liệu mẫu | `[dữ liệu: bảng/truy vấn]` |
| 4 | Code + màn đang chạy | route, component, rule đang có | `[code: path]` |
| 5 | Không có nguồn | — | `[GIẢ ĐỊNH]` |

**Lệnh gợi ý** (chỉ đọc):
```bash
git log --format='%h %ad %s%n%b' --date=short -- <vùng> | grep -iE 'anh long|chủ dự án|chốt|bỏ|đừng|không cần'
grep -rn "Sổ đã chốt" -A30 docs/app-map/
```

### Luật cho `[GIẢ ĐỊNH]`
- Được phép làm **mặc định nhẹ**: cảnh báo, ẩn, nháp, giá trị mặc định đổi được.
- KHÔNG được: thành rule R, thành token hay cỡ chữ cố định, thành test canh, thành quyền hay chặn.
- Luôn xuất hiện trong §0 nếu giả định đó **gánh một quyết định**.

### Mô tả user: bối cảnh, không nhân khẩu
| Sai (đã gây lỗi) | Đúng |
|---|---|
| "ngư dân 40–60 tuổi, ít rành công nghệ, tay ướt" → luật chữ to | "dùng Android tầm trung, online ~90% thời gian `[chủ dự án]`; đang dùng Zalo/Facebook hằng ngày `[GIẢ ĐỊNH]`" |
| "cán bộ lớn tuổi cần giao diện đơn giản" | "cán bộ cấp tỉnh nộp báo cáo quý theo biểu mẫu X `[văn bản]`" |

Cỡ chữ, cỡ nút và mật độ thuộc về design. Design dùng mặc định nền tảng, không suy từ tuổi.

## 2. Vai và quyền: bảng 3 câu (G2)

| Vai | Ai trả tiền | Ai chịu trách nhiệm (pháp lý/tài sản) | Ai bảo lãnh danh tính | Cách cấp | Đổi được? |
|---|---|---|---|---|---|
| Chủ tàu | chủ tàu | chủ tàu (tàu đứng tên) | số điện thoại + giấy tờ tàu | tự đăng ký | không (đổi qua nhân viên) |
| Thu mua | — | doanh nghiệp | nhân viên duyệt | **nhân viên duyệt** | không |

Mặc định an toàn: ít vai nhất. Vai có đặc quyền do người duyệt cấp. Dữ liệu tài sản chỉ chủ tài sản xem/sửa. Người đã vào app thì không bắt đăng nhập lại cho nghiệp vụ con.

## 3. Từ điển đại lượng (G4)

```markdown
| Đại lượng | Đơn vị đếm | Kỳ | Nguồn | Null hiển thị | Khoá chống trùng | Đơn vị đo |
|---|---|---|---|---|---|---|
| Số vụ vi phạm | vụ (không phải dòng) | luỹ kế từ đầu năm | cases JOIN violations | "chưa khai" | case_id | — |
| Tiền phạt | — | trong kỳ | penalties.amount | "chưa khai" | penalty_id | đồng (KHÔNG nghìn) |
```

Kiểm từng ô:
- **Đơn vị đếm**: nếu có 2 cách đếm hợp lý (lượt/tàu, dòng/vụ), viết rõ cách chọn và lý do kèm nguồn. Không có nguồn thì chọn cách bảo thủ và đưa lên §0.
- **Null**: 0 nghĩa là "đã khai, bằng 0". Chưa khai thì hiện "chưa khai" hoặc "—", và **không được cộng vào tổng như số 0**. Chấm điểm không phạt ô chưa khai mà hệ thống tự điền 0.
- **Chống trùng**: hồ sơ mang sang kỳ sau, tàu chưa đăng ký, bản ghi sinh đôi. Nêu khoá duy nhất.
- **Kỳ**: giờ VN; mốc đầu/cuối kỳ; luỹ kế hay trong kỳ.

App không có con số nào thì ghi `N/A — nghiệp vụ không tính/hiển thị số`.

### AC chạy trên số thật
```
### AC-7 — Tổng vụ Hà Tĩnh không đếm hồ sơ mang sang 2 lần · Maps to: NV3 · Test: integration
- **Given** dữ liệu mẫu Hà Tĩnh Q3: 4 vụ mới + 5 hồ sơ mang sang từ Q2 đã đóng
- **When** tính "Số vụ trong kỳ"
- **Then** kết quả là 4, không phải 9
- **Assert** count_cases(tinh='Hà Tĩnh', ky='Q3') == 4
```

## 4. Thang mặc định nhẹ (G5)

| Muốn làm (nặng) | Mặc định khi chưa có nguồn chốt (nhẹ) |
|---|---|
| chặn nộp / chặn lưu | cảnh báo + cho nộp, ghi nhận vi phạm |
| xoá | ẩn / lưu trữ, có khôi phục |
| bắt chọn | tự suy + cho sửa |
| bắt xác nhận | làm luôn + Undo |
| trừ điểm / tô đỏ | hiển thị trung tính, chờ ngưỡng do chủ dự án chốt |
| tách vai/nhóm quyền | giữ nhóm hiện có |

Mỗi lần hạ xuống mức nhẹ thì thêm 1 dòng vào §0.
