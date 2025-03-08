Modelsim RTL Simulation :   
vlog tb.sv JAM.v +define+P1 (Select Patterns you wanted)  
vsim -gui work.testfixture  
add wave -r *  
run -all  

State: 
IDLE:做初始化
DELAY_CLK:題目需要延遲兩個Clock Cycle在開始
CAL:
