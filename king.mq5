//+------------------------------------------------------------------+
//|                                                         king.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
input int maxTrades=5;
input int RSI_Period=14;
#define EXPERT_MAGIC 123123
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
MqlRates candle[];

// Acessando os ticks

MqlTick tick;

// Acessando dados do booking
MqlBookInfo book[];

//Acessando Indicadores  Padrão MetaTrader5 ( Medias móveis )

int Rsi_Mandle;
double Rsi_Buffer[];

int Fibo_Handle;
double     baseline1Buffer[];
double     baseline2Buffer[];
double     level236Buffer[];
double     level382Buffer[];
double     level500Buffer[];
double     level618Buffer[];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  


   EventSetMillisecondTimer(1000);
   //EventSetTimer(5);
   MarketBookAdd(_Symbol);
   // Invert Arrays last info is [0]
   ArraySetAsSeries(candle,true);
   ArraySetAsSeries(Rsi_Buffer,true);
    ArraySetAsSeries(baseline1Buffer,true);
    ArraySetAsSeries(baseline2Buffer,true);
    ArraySetAsSeries(level236Buffer,true);
    ArraySetAsSeries(level382Buffer,true);
    ArraySetAsSeries(level500Buffer,true);
    ArraySetAsSeries(level618Buffer,true);
   //Print("O máximo de trades serão", maxTrades," e periodos  ",ma_Period);
   Rsi_Mandle=  iRSI(_Symbol,_Period,RSI_Period,PRICE_CLOSE);
   Fibo_Handle= iCustom(_Symbol,_Period,"fibo_retrace.ex5");
   
   
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   EventKillTimer();
   MarketBookRelease(_Symbol);
   Print("Finish Init");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
  }
//+------------------------------------------------------------------+
void OnTimer(){
   bool newBar = isNewBar();  // Se for um novo candle return true
   //Dados do indicador
   CopyBuffer(Rsi_Mandle,0,0,5,Rsi_Buffer);
    CopyBuffer(Fibo_Handle,0,0,5,baseline1Buffer);
    
    CopyBuffer(Fibo_Handle,1,0,5,baseline2Buffer);
    
    CopyBuffer(Fibo_Handle,2,0,5,level236Buffer);
    
    CopyBuffer(Fibo_Handle,3,0,5,level382Buffer);
    
    CopyBuffer(Fibo_Handle,4,0,5,level500Buffer);
    
    CopyBuffer(Fibo_Handle,5,0,5,level618Buffer);
    
    Print("BaseLine 1=",baseline1Buffer[0]);
    
    Print("BaseLine 2=",baseline2Buffer[0]);
    
    Print("Linha 23=",level236Buffer[0]);
    
    Print("Linha 38=",level382Buffer[0]);
    
    Print("Linha 50=",level500Buffer[0]);
    
    Print("Linha 61=",level618Buffer[0]);
   //Print("parada =",Rsi_Buffer[0]);
   //Dados do par corrente
   CopyRates(_Symbol,_Period,0,5,candle);
   
  // Print("open:",candle[1].open);
   
   SymbolInfoTick(_Symbol,tick);
   
  //  Print("volume",tick.volume);s
  //  Print("volume",tick.bid)
  ;
   MarketBookGet(_Symbol,book);
   // --- Setup de Compra
    if(newBar  && Rsi_Buffer[0]<=30){
      buy();
      }
   // --- Setup de Venda    
    if(newBar  && Rsi_Buffer[0]>70){
      sell();
   
   }
}

bool buy(){


       Print("############### Compra ###################");
         MqlTradeRequest request;  // Requisição
         MqlTradeResult  result; // Resposta
         ZeroMemory(request);
         ZeroMemory(result);
         // Definir Caracteristicas
         request.action = TRADE_ACTION_DEAL;
         request.symbol=_Symbol; 
         request.volume=0.01;
         request.price=0;
         request.sl=tick.ask-0.003;
         request.tp=tick.ask+0.001;
    //     request.deviation=0;
         request.type= ORDER_TYPE_BUY;
         request.type_filling=ORDER_FILLING_IOC;
         //request.type_filling=SYMBOL_FILLING_IOC;
         request.type_time =ORDER_TIME_DAY;
  //       request.expiration=0;
         request.comment=" Compra de Mercado";
         request.magic    =EXPERT_MAGIC;                          // MagicNumber of the order
         ResetLastError();
         // ---
         bool ok = OrderSend(request,result);
               if(ok==false){
                  Print("Ordem não processada, erro",GetLastError());
               }
         
         return ok;
         }
bool sell(){
         Print("############### Venda ###############");
         MqlTradeRequest request;  // Requisição
         MqlTradeResult  result; // Resposta
         // Definir Caracteristicas
         request.action = TRADE_ACTION_DEAL;
    
         request.symbol=_Symbol; 
         request.volume=0.01;
         request.price=0;
         request.sl=tick.ask+0.003;;
         request.tp=tick.ask-0.001;
         //request.deviation=0;
         request.type= ORDER_TYPE_SELL;
         request.type_filling=ORDER_FILLING_IOC;
         //request.type_filling=SYMBOL_FILLING_IOC;
         request.type_time =ORDER_TIME_DAY;
        //requst.expiration=0;
         request.comment="Venda de Mercado";
          request.magic    =EXPERT_MAGIC;                          // MagicNumber of the order
         ResetLastError();
         // ---
         bool ok =OrderSend(request,result);
         if(ok==false){
            Print("Ordem não processada, erro",GetLastError());
         }
         return ok;
}
bool isNewBar()
  {
//--- memorize the time of opening of the last bar in the static variable
   static datetime last_time=0;
//--- current time
   datetime lastbar_time= (datetime) SeriesInfoInteger(Symbol(),Period(),SERIES_LASTBAR_DATE);

//--- if it is the first call of the function
   if(last_time==0)
     {
      //--- set the time and exit
      last_time=lastbar_time;
      return(false);
     }

//--- if the time differs
   if(last_time!=lastbar_time)
     {
      //--- memorize the time and return true
      last_time=lastbar_time;
      return(true);
     }
//--- if we passed to this line, then the bar is not new; return false
   return(false);
  }
 