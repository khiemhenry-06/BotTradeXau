//+------------------------------------------------------------------+
//|                                              BTCScalper_EA.mq5   |
//|                          Pro Bitcoin Scalper - Multi Strategy     |
//+------------------------------------------------------------------+
#property copyright "BTC Scalper Pro"
#property version   "1.00"
#property description "Bot scalp Bitcoin BTCUSD - Da chien luoc"
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\SymbolInfo.mqh>

//--- Inputs
input group "=== GIAO DICH ==="
input double InpLotSize       = 0.01;
input double InpTakeProfit    = 5.0;    // TP (USD)
input double InpStopLoss      = 8.0;    // SL (USD)
input int    InpMaxPositions  = 1;
input int    InpMagicNumber   = 77777;
input int    InpDelaySeconds  = 10;

input group "=== CHI BAO ==="
input int    InpRSIPeriod     = 7;
input int    InpRSIOver       = 75;
input int    InpRSIUnder      = 25;
input int    InpBBPeriod      = 14;
input double InpBBDev         = 2.0;
input int    InpEMAFast       = 8;
input int    InpEMASlow       = 21;
input int    InpEMATrend      = 50;
input int    InpADXPeriod     = 14;
input int    InpADXMin        = 20;
input int    InpATRPeriod     = 14;
input double InpATRSLMult     = 1.5;
input int    InpMACDFast      = 12;
input int    InpMACDSlow      = 26;
input int    InpMACDSignal    = 9;
input int    InpStochK        = 5;
input int    InpStochD        = 3;
input int    InpStochSlow     = 3;

input group "=== BO LOC ==="
input int    InpMaxSpread     = 100;
input bool   InpUseTimeFilter = false;
input int    InpStartHour     = 8;
input int    InpEndHour       = 22;
input bool   InpUseMTF        = true;    // Multi-Timeframe filter
input ENUM_TIMEFRAMES InpHTF  = PERIOD_M15; // Higher timeframe

input group "=== TRAILING ==="
input bool   InpUseTrailing   = true;
input double InpTrailStart    = 3.0;
input double InpTrailStep     = 1.0;
input bool   InpUseBreakeven  = true;
input double InpBEStart       = 2.0;    // BE khi lai (USD)
input double InpBEOffset      = 0.5;    // BE offset (USD)

input group "=== QUAN LY VON ==="
input double InpMaxDailyLoss  = 50.0;   // Lo toi da/ngay (USD)
input int    InpMaxDailyTrades= 30;

//--- Globals
CTrade trade;
CPositionInfo posInfo;
CSymbolInfo symInfo;
int hRSI, hBB, hEMAf, hEMAs, hEMAt, hADX, hATR, hMACD, hStoch;
int hRSI_HTF, hEMA_HTF;
datetime lastTradeTime;
int dailyTrades; double dailyPL;
datetime currentDay;
int totalWins, totalLosses; double totalProfit;

