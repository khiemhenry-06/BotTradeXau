//+------------------------------------------------------------------+
//|                                              GoldScalper_EA.mq5  |
//|                                         Gold Scalping Expert Bot |
//|                          Chien luoc: Scalp nhanh, thang nhanh    |
//+------------------------------------------------------------------+
#property copyright "GoldScalper Bot"
#property link      ""
#property version   "1.00"
#property strict
#property description "Bot scalp vang XAUUSD - Danh nhanh thang nhanh"
#property description "Su dung RSI + Bollinger Bands + EMA Filter"

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\SymbolInfo.mqh>

//+------------------------------------------------------------------+
//| INPUT PARAMETERS - CAU HINH BOT                                  |
//+------------------------------------------------------------------+
input group "=== CAU HINH GIAO DICH ==="
input double   InpLotSize        = 0.01;    // Lot Size (0.01 = micro lot)
input double   InpTakeProfit     = 3.0;     // Take Profit (USD/lot) - Muc tien lai mong muon
input double   InpStopLoss       = 5.0;     // Stop Loss (USD/lot) - Muc cat lo
input int      InpMaxPositions   = 1;       // So lenh toi da cung luc
input int      InpMagicNumber    = 12345;   // Magic Number (de phan biet bot)

input group "=== CHI BAO KY THUAT ==="
input int      InpRSIPeriod      = 7;       // RSI Period (ngan cho scalp)
input int      InpRSIOverbought  = 75;      // RSI Overbought (qua mua)
input int      InpRSIOversold    = 25;      // RSI Oversold (qua ban)
input int      InpBBPeriod       = 14;      // Bollinger Bands Period
input double   InpBBDeviation    = 2.0;     // Bollinger Bands Deviation
input int      InpEMAPeriod      = 50;      // EMA Period (loc xu huong)
input int      InpATRPeriod      = 14;      // ATR Period

input group "=== BO LOC AN TOAN ==="
input int      InpMaxSpread      = 40;      // Spread toi da cho phep (points)
input int      InpDelaySeconds   = 5;       // Thoi gian cho giua 2 lenh (giay)
input bool     InpUseTimeFilter  = false;   // Su dung bo loc thoi gian
input int      InpStartHour      = 8;       // Gio bat dau giao dich (server)
input int      InpEndHour        = 22;      // Gio ket thuc giao dich (server)

input group "=== TRAILING STOP ==="
input bool     InpUseTrailing    = true;    // Su dung Trailing Stop
input double   InpTrailingStart  = 2.0;     // Bat dau trail khi lai (USD/lot)
input double   InpTrailingStep   = 0.5;     // Buoc trail (USD/lot)

//+------------------------------------------------------------------+
//| GLOBAL VARIABLES                                                 |
//+------------------------------------------------------------------+
CTrade         trade;
CPositionInfo  posInfo;
CSymbolInfo    symInfo;

int            handleRSI;
int            handleBB;
int            handleEMA;
int            handleATR;

