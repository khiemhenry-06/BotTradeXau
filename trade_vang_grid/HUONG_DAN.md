# 🕸️ HƯỚNG DẪN CÀI ĐẶT GOLD GRID BOT

## Giới thiệu
**Gold Grid Bot** là thuật toán giao dịch theo kiểu lưới (Grid Trading), một chiến lược rất phổ biến khi thị trường đi ngang (Sideway) hoặc dao động trong một biên độ nhất định. 

Bot sẽ liên tục rải lệnh (Buy và Sell) ở các khoảng giá đều đặn. Khi giá biến động lên xuống, các lệnh sẽ lần lượt chạm Take Profit và mang lại lợi nhuận liên tục.

### Ưu và Nhược điểm:
- ✅ **Ưu điểm:** Cực kỳ hiệu quả trong thị trường giá đi ngang (Range market). Lợi nhuận nhỏ nhưng đều đặn.
- ❌ **Nhược điểm:** Rủi ro cao khi thị trường có xu hướng (Trend) mạnh kéo dài một chiều.

---

## Cấu hình tham số

| Tham số | Mặc định | Mô tả | Khuyến nghị |
|---------|----------|-------|-------------|
| **Lot Size** | 0.01 | Khối lượng lệnh | Nên để nhỏ nhất (0.01) |
| **Grid Step** | 200 | Khoảng cách rải lệnh (Điểm) | 200 - 300 points (2-3 giá Vàng) |
| **Take Profit** | 300 | Mức chốt lời mỗi lệnh (Điểm) | 300 - 400 points |
| **Max Levels** | 10 | Tầng lưới tối đa | 5 - 10 (Giới hạn rủi ro) |

> *100 points trên MT5 Vàng thường tương đương với 1 Giá ($1).*

---

## Lưu ý quan trọng
- **Chiến lược Grid không dùng Stop Loss** trên từng lệnh cá nhân, thay vào đó bạn cần quản lý vốn trên toàn bộ tài khoản. 
- Yêu cầu vốn tương đối lớn để gồng các nhịp đi sai hướng. Tối thiểu nên có từ **$500 - $1000** để chạy an toàn với Lot 0.01.
- Nên kết hợp tắt bot khi có các tin tức kinh tế quan trọng.