int OnInit()
{
   if(!symInfo.Name(_Symbol)) return INIT_FAILED;
   
   hRSI   = iRSI(_Symbol,PERIOD_M1,InpRSIPeriod,PRICE_CLOSE);
   hBB    = iBands(_Symbol,PERIOD_M1,InpBBPeriod,0,InpBBDev,PRICE_CLOSE);
   hEMAf  = iMA(_Symbol,PERIOD_M1,InpEMAFast,0,MODE_EMA,PRICE_CLOSE);
   hEMAs  = iMA(_Symbol,PERIOD_M1,InpEMASlow,0,MODE_EMA,PRICE_CLOSE);
   hEMAt  = iMA(_Symbol,PERIOD_M5,InpEMATrend,0,MODE_EMA,PRICE_CLOSE);
   hADX   = iADX(_Symbol,PERIOD_M1,InpADXPeriod);
   hATR   = iATR(_Symbol,PERIOD_M1,InpATRPeriod);
   hMACD  = iMACD(_Symbol,PERIOD_M1,InpMACDFast,InpMACDSlow,InpMACDSignal,PRICE_CLOSE);
   hStoch = iStochastic(_Symbol,PERIOD_M1,InpStochK,InpStochD,InpStochSlow,MODE_SMA,STO_LOWHIGH);
   
   if(InpUseMTF)
   {
      hRSI_HTF = iRSI(_Symbol,InpHTF,14,PRICE_CLOSE);
      hEMA_HTF = iMA(_Symbol,InpHTF,InpEMATrend,0,MODE_EMA,PRICE_CLOSE);
   }
   
   if(hRSI==INVALID_HANDLE||hBB==INVALID_HANDLE||hEMAf==INVALID_HANDLE||
      hEMAs==INVALID_HANDLE||hEMAt==INVALID_HANDLE||hADX==INVALID_HANDLE||
      hATR==INVALID_HANDLE||hMACD==INVALID_HANDLE||hStoch==INVALID_HANDLE)
      return INIT_FAILED;
   
   trade.SetExpertMagicNumber(InpMagicNumber);
   trade.SetDeviationInPoints(20);
   trade.SetTypeFilling(ORDER_FILLING_IOC);
   
   lastTradeTime=0; dailyTrades=0; dailyPL=0;
   currentDay=0; totalWins=0; totalLosses=0; totalProfit=0;
   
   Print("=== BTC SCALPER PRO - STARTED ===");
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   IndicatorRelease(hRSI); IndicatorRelease(hBB);
   IndicatorRelease(hEMAf); IndicatorRelease(hEMAs);
   IndicatorRelease(hEMAt); IndicatorRelease(hADX);
   IndicatorRelease(hATR); IndicatorRelease(hMACD);
   IndicatorRelease(hStoch);
   if(InpUseMTF){IndicatorRelease(hRSI_HTF);IndicatorRelease(hEMA_HTF);}
   Print("W:",totalWins," L:",totalLosses," PL:$",DoubleToString(totalProfit,2));
   Comment("");
}

