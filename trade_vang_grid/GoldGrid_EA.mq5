//+------------------------------------------------------------------+
//|                                                GoldGrid_EA.mq5   |
//|                                      Gold Grid Trading Strategy  |
//+------------------------------------------------------------------+
#property copyright "Gold Grid Bot"
#property version   "1.00"
#property description "Bot luoi (Grid) cho Vang XAUUSD"

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\SymbolInfo.mqh>

input group "=== CAU HINH GRID ==="
input double   InpLotSize        = 0.01;    // Lot Size co ban
input int      InpGridStep       = 200;     // Khoang cach luoi (Points)
input int      InpTakeProfit     = 300;     // Take Profit (Points)
input int      InpMaxLevels      = 10;      // So tang luoi toi da

input group "=== CAU HINH CHUNG ==="
input int      InpMagicNumber    = 22222;
input int      InpMaxSpread      = 40;

CTrade         trade;
CPositionInfo  posInfo;
CSymbolInfo    symInfo;

double         lastBuyPrice  = 0;
double         lastSellPrice = 0;
int            buyLevels     = 0;
int            sellLevels    = 0;

int OnInit()
{
   if(!symInfo.Name(_Symbol)) return INIT_FAILED;
   trade.SetExpertMagicNumber(InpMagicNumber);
   Print("Gold Grid Bot Started!");
   return INIT_SUCCEEDED;
}

void OnTick()
{
   symInfo.RefreshRates();
   if((int)SymbolInfoInteger(_Symbol,SYMBOL_SPREAD) > InpMaxSpread) return;

   CountLevels();
   
   double ask = symInfo.Ask();
   double bid = symInfo.Bid();
   double point = symInfo.Point();
   
   // Tinh TP
   double tpBuy = ask + InpTakeProfit * point;
   double tpSell = bid - InpTakeProfit * point;
   
   // Neu chua co lenh Buy nao, mo lenh dau tien
   if(buyLevels == 0)
   {
      if(trade.Buy(InpLotSize, _Symbol, ask, 0, tpBuy, "Grid Buy First"))
         lastBuyPrice = ask;
   }
   // Neu da co lenh Buy, kiem tra khoang cach de mo tang tiep theo
   else if(buyLevels < InpMaxLevels)
   {
      if(lastBuyPrice - ask >= InpGridStep * point)
      {
         if(trade.Buy(InpLotSize, _Symbol, ask, 0, tpBuy, "Grid Buy Level "+IntegerToString(buyLevels+1)))
            lastBuyPrice = ask;
      }
   }
   
   // Tuong tu cho Sell
   if(sellLevels == 0)
   {
      if(trade.Sell(InpLotSize, _Symbol, bid, 0, tpSell, "Grid Sell First"))
         lastSellPrice = bid;
   }
   else if(sellLevels < InpMaxLevels)
   {
      if(bid - lastSellPrice >= InpGridStep * point)
      {
         if(trade.Sell(InpLotSize, _Symbol, bid, 0, tpSell, "Grid Sell Level "+IntegerToString(sellLevels+1)))
            lastSellPrice = bid;
      }
   }
   
   DisplayInfo();
}

void CountLevels()
{
   buyLevels = 0;
   sellLevels = 0;
   double lowestBuy = 999999;
   double highestSell = 0;
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(posInfo.SelectByIndex(i))
      {
         if(posInfo.Magic() == InpMagicNumber && posInfo.Symbol() == _Symbol)
         {
            if(posInfo.PositionType() == POSITION_TYPE_BUY)
            {
               buyLevels++;
               if(posInfo.PriceOpen() < lowestBuy) lowestBuy = posInfo.PriceOpen();
            }
            else if(posInfo.PositionType() == POSITION_TYPE_SELL)
            {
               sellLevels++;
               if(posInfo.PriceOpen() > highestSell) highestSell = posInfo.PriceOpen();
            }
         }
      }
   }
   
   if(buyLevels > 0) lastBuyPrice = lowestBuy;
   if(sellLevels > 0) lastSellPrice = highestSell;
}

void DisplayInfo()
{
   string s = "=== GOLD GRID BOT ===\n";
   s += "Buy Levels: " + IntegerToString(buyLevels) + "/" + IntegerToString(InpMaxLevels) + "\n";
   s += "Sell Levels: " + IntegerToString(sellLevels) + "/" + IntegerToString(InpMaxLevels) + "\n";
   Comment(s);
}
//+------------------------------------------------------------------+
