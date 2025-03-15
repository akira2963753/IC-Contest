module LASER (
input CLK,
input RST,
input [3:0] X,
input [3:0] Y,
output reg [3:0] C1X,
output reg [3:0] C1Y,
output reg [3:0] C2X,
output reg [3:0] C2Y,
output DONE);

parameter [2:0] IDLE=3'd0,Delay1clk=3'd1,Read=3'd2,FindCircle1=3'd3,FindCircle2=3'd4,Circle1Fix=3'd5,Circle2Fix=3'd6,Finish=3'd7;
reg [2:0] state,next_state;
reg [3:0] obj_x[0:39];
reg [3:0] obj_y[0:39];
reg [5:0] read_counter;
wire [3:0] x_diff1;
wire [3:0] x_diff2;
wire [3:0] y_diff1;
wire [3:0] y_diff2;
reg [5:0] point_counter;
reg [5:0] coverage[0:255];
reg [8:0] circle_counter;
reg [8:0] circle_counter2;
integer i;
reg [4:0] counter;
reg [5:0] temp;
reg [3:0] fix_counter;
reg [5:0] Max_cover;
reg [3:0] Max_C1X;
reg [3:0] Max_C1Y;
reg [3:0] Max_C2X;
reg [3:0] Max_C2Y;

//Set difference
assign x_diff1 = (C1X >= obj_x[point_counter])? C1X - obj_x[point_counter] : obj_x[point_counter] - C1X;
assign y_diff1 = (C1Y >= obj_y[point_counter])? C1Y - obj_y[point_counter] : obj_y[point_counter] - C1Y;
assign x_diff2 = (C2X >= obj_x[point_counter])? C2X - obj_x[point_counter] : obj_x[point_counter] - C2X;
assign y_diff2 = (C2Y >= obj_y[point_counter])? C2Y - obj_y[point_counter] : obj_y[point_counter] - C2Y;
assign DONE = (next_state==Finish);

//Set FSM
always @(posedge CLK or posedge RST) begin
    if(RST) state <= IDLE;
    else state <= next_state;
end