void OnTick()
{
   symInfo.RefreshRates();
   ResetDailyStats();
   DisplayInfo();
   if(InpUseBreakeven) ManageBreakeven();
   if(InpUseTrailing) ManageTrailing();
   if(!CheckConditions()) return;
   
   double rsi[3],upBB[3],loBB[3],mdBB[3],emaF[3],emaS[3],emaT[3];
   double adx[3],pDI[3],nDI[3],atr[3],macd[3],macdS[3],stK[3],stD[3];
   
   if(!GetData(rsi,upBB,loBB,mdBB,emaF,emaS,emaT,adx,pDI,nDI,atr,macd,macdS,stK,stD))
      return;
   
   double ask=symInfo.Ask(), bid=symInfo.Bid(), pt=symInfo.Point();
   double tv=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   double ts=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   
   // ATR-based dynamic SL/TP
   double slPts, tpPts;
   if(tv>0&&ts>0){
      tpPts=(InpTakeProfit/(tv/ts))/InpLotSize;
      slPts=MathMax((InpStopLoss/(tv/ts))/InpLotSize, atr[0]*InpATRSLMult/pt);
   } else {
      tpPts=InpTakeProfit*10; slPts=InpStopLoss*10;
   }
   
   int score=0;
   // === SCORING SYSTEM - BUY ===
   // 1. EMA crossover bullish
   bool emaCross = (emaF[0]>emaS[0] && emaF[1]<=emaS[1]);
   bool emaAbove = (emaF[0]>emaS[0]);
   // 2. RSI oversold + rising
   bool rsiOS = (rsi[0]<InpRSIUnder && rsi[0]>rsi[1]);
   bool rsiMid = (rsi[0]>40 && rsi[0]<60 && rsi[0]>rsi[1]);
   // 3. BB: price near/below lower
   bool bbLow = (bid<=loBB[0]+atr[0]*0.3);
   // 4. ADX trend strength
   bool adxOK = (adx[0]>InpADXMin && pDI[0]>nDI[0]);
   // 5. MACD bullish
   bool macdBull = (macd[0]>macdS[0] && macd[1]<=macdS[1]);
   bool macdPos  = (macd[0]>macdS[0]);
   // 6. Stochastic oversold cross
   bool stochBuy = (stK[0]<30 && stK[0]>stD[0] && stK[1]<=stD[1]);
   bool stochLow = (stK[0]<40 && stK[0]>stD[0]);
   // 7. Price above trend EMA
   bool aboveTrend = (bid>emaT[0]);
   // 8. BB squeeze breakout
   double bw0=(upBB[0]-loBB[0])/mdBB[0], bw1=(upBB[1]-loBB[1])/mdBB[1];
   bool bbSqueeze = (bw0>bw1*1.2 && bid>upBB[1]);
   
   // Score calculation
   if(emaCross) score+=3; else if(emaAbove) score+=1;
   if(rsiOS) score+=3; else if(rsiMid) score+=1;
   if(bbLow) score+=2;
   if(adxOK) score+=2;
   if(macdBull) score+=3; else if(macdPos) score+=1;
   if(stochBuy) score+=2; else if(stochLow) score+=1;
   if(aboveTrend) score+=1;
   if(bbSqueeze) score+=2;
   
   // MTF filter
   if(InpUseMTF && score>=6) {
      double htfRSI[1], htfEMA[1];
      ArraySetAsSeries(htfRSI,true); ArraySetAsSeries(htfEMA,true);
      CopyBuffer(hRSI_HTF,0,0,1,htfRSI);
      CopyBuffer(hEMA_HTF,0,0,1,htfEMA);
      if(htfRSI[0]>70 || bid<htfEMA[0]) score-=3; // Against HTF
   }
   
   // BUY if score >= 6
   if(score>=6) {
      double sl=NormalizeDouble(ask-slPts*pt,(int)symInfo.Digits());
      double tp=NormalizeDouble(ask+tpPts*pt,(int)symInfo.Digits());
      if(trade.Buy(InpLotSize,_Symbol,ask,sl,tp,"BTC_BUY s:"+IntegerToString(score)))
      { lastTradeTime=TimeCurrent(); dailyTrades++; 
        Print(">> BUY Score:",score," P:",ask); }
   }
   
   // === SCORING SYSTEM - SELL ===
   score=0;
   bool emaCrossS = (emaF[0]<emaS[0] && emaF[1]>=emaS[1]);
   bool emaBelow  = (emaF[0]<emaS[0]);
   bool rsiOB = (rsi[0]>InpRSIOver && rsi[0]<rsi[1]);
   bool rsiMidS = (rsi[0]>40 && rsi[0]<60 && rsi[0]<rsi[1]);
   bool bbHigh = (bid>=upBB[0]-atr[0]*0.3);
   bool adxOKS = (adx[0]>InpADXMin && nDI[0]>pDI[0]);
   bool macdBear = (macd[0]<macdS[0] && macd[1]>=macdS[1]);
   bool macdNeg  = (macd[0]<macdS[0]);
   bool stochSell = (stK[0]>70 && stK[0]<stD[0] && stK[1]>=stD[1]);
   bool stochHigh = (stK[0]>60 && stK[0]<stD[0]);
   bool belowTrend = (bid<emaT[0]);
   bool bbSqzS = (bw0>bw1*1.2 && bid<loBB[1]);
   
   if(emaCrossS) score+=3; else if(emaBelow) score+=1;
   if(rsiOB) score+=3; else if(rsiMidS) score+=1;
   if(bbHigh) score+=2;
   if(adxOKS) score+=2;
   if(macdBear) score+=3; else if(macdNeg) score+=1;
   if(stochSell) score+=2; else if(stochHigh) score+=1;
   if(belowTrend) score+=1;
   if(bbSqzS) score+=2;
   
   if(InpUseMTF && score>=6) {
      double htfRSI2[1], htfEMA2[1];
      ArraySetAsSeries(htfRSI2,true); ArraySetAsSeries(htfEMA2,true);
      CopyBuffer(hRSI_HTF,0,0,1,htfRSI2);
      CopyBuffer(hEMA_HTF,0,0,1,htfEMA2);
      if(htfRSI2[0]<30 || bid>htfEMA2[0]) score-=3;
   }
   
   if(score>=6) {
      double sl=NormalizeDouble(bid+slPts*pt,(int)symInfo.Digits());
      double tp=NormalizeDouble(bid-tpPts*pt,(int)symInfo.Digits());
      if(trade.Sell(InpLotSize,_Symbol,bid,sl,tp,"BTC_SELL s:"+IntegerToString(score)))
      { lastTradeTime=TimeCurrent(); dailyTrades++;
        Print(">> SELL Score:",score," P:",bid); }
   }
}

