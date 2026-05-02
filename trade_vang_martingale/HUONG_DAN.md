# 📉 HƯỚNG DẪN CÀI ĐẶT GOLD MARTINGALE BOT

## Giới thiệu
**Gold Martingale Bot** (hay còn gọi là Bot Gồng Lỗ/DCA/Trung bình giá) là thuật toán quản lý vốn theo cấp số nhân. 

Khi một lệnh đi ngược hướng, bot sẽ tiếp tục nhồi thêm lệnh với khối lượng lớn hơn (nhân với hệ số multiplier) ở khoảng cách nhất định. Khi giá chỉ cần hồi lại một chút, tổng lợi nhuận của tất cả các lệnh sẽ dương và bot sẽ tự động chốt lời toàn bộ (đóng lưới lệnh).

### Ưu và Nhược điểm:
- ✅ **Ưu điểm:** Tỷ lệ thắng (Winrate) cực kỳ cao. Nếu vốn đủ dày để gồng, gần như chắc chắn sẽ chốt được lời.
- ❌ **Nhược điểm:** Rủi ro **Cháy Tài Khoản** (Margin Call) rất cao nếu gặp phải trend một chiều (thiên nga đen) kéo dài quá mức gồng của tài khoản.

---

## Cấu hình tham số

| Tham số | Mặc định | Mô tả | Khuyến nghị |
|---------|----------|-------|-------------|
| **Initial Lot** | 0.01 | Khối lượng lệnh đầu tiên | Bắt buộc để 0.01 cho Vàng |
| **Multiplier** | 2.0 | Hệ số nhân Lot (Ví dụ: 0.01 -> 0.02 -> 0.04) | 1.5 đến 2.0 (1.5 sẽ an toàn hơn) |
| **Step Distance** | 300 | Khoảng cách nhồi lệnh DCA (Điểm) | 300 - 500 (Tránh nhồi quá sát) |
| **Take Profit** | $5.0 | Lợi nhuận mục tiêu của cả chuỗi lệnh | $2 - $5 (Tùy vốn) |
| **Max Trades** | 7 | Giới hạn số lệnh nhồi tối đa | 5 - 7 (Bảo vệ tài khoản) |

---

## Cảnh báo quản lý rủi ro ⚠️
> Chiến lược Martingale là con dao hai lưỡi. Đã có rất nhiều quỹ lớn cháy tài khoản vì chiến lược này. Do đó bạn **BẮT BUỘC** phải tuân thủ:
1. **Vốn phải dày**: Chạy tài khoản Cent (Micro) hoặc cần có tối thiểu $2000 - $5000 cho tài khoản Standard nếu đánh lot khởi điểm 0.01.
2. **Tuyệt đối không chạy khi có tin mạnh**: NFP (Non-Farm), FOMC, CPI. Hãy tắt bot trước giờ ra tin.
3. Không để `Multiplier` quá cao, `Max Trades` quá lớn.
