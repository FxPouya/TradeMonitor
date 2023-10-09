input string ServerURL = "http://yourserver.com/mt4data";

datetime prevTime;  

int OnInit() {
  prevTime = TimeCurrent();
  return(INIT_SUCCEEDED);
}

void OnTick() {

  if(TimeCurrent() >= prevTime + 30) {

    string openTrades;
    string closedTrades;
    
    int total = OrdersTotal();

    for(int i=0; i < total; i++) {
    
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      
        if(OrderOpenTime() >= iTime(Symbol(),PERIOD_D1,0)) {
        
          openTrades += "symbol=" + Symbol() +
                       "&openprice=" + DoubleToString(OrderOpenPrice()) +
                       "&takeprofit=" + DoubleToString(OrderTakeProfit()) +
                       "&stoploss=" + DoubleToString(OrderStopLoss()) +
                       "&lots=" + DoubleToString(OrderLots()) +
                       "&profit=" + DoubleToString(OrderProfit()) +
                       "&opentime=" + IntegerToString(OrderOpenTime()) + "|";
        
        }
        
      }
    
    }
    
    total = OrdersHistoryTotal();
    
    for(i=0; i < total; i++) {
    
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
      
        if(OrderCloseTime() >= iTime(Symbol(),PERIOD_D1,0)) {
        
          closedTrades += "symbol=" + Symbol() +
                          "&openprice=" + DoubleToString(OrderOpenPrice()) +
                          "&closeprice=" + DoubleToString(OrderClosePrice()) + 
                          "&takeprofit=" + DoubleToString(OrderTakeProfit()) +
                          "&stoploss=" + DoubleToString(OrderStopLoss()) +
                          "&lots=" + DoubleToString(OrderLots()) +
                          "&profit=" + DoubleToString(OrderProfit()) +
                          "&opentime=" + IntegerToString(OrderOpenTime()) +
                          "&closetime=" + IntegerToString(OrderCloseTime()) + "|";
        
        }
        
      }
      
    }
    
    if(StringLen(openTrades) > 0) {
      openTrades = StringSubstr(openTrades, 0, StringLen(openTrades)-1);
      Print(openTrades);  
      if(FileWriteString("op.txt", openTrades)) 
        Print("Data written successfully");
      else
        Print("Error writing data to file");
      //int res1 = Post(ServerURL+"?type=open", openTrades);
    }
    
    if(StringLen(closedTrades) > 0) {
      closedTrades = StringSubstr(closedTrades, 0, StringLen(closedTrades)-1);
      Print(closedTrades);
      if(FileWriteString("cl.txt", closedTrades)) 
        Print("Data written successfully");
      else
        Print("Error writing data to file");
      //int res2 = Post(ServerURL+"?type=closed", closedTrades);   
    }

    prevTime = TimeCurrent();

  }

}

///------------------------------------
bool FileWriteString(string filename, string data)
  {
   int file_handle=FileOpen(filename,FILE_WRITE|FILE_TXT);
   if(file_handle!=INVALID_HANDLE)
     {
      if(FileWrite(file_handle,data)>0) 
        {
         FileClose(file_handle);
         return(true);
        }
      FileClose(file_handle);
     }
   return(false);
  }
