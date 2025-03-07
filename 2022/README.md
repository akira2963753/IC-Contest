Modelsim RTL Simulation :   
vlog tb.sv JAM.v +define+P1 (Select Patterns you wanted)  
vsim -gui work.testfixture  
add wave -r *  
run -all  
