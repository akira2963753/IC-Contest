module geofence( clk,reset,X,Y,valid,is_inside);
input clk;
input reset; //active high asynchronous
input [9:0] X; 
input [9:0] Y;
output reg valid; //Represent the output is valid.
output reg is_inside; //當待測物體在圍籬內，回應is_inside為high，反之low

parameter [2:0] IDLE = 3'd0,Geofence = 3'd1,Sort = 3'd2,Cal_IsInside = 3'd3,Delay1clk = 3'd4;
reg [2:0] state,next_state;

reg [9:0] object_X,object_Y;
reg [9:0] geofence_X[0:5],geofence_Y[0:5];
reg [2:0] geofence_counter,Cal_IsInside_counter; // Geofence的計數器 跟 Cal_IsInside的計數器
reg [1:0] inner_counter,outer_counter; //做Swap所需的inner 和 outter 計數器
wire [2:0] counter_A,counter_B,counter_cal_A,counter_cal_B; //做swap時的index 做cal_isinside的index

reg signed [10:0] vectorA_x,vectorB_x,vectorA_y,vectorB_y;
wire signed [20:0] AxBy,BxAy;
assign AxBy = vectorA_x*vectorB_y;
assign BxAy = vectorB_x*vectorA_y;
assign counter_A = inner_counter + 3'd1; //j+1
assign counter_B = inner_counter + 3'd2; //j+2
assign counter_cal_A = Cal_IsInside_counter; 
assign counter_cal_B = (Cal_IsInside_counter == 3'd5)? 3'd0 : Cal_IsInside_counter + 3'd1;

always @(posedge clk or posedge reset) begin
    if(reset) state <= IDLE;
    else state <= next_state;
end

always @(*) begin
    case(state)
        IDLE : next_state = Geofence;
        Geofence : next_state = (geofence_counter == 3'd6)? Sort : Geofence;
        Sort : next_state = (outer_counter == 2'd3)? Cal_IsInside : Sort;  //inner_counter == (2'd3 - outer_counter)
        Cal_IsInside : next_state = (Cal_IsInside_counter == 3'd6)? Delay1clk : Cal_IsInside;
        Delay1clk : next_state = IDLE;
        default : next_state = IDLE;
    endcase
end

//Load Object X and Y
always @(posedge clk) begin
    if(state == IDLE) {object_X,object_Y} <= {X,Y};
    else;
end

//Set Geofence Counter 
always @(posedge clk) begin
    if(state == Geofence) geofence_counter <= geofence_counter + 3'd1;
    else geofence_counter <= 3'd0; //狀態不在Geofence就歸0
end

//Load Geofence X and Y 
always @(posedge clk) begin
    if(state == Geofence) {geofence_X[geofence_counter],geofence_Y[geofence_counter]} <= {X,Y};
    else if(state == Sort) begin
        if(AxBy > BxAy) begin //做Swap
            geofence_X[counter_A] <= geofence_X[counter_B];
            geofence_Y[counter_A] <= geofence_Y[counter_B];
            geofence_X[counter_B] <= geofence_X[counter_A];
            geofence_Y[counter_B] <= geofence_Y[counter_A];
        end
        else;
    end
    else;
end

//Set inner counter Using Bubble Sort
always @(posedge clk) begin
    if(state == Sort) inner_counter <= (inner_counter == (2'd3 - outer_counter))? 2'd0 : inner_counter + 2'd1;
    else inner_counter <= 2'd0; 
end
//Set outer counter Using Bubble Sort
always @(posedge clk) begin
    if(state == Sort) begin
        if(inner_counter == (2'd3 - outer_counter)) outer_counter <= outer_counter + 2'd1;
        else;
    end
    else outer_counter <= 2'd0;
end
//Set Vector
always @(*) begin
    if(state == Sort) begin
        vectorA_x = geofence_X[0] - geofence_X[counter_A];
        vectorA_y = geofence_Y[0] - geofence_Y[counter_A];
        vectorB_x = geofence_X[0] - geofence_X[counter_B];
        vectorB_y = geofence_Y[0] - geofence_Y[counter_B];
    end
    else if(state == Cal_IsInside) begin
        vectorA_x = geofence_X[counter_cal_A] - object_X;
        vectorA_y = geofence_Y[counter_cal_A] - object_Y;
        vectorB_x = geofence_X[counter_cal_B] - geofence_X[counter_cal_A];
        vectorB_y = geofence_Y[counter_cal_B] - geofence_Y[counter_cal_A];
    end
    else {vectorA_x,vectorA_y,vectorB_x,vectorB_y} = 44'd0;
end

//Set Cal_IsInside Counter
always @(posedge clk) begin
    if(state == Cal_IsInside) Cal_IsInside_counter <= Cal_IsInside_counter + 3'd1;
    else Cal_IsInside_counter <= 3'd0;
end

//Cal_IsInside
reg [5:0] match_array;

always @(posedge clk)begin
    if(state == Cal_IsInside) begin
        if(AxBy > BxAy) match_array[Cal_IsInside_counter] <= 1'b1; 
        else match_array[Cal_IsInside_counter] <= 1'b0;
    end
    else;
end

//Output 考慮reset，因為valid跟is_inside要馬上輸出，不能等clk跳狀態，而是要看reset非同步直接變化
always @(posedge clk or posedge reset) begin
    if(reset) {valid,is_inside} <= 2'd0;
    else if(state == Cal_IsInside && Cal_IsInside_counter == 3'd6) begin
        valid <= 1'b1;
        if( match_array[0] == 1'd0 && match_array[1] == 1'd0 && match_array[2] == 1'd0 && match_array[3] == 1'd0 && match_array[4] == 1'd0 && match_array[5] == 1'd0 ) is_inside <= 1'd1;
		else if( match_array[0] == 1'd1 && match_array[1] == 1'd1 && match_array[2] == 1'd1 && match_array[3] == 1'd1 && match_array[4] == 1'd1 && match_array[5] == 1'd1 ) is_inside <= 1'd1;
		else is_inside <= 1'd0;
    end
    else {valid,is_inside} <= 2'd0;
end

endmodule