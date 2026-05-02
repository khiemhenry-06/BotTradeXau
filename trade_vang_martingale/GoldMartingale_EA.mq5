//+------------------------------------------------------------------+
//|                                          GoldMartingale_EA.mq5   |
//|                                  Gold Martingale (DCA) Strategy  |
//+------------------------------------------------------------------+
#property copyright "Gold Martingale Bot"
#property version   "1.00"
#property description "Bot trung binh gia / nhan doi (Martingale) cho Vang"

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\SymbolInfo.mqh>

input group "=== CAU HINH MARTINGALE ==="
input double   InpInitialLot     = 0.01;    // Lot Size ban dau
input double   InpMultiplier     = 2.0;     // He so nhan Lot (Martingale)
input int      InpStepDistance   = 300;     // Khoang cach DCA (Points)
input double   InpTakeProfit     = 5.0;     // Muc tieu chot loi tong (USD)
input int      InpMaxTrades      = 7;       // So lan gap lenh toi da

input group "=== CAU HINH CHUNG ==="
input int      InpMagicNumber    = 33333;

CTrade         trade;
CPositionInfo  posInfo;
CSymbolInfo    symInfo;

int            totalBuyTrades    = 0;
int            totalSellTrades   = 0;
double         lastBuyPrice      = 0;
double         lastSellPrice     = 0;
double         currentBuyLot     = 0;
double         currentSellLot    = 0;

int OnInit()
{
   if(!symInfo.Name(_Symbol)) return INIT_FAILED;
   trade.SetExpertMagicNumber(InpMagicNumber);
   Print("Gold Martingale Bot Started!");
   return INIT_SUCCEEDED;
}

void OnTick()
{
   symInfo.RefreshRates();
   double ask = symInfo.Ask();
   double bid = symInfo.Bid();
   double point = symInfo.Point();
   
   AnalyzePositions();
   CheckTakeProfit();

   // Entry co ban: Neu khong co lenh nao, vao 1 lenh BUY va 1 lenh SELL (Hedging Martingale)
   if(totalBuyTrades == 0 && totalSellTrades == 0)
   {
      if(trade.Buy(InpInitialLot, _Symbol, ask, 0, 0, "Martingale Start Buy"))
      {
         lastBuyPrice = ask;
         currentBuyLot = InpInitialLot;
      }
      if(trade.Sell(InpInitialLot, _Symbol, bid, 0, 0, "Martingale Start Sell"))
      {
         lastSellPrice = bid;
         currentSellLot = InpInitialLot;
      }
   }
   else
   {
      // Kiem tra khoang cach DCA cho BUY
      if(totalBuyTrades > 0 && totalBuyTrades < InpMaxTrades)
      {
         if(lastBuyPrice - ask >= InpStepDistance * point)
         {
            double newLot = NormalizeDouble(currentBuyLot * InpMultiplier, 2);
            if(trade.Buy(newLot, _Symbol, ask, 0, 0, "Martingale DCA Buy"))
            {
               lastBuyPrice = ask;
               currentBuyLot = newLot;
            }
         }
      }
      // Kiem tra khoang cach DCA cho SELL
      if(totalSellTrades > 0 && totalSellTrades < InpMaxTrades)
      {
         if(bid - lastSellPrice >= InpStepDistance * point)
         {
            double newLot = NormalizeDouble(currentSellLot * InpMultiplier, 2);
            if(trade.Sell(newLot, _Symbol, bid, 0, 0, "Martingale DCA Sell"))
            {
               lastSellPrice = bid;
               currentSellLot = newLot;
            }
         }
      }
   }
   
   DisplayInfo();
}

void AnalyzePositions()
{
   totalBuyTrades = 0;
   totalSellTrades = 0;
   double lowestBuy = 999999;
   double highestSell = 0;
   double maxBuyLot = 0;
   double maxSellLot = 0;
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(posInfo.SelectByIndex(i))
      {
         if(posInfo.Magic() == InpMagicNumber && posInfo.Symbol() == _Symbol)
         {
            if(posInfo.PositionType() == POSITION_TYPE_BUY)
            {
               totalBuyTrades++;
               if(posInfo.PriceOpen() < lowestBuy) lowestBuy = posInfo.PriceOpen();
               if(posInfo.Volume() > maxBuyLot) maxBuyLot = posInfo.Volume();
            }
            else if(posInfo.PositionType() == POSITION_TYPE_SELL)
            {
               totalSellTrades++;
               if(posInfo.PriceOpen() > highestSell) highestSell = posInfo.PriceOpen();
               if(posInfo.Volume() > maxSellLot) maxSellLot = posInfo.Volume();
            }
         }
      }
   }
   
   if(totalBuyTrades > 0) { lastBuyPrice = lowestBuy; currentBuyLot = maxBuyLot; }
   if(totalSellTrades > 0) { lastSellPrice = highestSell; currentSellLot = maxSellLot; }
}

void CheckTakeProfit()
{
   double totalBuyProfit = 0;
   double totalSellProfit = 0;
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(posInfo.SelectByIndex(i) && posInfo.Magic() == InpMagicNumber && posInfo.Symbol() == _Symbol)
      {
         double profit = posInfo.Profit() + posInfo.Swap() + posInfo.Commission();
         if(posInfo.PositionType() == POSITION_TYPE_BUY) totalBuyProfit += profit;
         else if(posInfo.PositionType() == POSITION_TYPE_SELL) totalSellProfit += profit;
      }
   }
   
   // Chot loi he thong BUY
   if(totalBuyTrades > 0 && totalBuyProfit >= InpTakeProfit) CloseAll(POSITION_TYPE_BUY);
   // Chot loi he thong SELL
   if(totalSellTrades > 0 && totalSellProfit >= InpTakeProfit) CloseAll(POSITION_TYPE_SELL);
}

void CloseAll(ENUM_POSITION_TYPE type)
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(posInfo.SelectByIndex(i) && posInfo.Magic() == InpMagicNumber && posInfo.Symbol() == _Symbol)
      {
         if(posInfo.PositionType() == type) trade.PositionClose(posInfo.Ticket());
      }
   }
}

void DisplayInfo()
{
   string s = "=== GOLD MARTINGALE ===\n";
   s += "Buy Trades: " + IntegerToString(totalBuyTrades) + "\n";
   s += "Sell Trades: " + IntegerToString(totalSellTrades) + "\n";
   Comment(s);
}
//+------------------------------------------------------------------+