datetime       lastTradeTime;
int            totalWins;
int            totalLosses;
double         totalProfit;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Kiem tra symbol
   if(!symInfo.Name(_Symbol))
   {
      Print("LOI: Khong the lay thong tin symbol!");
      return(INIT_FAILED);
   }
   
   // Khoi tao chi bao
   handleRSI = iRSI(_Symbol, PERIOD_M1, InpRSIPeriod, PRICE_CLOSE);
   handleBB  = iBands(_Symbol, PERIOD_M1, InpBBPeriod, 0, InpBBDeviation, PRICE_CLOSE);
   handleEMA = iMA(_Symbol, PERIOD_M5, InpEMAPeriod, 0, MODE_EMA, PRICE_CLOSE);
   handleATR = iATR(_Symbol, PERIOD_M1, InpATRPeriod);
   
   if(handleRSI == INVALID_HANDLE || handleBB == INVALID_HANDLE || 
      handleEMA == INVALID_HANDLE || handleATR == INVALID_HANDLE)
   {
      Print("LOI: Khong the khoi tao chi bao ky thuat!");
      return(INIT_FAILED);
   }
   
   // Cau hinh trade
   trade.SetExpertMagicNumber(InpMagicNumber);
   trade.SetDeviationInPoints(10);
   trade.SetTypeFilling(ORDER_FILLING_IOC);
   
   // Reset thong ke
   lastTradeTime = 0;
   totalWins     = 0;
   totalLosses   = 0;
   totalProfit   = 0;
   
   Print("========================================");
   Print("  GOLD SCALPER BOT - DA KHOI DONG!");
   Print("  Symbol: ", _Symbol);
   Print("  Lot: ", InpLotSize);
   Print("  TP: $", InpTakeProfit, " | SL: $", InpStopLoss);
   Print("========================================");
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Giai phong chi bao
   if(handleRSI != INVALID_HANDLE) IndicatorRelease(handleRSI);
   if(handleBB  != INVALID_HANDLE) IndicatorRelease(handleBB);
   if(handleEMA != INVALID_HANDLE) IndicatorRelease(handleEMA);
   if(handleATR != INVALID_HANDLE) IndicatorRelease(handleATR);
   
   Print("========================================");
   Print("  GOLD SCALPER - KET QUA:");
   Print("  Thang: ", totalWins, " | Thua: ", totalLosses);
   Print("  Tong loi nhuan: $", DoubleToString(totalProfit, 2));
   Print("========================================");
   
   Comment("");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Cap nhat thong tin symbol
   symInfo.RefreshRates();
   
   // Hien thi thong tin tren chart
   DisplayInfo();
   
   // Quan ly trailing stop
   if(InpUseTrailing)
      ManageTrailingStop();
   
   // Kiem tra dieu kien co ban
   if(!CheckBasicConditions())
      return;
   
   // Lay du lieu chi bao
   double rsi[], upperBB[], lowerBB[], middleBB[], ema[], atr[];
   
   if(!GetIndicatorData(rsi, upperBB, lowerBB, middleBB, ema, atr))
      return;
   
   double ask = symInfo.Ask();
   double bid = symInfo.Bid();
   double point = symInfo.Point();
   
   // Tinh TP va SL theo price
   // Voi Gold: 1 point thường = $0.01/lot (tuy broker)
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   
   double tpPoints = 0;
   double slPoints = 0;
   
   if(tickValue > 0 && tickSize > 0)
   {
      tpPoints = (InpTakeProfit / (tickValue / tickSize)) / InpLotSize;
      slPoints = (InpStopLoss  / (tickValue / tickSize)) / InpLotSize;
   }
   else
   {
      // Fallback: uoc luong cho gold
      tpPoints = InpTakeProfit * 10;
      slPoints = InpStopLoss * 10;
   }
   
   // === TIN HIEU MUA (BUY) ===
   if(CheckBuySignal(rsi, upperBB, lowerBB, middleBB, ema, atr, bid))
   {
      double sl = NormalizeDouble(ask - slPoints * point, (int)symInfo.Digits());
      double tp = NormalizeDouble(ask + tpPoints * point, (int)symInfo.Digits());
      
      if(trade.Buy(InpLotSize, _Symbol, ask, sl, tp, "GoldScalp BUY"))
      {
         lastTradeTime = TimeCurrent();
         Print(">> MO LENH BUY | Gia: ", ask, " | SL: ", sl, " | TP: ", tp);
      }
      else
      {
         Print("LOI MO LENH BUY: ", trade.ResultRetcodeDescription());
      }
   }
   
   // === TIN HIEU BAN (SELL) ===
   if(CheckSellSignal(rsi, upperBB, lowerBB, middleBB, ema, atr, bid))
   {
      double sl = NormalizeDouble(bid + slPoints * point, (int)symInfo.Digits());
      double tp = NormalizeDouble(bid - tpPoints * point, (int)symInfo.Digits());
      
      if(trade.Sell(InpLotSize, _Symbol, bid, sl, tp, "GoldScalp SELL"))
      {
         lastTradeTime = TimeCurrent();
         Print(">> MO LENH SELL | Gia: ", bid, " | SL: ", sl, " | TP: ", tp);
      }
      else
      {
         Print("LOI MO LENH SELL: ", trade.ResultRetcodeDescription());
      }
   }
}

