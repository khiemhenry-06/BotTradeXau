# 🏆 HƯỚNG DẪN CÀI ĐẶT VÀ SỬ DỤNG GOLD SCALPER BOT

## 📋 Mục lục
1. [Giới thiệu](#giới-thiệu)
2. [Yêu cầu](#yêu-cầu)
3. [Cài đặt EA vào MT5](#cài-đặt-ea-vào-mt5)
4. [Biên dịch EA](#biên-dịch-ea)
5. [Gắn EA lên chart](#gắn-ea-lên-chart)
6. [Cấu hình tham số](#cấu-hình-tham-số)
7. [Chạy và giám sát](#chạy-và-giám-sát)
8. [Backtest (Kiểm tra lịch sử)](#backtest)
9. [Lưu ý quan trọng](#lưu-ý-quan-trọng)

---

## 🎯 Giới thiệu

**Gold Scalper Bot** là Expert Advisor (EA) tự động giao dịch vàng (XAUUSD) trên MetaTrader 5.

### Chiến lược:
- **Scalping nhanh**: Vào lệnh nhanh, chốt lời nhanh ($2-5/lệnh)
- **Chỉ báo sử dụng**: RSI (7) + Bollinger Bands (14) + EMA (50)
- **Logic vào lệnh BUY**: RSI quá bán + Giá chạm Lower BB + RSI đang tăng
- **Logic vào lệnh SELL**: RSI quá mua + Giá chạm Upper BB + RSI đang giảm
- **Bảo vệ**: Trailing Stop + Lọc Spread + Giới hạn số lệnh

---

## ⚙️ Yêu cầu

1. **MetaTrader 5** đã cài đặt (tải từ [metatrader5.com](https://www.metatrader5.com/))
2. **Tài khoản broker** hỗ trợ giao dịch XAUUSD (Gold)
3. **VPS** (khuyến nghị) để bot chạy 24/7 ổn định
4. **Vốn tối thiểu**: $100+ (khuyến nghị $500+ để an toàn)

---

## 📥 Cài đặt EA vào MT5

### Bước 1: Mở thư mục dữ liệu MT5

1. Mở **MetaTrader 5**
2. Vào menu **File** → **Open Data Folder** (Mở thư mục dữ liệu)
3. Hoặc nhấn tổ hợp phím: `Ctrl + Shift + D`

### Bước 2: Copy file EA

1. Trong thư mục dữ liệu, mở: `MQL5\Experts`
2. **Copy file** `GoldScalper_EA.mq5` vào thư mục `MQL5\Experts`
3. Bạn có thể tạo thư mục con nếu muốn: `MQL5\Experts\MyBots\GoldScalper_EA.mq5`

```
📁 MQL5
 └── 📁 Experts
      └── 📄 GoldScalper_EA.mq5   ← Copy file vào đây
```

---

## 🔨 Biên dịch EA

### Bước 1: Mở MetaEditor

1. Trong MT5, nhấn phím **F4** hoặc vào **Tools** → **MetaQuotes Language Editor**
2. MetaEditor sẽ mở ra

### Bước 2: Mở file EA

1. Trong MetaEditor, vào **File** → **Open** (hoặc `Ctrl + O`)
2. Tìm đến file `GoldScalper_EA.mq5` trong thư mục Experts
3. Mở file

### Bước 3: Biên dịch

1. Nhấn phím **F7** hoặc click nút **Compile** trên toolbar
2. Kiểm tra tab **Errors** ở bên dưới:
   - ✅ Nếu thấy `0 error(s), 0 warning(s)` → **Thành công!**
   - ❌ Nếu có lỗi → kiểm tra lại file có đầy đủ không

### Bước 4: Quay lại MT5

1. Đóng MetaEditor hoặc nhấn `Alt + Tab` để quay lại MT5
2. Trong cửa sổ **Navigator** (bên trái), mục **Expert Advisors**, bạn sẽ thấy `GoldScalper_EA`
3. Nếu chưa thấy, click chuột phải vào **Expert Advisors** → **Refresh**

---

## 📊 Gắn EA lên Chart

### Bước 1: Mở chart XAUUSD

1. Vào **File** → **New Chart** → tìm **XAUUSD** (hoặc Gold)
2. Hoặc trong **Market Watch** (Ctrl+M), tìm XAUUSD, click chuột phải → **Chart Window**

### Bước 2: Chọn khung thời gian

1. Chọn **M1 (1 phút)** trên toolbar timeframe
2. Bot được tối ưu cho khung M1, phù hợp với scalping nhanh

### Bước 3: Gắn EA

**Cách 1 - Kéo thả:**
1. Trong **Navigator** (Ctrl+N), mở mục **Expert Advisors**
2. Tìm `GoldScalper_EA`
3. **Kéo và thả** EA lên chart XAUUSD

**Cách 2 - Double click:**
1. Double click vào `GoldScalper_EA` trong Navigator
2. EA sẽ tự gắn lên chart đang active

### Bước 4: Cấu hình khi gắn

Khi gắn EA, một cửa sổ cấu hình sẽ hiện ra:

**Tab Common:**
- ✅ Tick chọn **Allow Algo Trading** (Cho phép giao dịch tự động)
- ✅ Tick chọn **Allow modification of Signals settings**

**Tab Inputs:** (xem phần Cấu hình tham số bên dưới)

### Bước 5: Bật Auto Trading

1. Trên toolbar chính của MT5, tìm nút **Algo Trading** (AutoTrading)
2. Click để **BẬT** nó (nút sẽ chuyển sang màu xanh lá)
3. Trên chart, góc trên bên phải sẽ hiện biểu tượng **mặt cười 😊** → Bot đang chạy!
4. Nếu thấy **mặt buồn 😟** → Bot chưa được phép giao dịch, kiểm tra lại bước trên

---

## 🎛️ Cấu hình tham số

### Cấu hình giao dịch (quan trọng nhất)

| Tham số | Mặc định | Mô tả | Khuyến nghị |
|---------|----------|-------|-------------|
| **Lot Size** | 0.01 | Khối lượng mỗi lệnh | 0.01-0.05 (tùy vốn) |
| **Take Profit** | $3.0 | Mức chốt lời mỗi lệnh | $2-5 (scalp nhanh) |
| **Stop Loss** | $5.0 | Mức cắt lỗ mỗi lệnh | $3-7 |
| **Max Positions** | 1 | Số lệnh tối đa cùng lúc | 1-2 (an toàn) |
| **Magic Number** | 12345 | ID nhận diện bot | Giữ nguyên |

### Chỉ báo kỹ thuật

| Tham số | Mặc định | Mô tả |
|---------|----------|-------|
| RSI Period | 7 | Chu kỳ RSI (ngắn cho scalp) |
| RSI Overbought | 75 | Ngưỡng quá mua |
| RSI Oversold | 25 | Ngưỡng quá bán |
| BB Period | 14 | Chu kỳ Bollinger Bands |
| BB Deviation | 2.0 | Độ lệch chuẩn BB |
| EMA Period | 50 | Chu kỳ EMA lọc xu hướng |

### Bộ lọc an toàn

| Tham số | Mặc định | Mô tả |
|---------|----------|-------|
| Max Spread | 40 | Spread tối đa (points), không vào lệnh khi spread cao |
| Delay Seconds | 5 | Thời gian chờ giữa 2 lệnh |
| Use Time Filter | false | Bật/tắt lọc theo giờ giao dịch |
| Start Hour | 8 | Giờ bắt đầu giao dịch (giờ server) |
| End Hour | 22 | Giờ kết thúc giao dịch |

### Trailing Stop

| Tham số | Mặc định | Mô tả |
|---------|----------|-------|
| Use Trailing | true | Bật trailing stop (dời SL theo giá) |
| Trailing Start | $2.0 | Bắt đầu trail khi lãi đủ |
| Trailing Step | $0.5 | Bước dời trailing |

### 💡 Gợi ý cấu hình theo vốn:

**Vốn $100-200:**
- Lot: 0.01
- TP: $2 | SL: $3
- Max Positions: 1

**Vốn $500-1000:**
- Lot: 0.02-0.05
- TP: $3 | SL: $5
- Max Positions: 1-2

**Vốn $1000+:**
- Lot: 0.05-0.10
- TP: $3-5 | SL: $5-7
- Max Positions: 2-3

---

## 🖥️ Chạy và giám sát

### Xác nhận bot đang chạy

1. **Biểu tượng mặt cười** 😊 ở góc phải chart → Bot đang hoạt động
2. **Tab Experts** (bên dưới chart) → Hiện log hoạt động của bot
3. **Comment trên chart** → Hiện bảng thông tin realtime:
   - Spread hiện tại
   - RSI hiện tại
   - Số lệnh đang mở
   - P/L hiện tại
   - Thống kê thắng/thua

### Xem lệnh đang mở

- Tab **Trade** (bên dưới chart): Hiển thị tất cả lệnh đang mở
- Các lệnh của bot sẽ có comment "GoldScalp BUY" hoặc "GoldScalp SELL"

### Xem lịch sử giao dịch

- Tab **History** (bên dưới chart): Xem tất cả lệnh đã đóng

### Tạm dừng bot

- Click nút **Algo Trading** trên toolbar để TẮT (chuyển sang màu đỏ)
- Bot sẽ ngừng mở lệnh mới nhưng lệnh đang mở vẫn giữ nguyên

### Gỡ bot

- Click chuột phải trên chart → **Expert Advisors** → **Remove**

---

## 🧪 Backtest

### Kiểm tra bot trên dữ liệu lịch sử trước khi chạy thật

1. Vào **View** → **Strategy Tester** (hoặc nhấn `Ctrl + R`)
2. Cấu hình:
   - **Expert**: GoldScalper_EA
   - **Symbol**: XAUUSD
   - **Period**: M1
   - **Date**: Chọn khoảng thời gian muốn test
   - **Modeling**: **Every tick based on real ticks** (chính xác nhất)
   - **Deposit**: Nhập số vốn thử nghiệm
3. Click **Start** để bắt đầu backtest
4. Xem kết quả ở các tab: **Results**, **Graph**, **Report**

---

## ⚠️ Lưu ý quan trọng

### 🔴 Cảnh báo rủi ro

> **GIAO DỊCH VÀNG CÓ RỦI RO CAO!** Bot này là công cụ hỗ trợ, KHÔNG đảm bảo lợi nhuận.
> Chỉ giao dịch với số tiền bạn chấp nhận được mất.

### 📌 Khuyến nghị sử dụng

1. **LUÔN test trên tài khoản Demo trước** ít nhất 1-2 tuần
2. **Backtest kỹ lưỡng** trước khi chạy thật
3. **Bắt đầu với lot nhỏ nhất** (0.01)
4. **Theo dõi thường xuyên**, đặc biệt trong tuần đầu
5. **Dùng VPS** nếu muốn bot chạy 24/7 ổn định
6. **Tránh thời điểm tin tức lớn** (NFP, FOMC, CPI) - có thể bật Time Filter

### 📌 Khi nào KHÔNG nên chạy bot

- Khi có tin tức kinh tế quan trọng (NFP, FOMC...)
- Khi thị trường quá biến động bất thường
- Khi spread quá cao (bot sẽ tự dừng nếu spread > Max Spread)
- Cuối tuần (thị trường đóng cửa)

### 📌 Xử lý sự cố

| Vấn đề | Cách xử lý |
|--------|------------|
| Bot không mở lệnh | Kiểm tra: Auto Trading đã bật? Spread có quá cao? |
| Mặt buồn trên chart | Vào Properties → Common → tick Allow Algo Trading |
| Lỗi biên dịch | Kiểm tra file .mq5 đầy đủ, nhấn F7 lại |
| Bot thua liên tục | Dừng bot, kiểm tra lại cấu hình, backtest lại |

---

## 📞 Hỗ trợ

Nếu gặp vấn đề, kiểm tra:
1. Tab **Experts** trong MT5 để đọc log lỗi
2. Tab **Journal** để xem thông tin hệ thống
3. Đảm bảo kết nối internet ổn định
4. Đảm bảo broker cho phép giao dịch tự động (Algo Trading)

---

**Chúc bạn giao dịch thành công! 🚀💰**
