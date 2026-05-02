# 🚀 HƯỚNG DẪN CÀI ĐẶT GOLD BREAKOUT BOT

## Giới thiệu
**Gold Breakout Bot** là thuật toán giao dịch theo kiểu phá vỡ xu hướng (Breakout Trading). Thuật toán này dựa trên một nguyên lý thị trường kinh điển: "Sau một chuỗi thời gian nén giá đi ngang, giá sẽ bùng nổ theo một hướng mạnh mẽ".

Bot sẽ tính toán các mốc **Đỉnh cao nhất (Highest High)** và **Đáy thấp nhất (Lowest Low)** của `N` cây nến gần nhất. Nếu giá phá vỡ đỉnh (Kèm theo khoảng đệm Buffer) thì bot sẽ Buy, nếu phá đáy thì bot sẽ Sell.

### Ưu và Nhược điểm:
- ✅ **Ưu điểm:** Lợi nhuận rất lớn nếu bắt đúng sóng bùng nổ của thị trường (Đặc biệt vào các phiên Âu/Mỹ).
- ❌ **Nhược điểm:** Dễ dính lệnh giả (False Breakout) khi thị trường chỉ thò râu nến quét Stop Loss rồi đảo chiều quay lại bên trong hộp nén.

---

## Cấu hình tham số

| Tham số | Mặc định | Mô tả | Khuyến nghị |
|---------|----------|-------|-------------|
| **Lot Size** | 0.05 | Khối lượng lệnh | Tùy số vốn (Bot này đánh lệnh đơn, có Stoploss nên rủi ro thấp, có thể đánh lot lớn hơn) |
| **Breakout Candles** | 20 | Số lượng nến để xét Đỉnh/Đáy hộp nén | 10 - 20 nến (Khuyên dùng trên khung M15 hoặc H1) |
| **Take Profit** | 500 | Chốt lời (Points) | 500 - 1000 (Tỉ lệ R:R nên lớn hơn 1) |
| **Stop Loss** | 300 | Cắt lỗ (Points) | 200 - 400 |
| **Buffer** | 20 | Khoảng đệm điểm (Points) để lọc nhiễu | 20 - 50 (Tránh quét râu) |
| **Delay Seconds** | 3600 | Khoảng thời gian chờ sau khi đánh xong 1 lệnh (Giây) | 3600 (1 Tiếng) - Tránh đánh liên tục khi giá giật |

---

## Khuyến nghị giao dịch
- **Khung thời gian (Timeframe):** Khuyến nghị chạy trên **M15** hoặc **H1**. Breakout trên khung nhỏ (M1, M5) độ nhiễu rất cao.
- **Stop Loss là bắt buộc:** Khác với Grid hay Martingale, chiến lược Breakout yêu cầu **phải có Stop Loss cứng**. Nếu False Breakout xảy ra, bạn chỉ mất khoản tiền nhỏ và chờ cơ hội sau.