//+------------------------------------------------------------------+
//| Kiem tra dieu kien co ban                                        |
//+------------------------------------------------------------------+
bool CheckBasicConditions()
{
   // Kiem tra spread
   int currentSpread = (int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   if(currentSpread > InpMaxSpread)
   {
      return false;
   }
   
   // Kiem tra so lenh hien tai
   int currentPositions = CountMyPositions();
   if(currentPositions >= InpMaxPositions)
   {
      return false;
   }
   
   // Kiem tra thoi gian cho giua 2 lenh
   if(TimeCurrent() - lastTradeTime < InpDelaySeconds)
   {
      return false;
   }
   
   // Bo loc thoi gian
   if(InpUseTimeFilter)
   {
      MqlDateTime dt;
      TimeToStruct(TimeCurrent(), dt);
      if(dt.hour < InpStartHour || dt.hour >= InpEndHour)
         return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Lay du lieu chi bao                                              |
//+------------------------------------------------------------------+
bool GetIndicatorData(double &rsi[], double &upperBB[], double &lowerBB[], 
                      double &middleBB[], double &ema[], double &atr[])
{
   ArraySetAsSeries(rsi, true);
   ArraySetAsSeries(upperBB, true);
   ArraySetAsSeries(lowerBB, true);
   ArraySetAsSeries(middleBB, true);
   ArraySetAsSeries(ema, true);
   ArraySetAsSeries(atr, true);
   
   if(CopyBuffer(handleRSI, 0, 0, 3, rsi)     < 3) return false;
   if(CopyBuffer(handleBB,  0, 0, 3, middleBB)< 3) return false;
   if(CopyBuffer(handleBB,  1, 0, 3, upperBB) < 3) return false;
   if(CopyBuffer(handleBB,  2, 0, 3, lowerBB) < 3) return false;
   if(CopyBuffer(handleEMA, 0, 0, 3, ema)     < 3) return false;
   if(CopyBuffer(handleATR, 0, 0, 3, atr)     < 3) return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Kiem tra tin hieu MUA                                            |
//+------------------------------------------------------------------+
bool CheckBuySignal(double &rsi[], double &upperBB[], double &lowerBB[],
                    double &middleBB[], double &ema[], double &atr[], double price)
{
   // Dieu kien 1: RSI qua ban (oversold)
   bool rsiOversold = (rsi[0] < InpRSIOversold);
   
   // Dieu kien 2: Gia cham hoac duoi Lower Bollinger Band
   bool priceBelowLowerBB = (price <= lowerBB[0]);
   
   // Dieu kien 3: RSI dang tang len (momentum)
   bool rsiRising = (rsi[0] > rsi[1]);
   
   // Ket hop: RSI oversold + Gia duoi Lower BB + RSI bat dau tang
   if(rsiOversold && priceBelowLowerBB && rsiRising)
      return true;
   
   // Tin hieu phu: RSI rat thap + gia gan Lower BB
   if(rsi[0] < (InpRSIOversold - 5) && price < (lowerBB[0] + atr[0] * 0.3))
      return true;
   
   return false;
}

//+------------------------------------------------------------------+
//| Kiem tra tin hieu BAN                                            |
//+------------------------------------------------------------------+
bool CheckSellSignal(double &rsi[], double &upperBB[], double &lowerBB[],
                     double &middleBB[], double &ema[], double &atr[], double price)
{
   // Dieu kien 1: RSI qua mua (overbought)
   bool rsiOverbought = (rsi[0] > InpRSIOverbought);
   
   // Dieu kien 2: Gia cham hoac tren Upper Bollinger Band
   bool priceAboveUpperBB = (price >= upperBB[0]);
   
   // Dieu kien 3: RSI dang giam (momentum)
   bool rsiFalling = (rsi[0] < rsi[1]);
   
   // Ket hop: RSI overbought + Gia tren Upper BB + RSI bat dau giam
   if(rsiOverbought && priceAboveUpperBB && rsiFalling)
      return true;
   
   // Tin hieu phu: RSI rat cao + gia gan Upper BB
   if(rsi[0] > (InpRSIOverbought + 5) && price > (upperBB[0] - atr[0] * 0.3))
      return true;
   
   return false;
}

//+------------------------------------------------------------------+
//| Dem so lenh cua bot                                              |
//+------------------------------------------------------------------+
int CountMyPositions()
{
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(posInfo.SelectByIndex(i))
      {
         if(posInfo.Magic() == InpMagicNumber && posInfo.Symbol() == _Symbol)
            count++;
      }
   }
   return count;
}

//+------------------------------------------------------------------+
//| Quan ly Trailing Stop                                            |
//+------------------------------------------------------------------+
void ManageTrailingStop()
{
   double point = symInfo.Point();
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(!posInfo.SelectByIndex(i)) continue;
      if(posInfo.Magic() != InpMagicNumber) continue;
      if(posInfo.Symbol() != _Symbol) continue;
      
      double openPrice = posInfo.PriceOpen();
      double currentSL = posInfo.StopLoss();
      double profit    = posInfo.Profit();
      
      // Chi trail khi da co lai du
      double trailStartProfit = InpTrailingStart * InpLotSize;
      
      if(profit < trailStartProfit) continue;
      
      double trailStepPrice = 0;
      if(tickValue > 0 && tickSize > 0)
         trailStepPrice = (InpTrailingStep / (tickValue / tickSize)) / InpLotSize * point;
      else
         trailStepPrice = InpTrailingStep * 10 * point;
      
      if(posInfo.PositionType() == POSITION_TYPE_BUY)
      {
         double bid = symInfo.Bid();
         double newSL = NormalizeDouble(bid - trailStepPrice, (int)symInfo.Digits());
         
         if(newSL > currentSL && newSL > openPrice)
         {
            trade.PositionModify(posInfo.Ticket(), newSL, posInfo.TakeProfit());
         }
      }
      else if(posInfo.PositionType() == POSITION_TYPE_SELL)
      {
         double ask = symInfo.Ask();
         double newSL = NormalizeDouble(ask + trailStepPrice, (int)symInfo.Digits());
         
         if((newSL < currentSL || currentSL == 0) && newSL < openPrice)
         {
            trade.PositionModify(posInfo.Ticket(), newSL, posInfo.TakeProfit());
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Hien thi thong tin tren chart                                    |
//+------------------------------------------------------------------+
void DisplayInfo()
{
   // Dem lenh va tinh loi nhuan
   int openPositions = 0;
   double openProfit = 0;
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(posInfo.SelectByIndex(i))
      {
         if(posInfo.Magic() == InpMagicNumber && posInfo.Symbol() == _Symbol)
         {
            openPositions++;
            openProfit += posInfo.Profit() + posInfo.Swap() + posInfo.Commission();
         }
      }
   }
   
   int currentSpread = (int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   
   // Lay RSI hien tai
   double rsiVal[];
   ArraySetAsSeries(rsiVal, true);
   CopyBuffer(handleRSI, 0, 0, 1, rsiVal);
   
   string info = "";
   info += "╔══════════════════════════════════╗\n";
   info += "║     GOLD SCALPER BOT v1.0       ║\n";
   info += "╠══════════════════════════════════╣\n";
   info += "║ Spread: " + IntegerToString(currentSpread) + 
           (currentSpread <= InpMaxSpread ? " ✓" : " ✗ (qua cao)") + "\n";
   info += "║ RSI: " + (ArraySize(rsiVal) > 0 ? DoubleToString(rsiVal[0], 1) : "N/A") + "\n";
   info += "║ Lenh mo: " + IntegerToString(openPositions) + "/" + IntegerToString(InpMaxPositions) + "\n";
   info += "║ P/L hien tai: $" + DoubleToString(openProfit, 2) + "\n";
   info += "╠══════════════════════════════════╣\n";
   info += "║ Thang: " + IntegerToString(totalWins) + " | Thua: " + IntegerToString(totalLosses) + "\n";
   info += "║ Tong P/L: $" + DoubleToString(totalProfit, 2) + "\n";
   info += "╚══════════════════════════════════╝\n";
   
   Comment(info);
}

//+------------------------------------------------------------------+
//| Theo doi giao dich (cap nhat thong ke)                           |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
{
   if(trans.type == TRADE_TRANSACTION_DEAL_ADD)
   {
      // Kiem tra xem deal co phai cua bot khong
      if(trans.order_state == ORDER_STATE_FILLED)
      {
         // Lay thong tin deal
         if(HistoryDealSelect(trans.deal))
         {
            long dealMagic = HistoryDealGetInteger(trans.deal, DEAL_MAGIC);
            long dealEntry = HistoryDealGetInteger(trans.deal, DEAL_ENTRY);
            
            if(dealMagic == InpMagicNumber && dealEntry == DEAL_ENTRY_OUT)
            {
               double dealProfit = HistoryDealGetDouble(trans.deal, DEAL_PROFIT);
               double dealComm   = HistoryDealGetDouble(trans.deal, DEAL_COMMISSION);
               double dealSwap   = HistoryDealGetDouble(trans.deal, DEAL_SWAP);
               double netProfit  = dealProfit + dealComm + dealSwap;
               
               totalProfit += netProfit;
               
               if(netProfit >= 0)
               {
                  totalWins++;
                  Print(">> THANG! Lai: $", DoubleToString(netProfit, 2),
                        " | Tong: ", totalWins, "W/", totalLosses, "L");
               }
               else
               {
                  totalLosses++;
                  Print(">> THUA! Lo: $", DoubleToString(netProfit, 2),
                        " | Tong: ", totalWins, "W/", totalLosses, "L");
               }
            }
         }
      }
   }
}
//+------------------------------------------------------------------+