bool GetData(double &rsi[],double &uBB[],double &lBB[],double &mBB[],
             double &eF[],double &eS[],double &eT[],double &adx[],
             double &pDI[],double &nDI[],double &atr[],double &macd[],
             double &macdS[],double &stK[],double &stD[])
{
   ArraySetAsSeries(rsi,true);ArraySetAsSeries(uBB,true);ArraySetAsSeries(lBB,true);
   ArraySetAsSeries(mBB,true);ArraySetAsSeries(eF,true);ArraySetAsSeries(eS,true);
   ArraySetAsSeries(eT,true);ArraySetAsSeries(adx,true);ArraySetAsSeries(pDI,true);
   ArraySetAsSeries(nDI,true);ArraySetAsSeries(atr,true);ArraySetAsSeries(macd,true);
   ArraySetAsSeries(macdS,true);ArraySetAsSeries(stK,true);ArraySetAsSeries(stD,true);
   
   if(CopyBuffer(hRSI,0,0,3,rsi)<3) return false;
   if(CopyBuffer(hBB,0,0,3,mBB)<3) return false;
   if(CopyBuffer(hBB,1,0,3,uBB)<3) return false;
   if(CopyBuffer(hBB,2,0,3,lBB)<3) return false;
   if(CopyBuffer(hEMAf,0,0,3,eF)<3) return false;
   if(CopyBuffer(hEMAs,0,0,3,eS)<3) return false;
   if(CopyBuffer(hEMAt,0,0,3,eT)<3) return false;
   if(CopyBuffer(hADX,0,0,3,adx)<3) return false;
   if(CopyBuffer(hADX,1,0,3,pDI)<3) return false;
   if(CopyBuffer(hADX,2,0,3,nDI)<3) return false;
   if(CopyBuffer(hATR,0,0,3,atr)<3) return false;
   if(CopyBuffer(hMACD,0,0,3,macd)<3) return false;
   if(CopyBuffer(hMACD,1,0,3,macdS)<3) return false;
   if(CopyBuffer(hStoch,0,0,3,stK)<3) return false;
   if(CopyBuffer(hStoch,1,0,3,stD)<3) return false;
   return true;
}

bool CheckConditions()
{
   if((int)SymbolInfoInteger(_Symbol,SYMBOL_SPREAD)>InpMaxSpread) return false;
   if(CountPos()>=InpMaxPositions) return false;
   if(TimeCurrent()-lastTradeTime<InpDelaySeconds) return false;
   if(dailyPL<=-InpMaxDailyLoss){Print("Max daily loss!");return false;}
   if(dailyTrades>=InpMaxDailyTrades) return false;
   if(InpUseTimeFilter){
      MqlDateTime dt; TimeToStruct(TimeCurrent(),dt);
      if(dt.hour<InpStartHour||dt.hour>=InpEndHour) return false;
   }
   return true;
}

int CountPos()
{
   int c=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(posInfo.SelectByIndex(i))
         if(posInfo.Magic()==InpMagicNumber&&posInfo.Symbol()==_Symbol) c++;
   return c;
}

void ManageBreakeven()
{
   double pt=symInfo.Point();
   double tv=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   double ts=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      if(!posInfo.SelectByIndex(i)) continue;
      if(posInfo.Magic()!=InpMagicNumber||posInfo.Symbol()!=_Symbol) continue;
      
      double op=posInfo.PriceOpen(), sl=posInfo.StopLoss();
      double pf=posInfo.Profit();
      double beThreshold=InpBEStart*InpLotSize;
      double beOff=0;
      if(tv>0&&ts>0) beOff=(InpBEOffset/(tv/ts))/InpLotSize*pt;
      else beOff=InpBEOffset*10*pt;
      
      if(pf>=beThreshold)
      {
         if(posInfo.PositionType()==POSITION_TYPE_BUY && sl<op)
         {
            double nsl=NormalizeDouble(op+beOff,(int)symInfo.Digits());
            trade.PositionModify(posInfo.Ticket(),nsl,posInfo.TakeProfit());
         }
         else if(posInfo.PositionType()==POSITION_TYPE_SELL && (sl>op||sl==0))
         {
            double nsl=NormalizeDouble(op-beOff,(int)symInfo.Digits());
            trade.PositionModify(posInfo.Ticket(),nsl,posInfo.TakeProfit());
         }
      }
   }
}

