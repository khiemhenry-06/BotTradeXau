//+------------------------------------------------------------------+
//|                                           GoldBreakout_EA.mq5    |
//|                                  Gold Breakout Trading Strategy  |
//+------------------------------------------------------------------+
#property copyright "Gold Breakout Bot"
#property version   "1.00"
#property description "Bot danh pha vo (Breakout) cho Vang"

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\SymbolInfo.mqh>

input group "=== CAU HINH BREAKOUT ==="
input double   InpLotSize        = 0.05;    // Lot Size
input int      InpBreakoutCandles= 20;      // So nen de xac dinh High/Low (Period)
input int      InpTakeProfit     = 500;     // Take Profit (Points)
input int      InpStopLoss       = 300;     // Stop Loss (Points)
input int      InpBuffer         = 20;      // Khoang cach Buffer phu (Points)
input int      InpDelaySeconds   = 3600;    // Thoi gian cho giua 2 lan giao dich (Giay)

input group "=== CAU HINH CHUNG ==="
input int      InpMagicNumber    = 44444;

CTrade         trade;
CPositionInfo  posInfo;
CSymbolInfo    symInfo;
datetime       lastTradeTime     = 0;

int OnInit()
{
   if(!symInfo.Name(_Symbol)) return INIT_FAILED;
   trade.SetExpertMagicNumber(InpMagicNumber);
   Print("Gold Breakout Bot Started!");
   return INIT_SUCCEEDED;
}

void OnTick()
{
   symInfo.RefreshRates();
   
   if(PositionsTotal() > 0) 
   {
      // Chi cho phep 1 lenh breakout o 1 thoi diem
      DisplayInfo(0, 0);
      return; 
   }
   
   if(TimeCurrent() - lastTradeTime < InpDelaySeconds)
   {
      DisplayInfo(0, 0);
      return;
   }
   
   // Tinh High / Low cua N nen gan nhat
   double high[], low[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   
   if(CopyHigh(_Symbol, PERIOD_CURRENT, 1, InpBreakoutCandles, high) < InpBreakoutCandles) return;
   if(CopyLow(_Symbol, PERIOD_CURRENT, 1, InpBreakoutCandles, low) < InpBreakoutCandles) return;
   
   double highestHigh = high[0];
   double lowestLow = low[0];
   
   for(int i=1; i<InpBreakoutCandles; i++)
   {
      if(high[i] > highestHigh) highestHigh = high[i];
      if(low[i] < lowestLow) lowestLow = low[i];
   }
   
   double ask = symInfo.Ask();
   double bid = symInfo.Bid();
   double point = symInfo.Point();
   
   double upperBreakoutLevel = highestHigh + InpBuffer * point;
   double lowerBreakoutLevel = lowestLow - InpBuffer * point;
   
   // Breakout Buy
   if(ask >= upperBreakoutLevel)
   {
      double sl = ask - InpStopLoss * point;
      double tp = ask + InpTakeProfit * point;
      if(trade.Buy(InpLotSize, _Symbol, ask, sl, tp, "Breakout Buy"))
      {
         lastTradeTime = TimeCurrent();
      }
   }
   // Breakout Sell
   else if(bid <= lowerBreakoutLevel)
   {
      double sl = bid + InpStopLoss * point;
      double tp = bid - InpTakeProfit * point;
      if(trade.Sell(InpLotSize, _Symbol, bid, sl, tp, "Breakout Sell"))
      {
         lastTradeTime = TimeCurrent();
      }
   }
   
   DisplayInfo(highestHigh, lowestLow);
}

void DisplayInfo(double h, double l)
{
   string s = "=== GOLD BREAKOUT ===\n";
   if(h > 0 && l > 0)
   {
      s += "Highest ("+IntegerToString(InpBreakoutCandles)+"): " + DoubleToString(h, 2) + "\n";
      s += "Lowest ("+IntegerToString(InpBreakoutCandles)+"): " + DoubleToString(l, 2) + "\n";
   }
   else
   {
      s += "Waiting / Trading in progress...\n";
   }
   Comment(s);
}
//+------------------------------------------------------------------+
