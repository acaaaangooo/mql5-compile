//+------------------------------------------------------------------+
//|                                         RSI_BuySell_Levels.mq5  |
//|                        RSI with Buy/Sell Zone Labels (MT5)       |
//+------------------------------------------------------------------+
#property copyright   "Custom Indicator"
#property link        ""
#property version     "1.00"
#property indicator_separate_window
#property indicator_minimum   0
#property indicator_maximum   100
#property indicator_buffers   1
#property indicator_plots     1
#property indicator_label1    "RSI"
#property indicator_type1     DRAW_LINE
#property indicator_color1    clrOrangeRed
#property indicator_style1    STYLE_SOLID
#property indicator_width1    2
#property indicator_level1    80.0
#property indicator_level2    70.0
#property indicator_level3    50.0
#property indicator_level4    30.0
#property indicator_level5    20.0
#property indicator_levelcolor clrFireBrick
#property indicator_levelstyle STYLE_SOLID
#property indicator_levelwidth 1
input int    RSI_Period   = 8;
input ENUM_APPLIED_PRICE RSI_Price = PRICE_CLOSE;
input double Level_Sell   = 80.0;
input double Level_RSell  = 70.0;
input double Level_Wait   = 50.0;
input double Level_RBuy   = 30.0;
input double Level_Buy    = 20.0;
input bool   Show_Labels  = true;
input color  Color_Sell   = clrFireBrick;
input color  Color_Wait   = clrGray;
input color  Color_Buy    = clrForestGreen;
double RSIBuffer[];
int rsi_handle;
int window_num = -1;
int OnInit()
{
   SetIndexBuffer(0, RSIBuffer, INDICATOR_DATA);
   ArraySetAsSeries(RSIBuffer, true);
   rsi_handle = iRSI(_Symbol, _Period, RSI_Period, RSI_Price);
   if(rsi_handle == INVALID_HANDLE) return INIT_FAILED;
   string short_name = "RSI(" + IntegerToString(RSI_Period) + ")";
   IndicatorSetString(INDICATOR_SHORTNAME, short_name);
   IndicatorSetInteger(INDICATOR_DIGITS, 2);
   EventSetTimer(1);
   return INIT_SUCCEEDED;
}
void OnTimer()
{
   if(Show_Labels) DrawLevelLabels();
   EventKillTimer();
}
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],const double &open[],const double &high[],const double &low[],const double &close[],const long &tick_volume[],const long &volume[],const int &spread[])
{
   if(rates_total < RSI_Period + 1) return 0;
   int to_copy = rates_total - prev_calculated + 1;
   if(prev_calculated == 0) to_copy = rates_total;
   if(CopyBuffer(rsi_handle, 0, 0, to_copy, RSIBuffer) <= 0) return prev_calculated;
   return rates_total;
}
void DrawLevelLabels()
{
   window_num = ChartWindowFind(0, "RSI(" + IntegerToString(RSI_Period) + ")");
   if(window_num < 0) return;
   double levels[5] = {Level_Sell, Level_RSell, Level_Wait, Level_RBuy, Level_Buy};
   string labels[5] = {"SELL", "R SELL", "Waiting", "R BUY", "BUY"};
   color  colors[5];
   colors[0]=Color_Sell; colors[1]=Color_Sell; colors[2]=Color_Wait; colors[3]=Color_Buy; colors[4]=Color_Buy;
   for(int i=0; i<5; i++)
   {
      string obj_name = "RSI_Label_" + IntegerToString(i);
      ObjectDelete(0, obj_name);
      datetime label_time = iTime(_Symbol, _Period, (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR) - 2);
      if(!ObjectCreate(0, obj_name, OBJ_TEXT, window_num, label_time, levels[i])) continue;
      ObjectSetString(0, obj_name, OBJPROP_TEXT, labels[i]);
      ObjectSetInteger(0, obj_name, OBJPROP_COLOR, colors[i]);
      ObjectSetInteger(0, obj_name, OBJPROP_FONTSIZE, 8);
      ObjectSetString(0, obj_name, OBJPROP_FONT, "Arial Bold");
      ObjectSetInteger(0, obj_name, OBJPROP_ANCHOR, ANCHOR_RIGHT);
      ObjectSetInteger(0, obj_name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, obj_name, OBJPROP_HIDDEN, true);
   }
   ChartRedraw(0);
}
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{
   if(id == CHARTEVENT_CHART_CHANGE && Show_Labels) DrawLevelLabels();
}
void OnDeinit(const REAS_DEINIT reason)
{
   for(int i=0; i<5; i++) ObjectDelete(0, "RSI_Label_" + IntegerToString(i));
   if(rsi_handle != INVALID_HANDLE) IndicatorRelease(rsi_handle);
   EventKillTimer();
   ChartRedraw(0);
}