void ManageTrailing()
{
   double pt=symInfo.Point();
   double tv=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   double ts=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      if(!posInfo.SelectByIndex(i)) continue;
      if(posInfo.Magic()!=InpMagicNumber||posInfo.Symbol()!=_Symbol) continue;
      
      double op=posInfo.PriceOpen(), sl=posInfo.StopLoss(), pf=posInfo.Profit();
      double tStart=InpTrailStart*InpLotSize;
      if(pf<tStart) continue;
      
      double stepPx=0;
      if(tv>0&&ts>0) stepPx=(InpTrailStep/(tv/ts))/InpLotSize*pt;
      else stepPx=InpTrailStep*10*pt;
      
      if(posInfo.PositionType()==POSITION_TYPE_BUY)
      {
         double nsl=NormalizeDouble(symInfo.Bid()-stepPx,(int)symInfo.Digits());
         if(nsl>sl&&nsl>op) trade.PositionModify(posInfo.Ticket(),nsl,posInfo.TakeProfit());
      }
      else
      {
         double nsl=NormalizeDouble(symInfo.Ask()+stepPx,(int)symInfo.Digits());
         if((nsl<sl||sl==0)&&nsl<op) trade.PositionModify(posInfo.Ticket(),nsl,posInfo.TakeProfit());
      }
   }
}

void ResetDailyStats()
{
   MqlDateTime dt; TimeToStruct(TimeCurrent(),dt);
   datetime today=StringToTime(IntegerToString(dt.year)+"."+IntegerToString(dt.mon)+"."+IntegerToString(dt.day));
   if(today!=currentDay){currentDay=today;dailyTrades=0;dailyPL=0;}
}

void DisplayInfo()
{
   int op=0; double opf=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(posInfo.SelectByIndex(i))
         if(posInfo.Magic()==InpMagicNumber&&posInfo.Symbol()==_Symbol)
         {op++;opf+=posInfo.Profit()+posInfo.Swap()+posInfo.Commission();}
   
   double rv[1]; ArraySetAsSeries(rv,true); CopyBuffer(hRSI,0,0,1,rv);
   double av[1]; ArraySetAsSeries(av,true); CopyBuffer(hADX,0,0,1,av);
   int sp=(int)SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);
   
   string s="";
   s+="[ BTC SCALPER PRO v1.0 ]\n";
   s+="Spread:"+IntegerToString(sp)+(sp<=InpMaxSpread?" OK":" HIGH")+"\n";
   s+="RSI:"+DoubleToString(rv[0],1)+" ADX:"+DoubleToString(av[0],1)+"\n";
   s+="Pos:"+IntegerToString(op)+"/"+IntegerToString(InpMaxPositions)+"\n";
   s+="Open PL:$"+DoubleToString(opf,2)+"\n";
   s+="Today:"+IntegerToString(dailyTrades)+"trades $"+DoubleToString(dailyPL,2)+"\n";
   s+="Total W:"+IntegerToString(totalWins)+" L:"+IntegerToString(totalLosses)+"\n";
   s+="Total PL:$"+DoubleToString(totalProfit,2)+"\n";
   Comment(s);
}

void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &req,const MqlTradeResult &res)
{
   if(trans.type==TRADE_TRANSACTION_DEAL_ADD)
   {
      if(HistoryDealSelect(trans.deal))
      {
         if(HistoryDealGetInteger(trans.deal,DEAL_MAGIC)==InpMagicNumber &&
            HistoryDealGetInteger(trans.deal,DEAL_ENTRY)==DEAL_ENTRY_OUT)
         {
            double np=HistoryDealGetDouble(trans.deal,DEAL_PROFIT)+
                      HistoryDealGetDouble(trans.deal,DEAL_COMMISSION)+
                      HistoryDealGetDouble(trans.deal,DEAL_SWAP);
            totalProfit+=np; dailyPL+=np;
            if(np>=0){totalWins++;Print("WIN $",DoubleToString(np,2));}
            else{totalLosses++;Print("LOSS $",DoubleToString(np,2));}
         }
      }
   }
}
//+------------------------------------------------------------------+
