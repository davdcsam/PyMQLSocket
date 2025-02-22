//+------------------------------------------------------------------+
int lrlenght;

//+------------------------------------------------------------------+
bool SockSend(int sock, string request)
  {
   char req[];
   int len = StringToCharArray(request, req)-1;
   if(len<0)
      return false;
   return SocketSend(sock, req, len) == len;
  }

//+------------------------------------------------------------------+
string SocketReceive(int sock, int timeOut)
  {
   char rsp[];
   string result = "";
   uint len;
   uint timeOutCheck = GetTickCount()+timeOut;
   do
     {
      len=SocketIsReadable(sock);
      if(len)
        {
         int rsp_len;
         rsp_len = SocketRead(sock, rsp, len, timeOut);
         if(rsp_len>0)
           {
            result+=CharArrayToString(rsp, 0, rsp_len);
           }
        }
     }
   while((GetTickCount()<timeOutCheck) && !IsStopped());
   return result;
  }

//+------------------------------------------------------------------+
void DrawLinearRegression(string points)
  {
   string res[];
   StringSplit(points, ' ', res);

   if(ArraySize(res) == 2)
     {
      Print(ArraySize(res));
      datetime temp[];
      double value0 = NormalizeDouble(StringToDouble(res[0]), _Digits), value1 = NormalizeDouble(StringToDouble(res[1]), _Digits);
      Print(value0);
      Print(value1);
      
      CopyTime(Symbol(), Period(), TimeCurrent(), 30, temp);
      ObjectCreate(0, "regrline", OBJ_TREND, 0, TimeCurrent(),
                   NormalizeDouble(StringToDouble(res[0]), _Digits), temp[0],
                   NormalizeDouble(StringToDouble(res[1]), _Digits));
     }
   else
     {
      Print("Error: los datos recibidos no tienen el formato esperado.");
     }
  }

//+------------------------------------------------------------------+
void OnTick()
  {
   int socket=SocketCreate();
   if(socket!=INVALID_HANDLE)
     {
      if(SocketConnect(socket,"http://127.0.0.1:9091",9091,1000))
        {
         double clpr[];
         int copyed = CopyClose(_Symbol,PERIOD_CURRENT,0,30,clpr);

         Print("Total prices close ", copyed);

         string tosend;
         for(int i=0;i<ArraySize(clpr);i++)
            tosend+=(string)clpr[i]+" ";
         string received = SockSend(socket, tosend) ? SocketReceive(socket, 2000) : "";
         DrawLinearRegression(received);
        }

      else
         Print("Connection ","http://127.0.0.1",":",9091," error ",GetLastError());
      SocketClose(socket);
     }
   else
      Print("Socket creation error ",GetLastError());
  }
//+------------------------------------------------------------------+
