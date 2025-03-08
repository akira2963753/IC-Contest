Modelsim RTL Simulation : 
-
vlog tb.sv JAM.v +define+P1 (Select Patterns you wanted)  
vsim -gui work.testfixture  
add wave -r *  
run -all  

State:
-
//IDLE:  
做初始化  
//DELAY_CLK:  
題目需要延遲兩個Clock Cycle在開始  
CAL:  
Counter數0~7做Cost的加法，而數到8做判斷是否為最小成本和Match最小成本的數量。  
FIND_PNT:  
找Point(從n[7]開始尋找，找右邊比左邊大的，左邊即設為Point)  
當Point找到時，find_fn跳起，找不到時代表已經完成全排列，finish跳起  
FIND_CPNT:  
找替換點  
SORT:  
做替換點交換和排列  
RESULT:  
完成  
         
