//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 1
#property indicator_plots 1
#property indicator_label1 "RSI"
#property indicator_type1 DRAW_LINE
#property indicator_color1 clrOrangeRed
#property indicator_width1 2
#property indicator_level1 80.0
#property indicator_level2 70.0
#property indicator_level3 50.0
#property indicator_level4 30.0
#property indicator_level5 20.0
#property indicator_levelcolor clrFireBrick
#property indicator_levelstyle STYLE_SOLID
#property indicator_levelwidth 1

input int RSI_Period = 8;
input ENUM_APPLIED_PRICE RSI_Price = PRICE_CLOSE;

double RSIBuffer[];
int rsi_handle;

int OnInit()
{
   SetIndexBuffer(0,RSIBuffer,INDICATOR_DATA);
   rsi_handle=iRSI(_Symbol,_Period,RSI_Period,RSI_Price);
   if(rsi_handle==INVALID_HANDLE) return(INIT_FAILED);
   IndicatorSetString(INDICATOR_SHORTNAME,"RSI("+string(RSI_Period)+")");
   return(INIT_SUCCEEDED);
}

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],const double &high[],const double &low[],
                const double &close[],const long &tick_volume[],const long &volume[],
                const int &spread[])
{
   if(rates_total<RSI_Period+1) return(0);
   int to_copy=rates_total-prev_calculated+1;
   if(prev_calculated==0) to_copy=rates_total;
   if(CopyBuffer(rsi_handle,0,0,to_copy,RSIBuffer)<=0) return(prev_calculated);
   return(rates_total);
}

void OnDeinit(const int reason)
{
   if(rsi_handle!=INVALID_HANDLE) IndicatorRelease(rsi_handle);
}
