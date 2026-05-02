# 🪙 HƯỚNG DẪN CÀI ĐẶT BTC SCALPER PRO

## Giới thiệu
Bot scalp Bitcoin (BTCUSD) trên MT5 sử dụng **hệ thống chấm điểm đa chỉ báo** (Scoring System) - kỹ thuật được các trader chuyên nghiệp sử dụng.

### Các kỹ thuật nâng cao được tích hợp:
| Kỹ thuật | Mô tả |
|----------|-------|
| **Multi-Indicator Scoring** | Chấm điểm từ 7 chỉ báo, chỉ vào lệnh khi score ≥ 6/18 |
| **Multi-Timeframe (MTF)** | Kiểm tra xu hướng M15 trước khi vào lệnh M1 |
| **EMA Crossover (8/21)** | Tín hiệu Golden/Death cross |
| **RSI + Bollinger Bands** | Phát hiện quá mua/bán + biên độ giá |
| **ADX + DI** | Lọc sức mạnh xu hướng (chỉ trade khi ADX > 20) |
| **MACD Crossover** | Xác nhận momentum |
| **Stochastic** | Tín hiệu đảo chiều vùng quá mua/bán |
| **ATR Dynamic SL** | Stop Loss tự điều chỉnh theo biến động |
| **Breakeven + Trailing** | Bảo vệ vốn: dời SL về entry rồi trail |
| **Daily Loss Limit** | Tự dừng khi lỗ vượt ngưỡng/ngày |

---

## Cài đặt nhanh (3 bước)

### 1. Copy file EA
- Mở MT5 → **File** → **Open Data Folder**
- Copy `BTCScalper_EA.mq5` vào `MQL5\Experts\`

### 2. Biên dịch
- Nhấn **F4** (mở MetaEditor) → mở file → nhấn **F7** (Compile)
- Phải thấy `0 error(s)` = thành công

### 3. Gắn lên chart
- Mở chart **BTCUSD** khung **M1**
- Kéo thả `BTCScalper_EA` từ Navigator lên chart
- Tab **Common**: ✅ Allow Algo Trading
- Bật nút **Algo Trading** trên toolbar (phải chuyển xanh)
- Thấy 😊 trên chart = Bot đang chạy!

---

## Cấu hình theo vốn

| Vốn | Lot | TP | SL | Max Pos |
|-----|-----|----|----|---------|
| $200 | 0.01 | $3 | $5 | 1 |
| $500 | 0.01-0.02 | $5 | $8 | 1 |
| $1000+ | 0.02-0.05 | $5-8 | $8-12 | 1-2 |

---

## Cách hệ thống Scoring hoạt động

Bot chấm điểm mỗi tín hiệu. Chỉ vào lệnh khi **tổng điểm ≥ 6**:

| Tín hiệu | Điểm mạnh | Điểm yếu |
|-----------|-----------|-----------|
| EMA Cross (8/21) | +3 | +1 (chỉ trending) |
| RSI quá mua/bán | +3 | +1 (vùng trung tính) |
| Bollinger Band | +2 | - |
| ADX + DI | +2 | - |
| MACD Cross | +3 | +1 (chỉ hướng) |
| Stochastic Cross | +2 | +1 (chỉ hướng) |
| Trend EMA | +1 | - |
| BB Squeeze Breakout | +2 | - |
| **Tổng tối đa** | **18** | |

MTF filter có thể **trừ 3 điểm** nếu tín hiệu ngược xu hướng lớn.

---

## Lưu ý quan trọng

> ⚠️ **LUÔN TEST TRÊN TÀI KHOẢN DEMO TRƯỚC** ít nhất 2 tuần!

- Bitcoin biến động mạnh hơn vàng → spread có thể rất cao
- Tránh trade khi có tin tức crypto lớn
- Bot sẽ tự dừng khi lỗ vượt **Max Daily Loss**
- Dùng **Strategy Tester** (Ctrl+R) để backtest trước

---

**Chúc bạn trade thành công! 🚀**
