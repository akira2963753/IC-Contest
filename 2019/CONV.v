`timescale 1ns/10ps
module  CONV(
	input clk,
	input reset,
	output busy,	
	input ready,	
	output reg [11:0] iaddr,
	input signed [19:0] idata,
	output cwr, 
	output reg [11:0] caddr_wr, 
	output reg signed [19:0] cdata_wr, 
	output crd, 
	output [11:0] caddr_rd, 
	input [19:0] cdata_rd, 
	output reg [2:0] csel);
	
// Set parameter、state、net and regiser 
parameter IDLE = 3'd0,Read = 3'd1,Delay = 3'd2,Conv = 3'd3,Write = 3'd4,MaxPool = 3'd5,Finish = 3'd6;
parameter signed bias = 20'h01310;
reg [2:0] state,next_state;
reg signed [19:0] image_data[0:65][0:65];
reg signed [39:0] result; 
wire [65:0] x,y;
wire signed [19:0] kernal;
reg [3:0] counter;
reg [6:0] set_zero_cnt;
reg load;

// x = iaddr % 64 、 y = iaddr / 64
assign x = iaddr[5:0]; 
assign y = iaddr >> 6; 

assign busy = (state!=IDLE); // 當狀態不在IDLE時，即在忙碌中...
assign cwr = (state==Write||state==MaxPool||state==Finish); //寫入記憶體 
Kernel_block u0(counter,kernal);

// Set FSM
always @(posedge clk or posedge reset) begin
	if(reset) state <= IDLE;
	else state <= next_state;
end

always @(*) begin
	case(state)
		IDLE: next_state = (ready&&set_zero_cnt==7'd66)? Read : IDLE;
		Read: next_state = (iaddr==12'd4095)? Delay : Read ;
		Delay: next_state = Conv;
		Conv: next_state = (iaddr==12'd4095&&load==1'b1)? Write : Conv;
		Write : next_state = (caddr_wr==12'd4095)? MaxPool : Write;
		MaxPool : next_state = (iaddr==12'd4030)? Finish : MaxPool;
		Finish: next_state = IDLE;
		default;
	endcase
end

//Set set_zero_cnt 
always @(posedge clk or reset) begin
	if(reset) set_zero_cnt <= 7'd0;
	else if(state==IDLE) set_zero_cnt <= set_zero_cnt + 7'd1;
	else set_zero_cnt <= 7'd0;
end

//Set iaddr 
always @(posedge clk) begin
	if(state==IDLE) iaddr <= 12'd0;
	else if(state==Read||(state==Write&&next_state!=MaxPool)) iaddr <= iaddr + 12'd1;
	else if(state==Conv&&iaddr==12'd4095&&load==1'b1) iaddr <= 12'd0;
	else if(state==Conv&&load==1'b1) iaddr <= iaddr + 12'd1;
	else if(state==Delay) iaddr <= 12'd0;
	else if(state==MaxPool||next_state==MaxPool) begin 
		if(iaddr==12'd0) iaddr <= iaddr + 12'd2;
		else iaddr <= (iaddr[5:0] == 6'd62)? iaddr + 12'd66 : iaddr + 12'd2; //iaddr % 64 == 62 
	end
	else;
end

//Set Counter
always @(posedge clk) begin
	if(state==IDLE) {counter,load} <= 5'd0;
	else if(counter==4'd8&&load==1'b0) begin //讓他在數到第八後變 0 
		load <= 1'b1;
		counter <= 4'd0;
	end
	else if(next_state==Conv||state==Conv) begin
		if(load) counter <= 4'd0; //延遲一個 clk 方便我接下去做 Write
		else counter <= counter + 4'd1;
		load <= 1'b0;
	end
	else {counter,load} <= 5'd0;
end
//Set Image Data,Result,cdata_wr
always @(posedge clk) begin
	case(state) 
		IDLE: begin
			result <= 40'd0;
			cdata_wr <= 20'd0;
			image_data[set_zero_cnt][0] <= 20'd0;
			image_data[0][set_zero_cnt] <= 20'd0;
			image_data[65][set_zero_cnt] <= 20'd0;
			image_data[set_zero_cnt][65] <= 20'd0;			
		end
		Read: image_data[x+1][y+1] <= idata;
		Conv: begin
			if(load==1'b0) result <= result + (image_data[x+counter%4'd3][y+counter/4'd3]*kernal);
			else begin
				image_data[x][y] <= (result[15] == 1'b1)? (result[35:16] + 20'h1) + bias : result[35:16] + bias;
				result <= 40'd0; //reset to zero
			end
		end
		Write: {cdata_wr,image_data[x][y]} <= (image_data[x][y][19:16] == 4'd0)? {2{image_data[x][y]}} : 40'd0;
		MaxPool: begin
			if(image_data[x][y]>image_data[x][y+1]&&image_data[x][y]>image_data[x+1][y]&&image_data[x][y]>image_data[x+1][y+1]) begin
				cdata_wr <= {image_data[x][y]};
			end
			else if(image_data[x+1][y]>image_data[x][y+1]&&image_data[x+1][y]>image_data[x+1][y+1]) begin
				cdata_wr <= image_data[x+1][y];
			end
			else if(image_data[x][y+1]>image_data[x+1][y+1]) begin
				cdata_wr <= image_data[x][y+1];
			end
			else begin
				cdata_wr <= image_data[x+1][y+1];
			end			
		end
		default:;
	endcase
end

//Set caddr_wr
always @(posedge clk) begin
	case(state)
		IDLE: caddr_wr <= 12'd0;
		Write: caddr_wr <= iaddr;
		MaxPool: caddr_wr <= caddr_wr + 12'd1;
		default: caddr_wr <= 12'd0;
	endcase
end

//Set csel 
always @(posedge clk) begin
	if(state==IDLE) csel <= 3'b000;
	else if(next_state==Write) csel <= 3'b001;
	else if(next_state==MaxPool) csel <= 3'b011;
	else;
end
endmodule


module Kernel_block(
	input [3:0] counter,
	output reg signed [19:0] kernal
);
	always @(*) begin
		case(counter)
			4'd0: kernal = 20'h0A89E;
			4'd1: kernal = 20'h092D5;
			4'd2: kernal = 20'h06D43;
			4'd3: kernal = 20'h01004;
			4'd4: kernal = 20'hF8F71;
			4'd5: kernal = 20'hF6E54;
			4'd6: kernal = 20'hFA6D7;
			4'd7: kernal = 20'hFC834;
			4'd8: kernal = 20'hFAC19;
			default: kernal = 20'd0;
		endcase
	end
endmodule



