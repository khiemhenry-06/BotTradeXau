# 🤖 BotTradeXau - Repository Expert Advisors (EA) Cho MT5

Chào mừng bạn đến với kho lưu trữ mã nguồn các bot giao dịch tự động (**Expert Advisors - EA**) chạy trên nền tảng **MetaTrader 5 (MT5)**. Kho lưu trữ này chứa các bot giao dịch scalping tự động được tối ưu hóa cho các thị trường biến động mạnh như **Vàng (XAUUSD)** và **Bitcoin (BTCUSD)**.

---

## 📁 Cấu trúc thư mục

Dưới đây là tổng quan về các thư mục trong repository này:

```
📁 BotTradeXau
 ├── 📁 trade_vang             # Bot scalping Vàng (RSI + BB)
 │    ├── 📄 GoldScalper_EA.mq5     
 │    └── 📄 README.md              
 ├── 📁 trade_vang_grid        # Bot lưới (Grid Trading) cho Vàng
 │    ├── 📄 GoldGrid_EA.mq5     
 │    └── 📄 HUONG_DAN.md           
 ├── 📁 trade_vang_martingale  # Bot nhồi lệnh (DCA/Martingale) cho Vàng
 │    ├── 📄 GoldMartingale_EA.mq5  
 │    └── 📄 HUONG_DAN.md           
 ├── 📁 trade_vang_breakout    # Bot phá vỡ xu hướng (Breakout) cho Vàng
 │    ├── 📄 GoldBreakout_EA.mq5    
 │    └── 📄 HUONG_DAN.md           
 ├── 📁 trade_bitcoin          # Bot giao dịch Bitcoin (Multi-indicator)
 │    ├── 📄 BTCScalper_EA.mq5     
 │    └── 📄 HUONG_DAN.md           
 └── 📄 README.md              # File tổng quan (file này)
```

---

## 🚀 Giới thiệu các Bot Giao Dịch

### 1. 🏆 Gold Scalper Bot (`trade_vang`)

Bot được thiết kế riêng cho thị trường Vàng (XAUUSD) với phong cách **đánh nhanh thắng nhanh** nhằm tối ưu hóa lợi nhuận trong thời gian ngắn và giảm thiểu rủi ro.

*   **Thời gian giao dịch tối ưu:** Khung thời gian **M1** (1 Phút).
*   **Chiến lược cốt lõi:** Kết hợp **RSI (7)** + **Bollinger Bands (14)** + **EMA (50)**.
*   **Điểm mạnh:**
    *   Tự động tính toán Take Profit và Stop Loss linh hoạt theo số vốn.
    *   Sử dụng **Trailing Stop** dời điểm Stop Loss theo đà giá để tối đa hóa lợi nhuận.
    *   **Lọc Spread** an toàn, ngăn không vào lệnh khi thị trường biến động quá mạnh hoặc thanh khoản thấp.
*   **Chi tiết & Cài đặt:** Xem tại [trade_vang/README.md](file:///e:/ide/antigravity/trade_bot/trade_vang/README.md).

### 2. 🕸️ Gold Grid Bot (`trade_vang_grid`)
Chiến lược giao dịch theo lưới (Grid Trading), tối ưu khi thị trường đi ngang (Sideway) hoặc dao động trong biên độ. Bot liên tục rải lệnh chờ Buy/Sell cách đều nhau để ăn từng nhịp sóng nhỏ.

### 3. 📉 Gold Martingale Bot (`trade_vang_martingale`)
Chiến lược gồng lỗ/nhồi lệnh (DCA) theo cấp số nhân. Bot sẽ nhồi thêm lệnh với khối lượng lớn hơn khi giá đi ngược hướng, giúp nhanh chóng chốt lời toàn bộ khi giá hồi phục một chút. **Yêu cầu vốn lớn và quản lý rủi ro chặt chẽ.**

### 4. 🚀 Gold Breakout Bot (`trade_vang_breakout`)
Chiến lược giao dịch bùng nổ (Breakout). Bot tính toán Đỉnh/Đáy của một vùng nén giá (ví dụ 20 nến M15) và chỉ vào lệnh khi giá phá vỡ mạnh qua các mốc này (kèm theo khoảng đệm để tránh nhiễu).

### 5. 🪙 BTC Scalper Pro (`trade_bitcoin`)
Bot được thiết kế cho thị trường Bitcoin (BTCUSD) với **hệ thống chấm điểm đa chỉ báo nâng cao** (Scoring System) và **đa khung thời gian** (Multi-Timeframe), phù hợp cho việc giao dịch một tài sản có biên độ dao động lớn như tiền điện tử.

*   **Thời gian giao dịch tối ưu:** Khung thời gian **M1** (vào lệnh) và **M15** (lọc xu hướng).
*   **Chiến lược cốt lõi:** **Scoring System** chấm điểm từ 7 chỉ báo kỹ thuật hàng đầu:
    *   **EMA Crossover (8/21)** & **Trend EMA (50)**.
    *   **RSI Divergence** & **Bollinger Squeeze Breakout**.
    *   **ADX & DI** (Lọc sức mạnh xu hướng).
    *   **MACD** & **Stochastic** (Momentum).
*   **Điểm mạnh:**
    *   Chỉ vào lệnh khi hệ thống chấm điểm đạt từ 6/18 điểm trở lên.
    *   **ATR Dynamic Stop Loss**: Stop Loss co giãn tự động theo biên độ dao động thực tế của Bitcoin.
    *   **Breakeven & Trailing**: Bảo toàn vốn khi giá đi đúng hướng trước khi dời Trail Stop.
    *   **Daily Loss Protection**: Tự động dừng giao dịch trong ngày nếu chạm mức lỗ tối đa cho phép.
*   **Chi tiết & Cài đặt:** Xem tại [trade_bitcoin/HUONG_DAN.md](file:///e:/ide/antigravity/trade_bot/trade_bitcoin/HUONG_DAN.md).

---

## ⚙️ Quy trình cài đặt chung cho MT5

Để cài đặt bất kỳ bot nào trong repo này, hãy thực hiện các bước sau:

1.  **Sao chép mã nguồn:** Tải file `.mq5` từ thư mục mong muốn (`trade_vang` hoặc `trade_bitcoin`).
2.  **Mở thư mục dữ liệu MT5:** Trên phần mềm MetaTrader 5, chọn **File** -> **Open Data Folder** (hoặc bấm `Ctrl + Shift + D`).
3.  **Di chuyển file:** Dán file vừa copy vào đường dẫn `MQL5\Experts\`.
4.  **Biên dịch (Compile):** Bật **MetaEditor** (Phím `F4` trên MT5), tìm file vừa dán và bấm **Compile** (Phím `F7`).
5.  **Bật Auto Trading:** Quay lại MT5, kéo thả bot vào chart tài sản tương ứng (XAUUSD hoặc BTCUSD) và bật nút **Algo Trading** trên thanh công cụ.

---

## ⚠️ Khuyến cáo rủi ro

> [!IMPORTANT]
> Giao dịch tài chính (Vàng, Crypto) luôn tiềm ẩn rủi ro rất cao. Các bot giao dịch tự động trong kho lưu trữ này được phát triển cho mục đích tham khảo và hỗ trợ giao dịch:
> *   **LUÔN LUÔN** chạy thử nghiệm (Backtest) và giao dịch trên tài khoản **Demo** ít nhất 1 - 2 tuần trước khi sử dụng tài khoản thật.
> *   Không giao dịch với số tiền mà bạn không thể chấp nhận rủi ro bị mất.

---

**Chúc bạn giao dịch thành công! 📈💰**