always @(*) begin
    case(state)
        IDLE: next_state = (read_counter==6'd39)? FindCircle1 : IDLE;
        FindCircle1: next_state = (circle_counter==9'd256)? FindCircle2 : FindCircle1;
        FindCircle2: next_state = (circle_counter2==9'd256)? Circle1Fix : FindCircle2;
        Circle1Fix: next_state = (counter==5'd16)? Circle2Fix:Circle1Fix;
        Circle2Fix: begin
            if(fix_counter==4'd6) next_state = Finish;
            else next_state = (counter==5'd16)? Circle1Fix : Circle2Fix;
        end
        Finish: next_state = IDLE;
        default: next_state = IDLE;
    endcase
end

//Set Read Counter
always @(posedge CLK or posedge RST) begin
    if(RST) read_counter <= 6'd0;
    else if(state==IDLE) read_counter <= read_counter + 6'd1;
    else read_counter <= 6'd0;
end
//Read X and Y 
always @(posedge CLK) begin
    if(state==IDLE) begin
        obj_x[read_counter] <= X;
        obj_y[read_counter] <= Y;
    end
    else;
end

//Set Point Counter
always @(posedge CLK) begin
    if(state==FindCircle1) point_counter <= (point_counter==6'd40)? 6'd0 : point_counter + 6'd1; //數到40(緩衝)
    else if(state==FindCircle2) point_counter <= (point_counter==6'd40)? 6'd0 : point_counter + 6'd1; //數到40(緩衝)
    else if(state==Circle1Fix&&(counter[0] != 1'd0)) point_counter <= (point_counter==6'd39)? 6'd0 : point_counter + 6'd1;
    else if(state==Circle2Fix&&(counter[0] != 1'd0)) point_counter <= (point_counter==6'd39)? 6'd0 : point_counter + 6'd1;
    else point_counter <= 6'd0;
end
//Set Circle Counter
always @(posedge CLK) begin
    if(state==IDLE) circle_counter <= 9'd0;
    else if(state==FindCircle1&&point_counter==6'd39) circle_counter <= circle_counter + 9'd1;
    else;
end
//Set Circle Counter2
always @(posedge CLK) begin
    if(state==IDLE) circle_counter2 <= 9'd0;
    else if(state==FindCircle2&&point_counter==6'd39) circle_counter2 <= circle_counter2 + 9'd1;
    else;
end
//Set C1X,X1Y,C2X,C2Y
always @(posedge CLK) begin
    if(state==IDLE) {C1X,C1Y,C2X,C2Y} <= 16'd0;
    else if(state==FindCircle1&&next_state!=FindCircle2) begin 
        if(circle_counter <= 9'd15) begin
            C1X <= circle_counter;
            C1Y <= 4'd0;
        end
        else begin
            C1X <= circle_counter[3:0];
            C1Y <= circle_counter >> 4;           
        end
    end
    else if(state==FindCircle2&&next_state!=Circle1Fix) begin
        if(circle_counter2 <= 9'd15) begin
            C2X <= circle_counter2;
            C2Y <= 4'd0;
        end
        else begin
            C2X <= circle_counter2[3:0];
            C2Y <= circle_counter2 >> 4;           
        end     
    end
    else if(state==Circle1Fix&&point_counter==6'd0&&next_state!=Circle2Fix) begin
        case(counter)
            5'd0:begin
                C1X <= C1X - 4'd1;
                C1Y <= C1Y - 4'd1;
            end
            5'd2:C1X <= C1X + 4'd1;
            5'd4:C1X <= C1X + 4'd1;
            5'd6:C1Y <= C1Y + 4'd1;
            5'd8:C1Y <= C1Y + 4'd1;
            5'd10:C1X <= C1X - 4'd1;
            5'd12:C1X <= C1X - 4'd1;
            5'd14:C1Y <= C1Y - 4'd1;
            default:;
        endcase
    end
    else if(state==Circle2Fix&&point_counter==6'd0&&(next_state!=Circle1Fix||next_state!=Finish)) begin
        case(counter)
            5'd0:begin
                C2X <= C2X - 4'd1;
                C2Y <= C2Y - 4'd1;
            end
            5'd2:C2X <= C2X + 4'd1;
            5'd4:C2X <= C2X + 4'd1;
            5'd6:C2Y <= C2Y + 4'd1;
            5'd8:C2Y <= C2Y + 4'd1;
            5'd10:C2X <= C2X - 4'd1;
            5'd12:C2X <= C2X - 4'd1;
            5'd14:C2Y <= C2Y - 4'd1;
            default:;
        endcase
    end
    else if(next_state==FindCircle2) {C1X,C1Y} <= {Max_C1X,Max_C1Y};
    else if(next_state==Circle1Fix) {C2X,C2Y} <= {Max_C2X,Max_C2Y};
    else if(next_state==Circle2Fix) {C1X,C1Y} <= {Max_C1X,Max_C1Y};
    else if(next_state==Finish) {C1X,C1Y,C2X,C2Y} <= {Max_C1X,Max_C1Y,Max_C2X,Max_C2Y};
    else;
end

//Find Circle 1 
always @(posedge CLK) begin
    if(state==IDLE) for(i=0;i<225;i=i+1) coverage[i] <= 6'd0;
    else if(state==FindCircle1) begin
        if(x_diff1*x_diff1 + y_diff1*y_diff1 <= 13'd16) coverage[circle_counter] <= coverage[circle_counter] + 6'd1;
        else;
    end
    else if(state==FindCircle2) begin
        if(x_diff1*x_diff1 + y_diff1*y_diff1 > 13'd16) begin
            if(x_diff2*x_diff2 + y_diff2*y_diff2 <= 13'd16) coverage[circle_counter2] <= coverage[circle_counter2] + 6'd1;
            else;
        end
        else;
    end
    else;
end

//看看是否為最大覆蓋
always @(posedge CLK) begin
    if(state==IDLE) begin
	Max_cover <= 6'd0;
	{Max_C1X,Max_C1Y,Max_C2X,Max_C2Y} <= 16'd0;
    end
    else if(state==FindCircle1 && point_counter==6'd39) begin //計數到第40個的時候 紀錄一下目前大小
        if(coverage[circle_counter] >= Max_cover) begin
            Max_cover <= coverage[circle_counter];
            Max_C1X <= C1X;
            Max_C1Y <= C1Y;
        end
        else;
    end
    else if(state==FindCircle2 && point_counter==6'd39) begin //計數到第40個的時候 紀錄一下目前大小
        if(coverage[circle_counter2] >= Max_cover) begin
            Max_cover <= coverage[circle_counter2];
            Max_C2X <= C2X;
            Max_C2Y <= C2Y;
        end
        else;
    end
    else if(state==Circle1Fix&&(counter[0] == 1'd0)) begin
        if(Max_cover <= temp) begin
            Max_cover <= temp;
            Max_C1X <= C1X;
            Max_C1Y <= C1Y;
        end
        else;
    end
    else if(state==Circle2Fix&&(counter[0] == 1'd0)) begin
        if(Max_cover <= temp) begin
            Max_cover <= temp;
            Max_C2X <= C2X;
            Max_C2Y <= C2Y;
        end
        else;
    end
    else;
end

//Set counter
always @(posedge CLK) begin
    if(state==IDLE) counter <= 6'd0;
    else if(state==Circle1Fix&&(counter[0] == 1'd0)) counter <= (counter==5'd16)? 5'd0 : counter + 6'd1;
    else if(state==Circle1Fix&&point_counter==6'd39) counter <= counter + 6'd1;
    else if(state==Circle2Fix&&(counter[0] == 1'd0)) counter <= (counter==5'd16)? 5'd0 : counter + 6'd1;
    else if(state==Circle2Fix&&point_counter==6'd39) counter <= counter + 6'd1;
    else;
end

//設定其他25宮格的Coverage Temp
always @(posedge CLK) begin
    if(state==IDLE) temp <= 6'd0;
    else if(state==Circle1Fix&&(counter[0] != 1'd0)) begin
        if(x_diff1*x_diff1 + y_diff1*y_diff1 <= 13'd16) begin
            temp <= temp + 6'd1;
        end
        else begin
            if(x_diff2*x_diff2 + y_diff2*y_diff2 <= 13'd16) begin
                temp <= temp + 6'd1;
            end
        end
    end
    else if(state==Circle2Fix&&(counter[0] != 1'd0)) begin
        if(x_diff1*x_diff1 + y_diff1*y_diff1 <= 13'd16) begin
            temp <= temp + 6'd1;
        end
        else begin
            if(x_diff2*x_diff2 + y_diff2*y_diff2 <= 13'd16) begin
                temp <= temp + 6'd1;
            end
        end
    end
    else temp <= 6'd0;
end

//Set 迭代計數器
always @(posedge CLK) begin
    if(state==IDLE) fix_counter <= 2'd0;
    else if(state==Circle2Fix&&counter==5'd16) fix_counter <= fix_counter + 4'd1;
    else; 
end

endmodule
