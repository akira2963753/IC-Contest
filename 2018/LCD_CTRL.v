module LCD_CTRL(clk, reset, cmd, cmd_valid, IROM_Q, IROM_rd, IROM_A, IRAM_valid, IRAM_D, IRAM_A, busy, done);
input clk;
input reset;
input [3:0] cmd;
input cmd_valid;
input [7:0] IROM_Q;
output reg IROM_rd;
output reg [5:0] IROM_A;
output reg IRAM_valid;
output reg [7:0] IRAM_D;
output reg [5:0] IRAM_A;
output busy;
output done;

parameter [3:0] IDLE = 4'd0,READ = 4'd1,Opcode = 4'd2,Write = 4'd3,Shiftup = 4'd4,Shiftdown = 4'd5,Shiftleft = 4'd6,Shiftright = 4'd7;
parameter [3:0] Max = 4'd8,Min = 4'd9,Average = 4'd10,Counterclockwise = 4'd11,Clockwise = 4'd12,MirrorX = 4'd13,MirrorY = 4'd14,Finish = 4'd15;
reg [3:0] state,next_state;
reg [7:0] IROM[0:63];
reg [2:0] point_x;
reg [2:0] point_y;

assign done = (state==Finish);
assign busy = (next_state==Opcode)? 1'b0 : 1'b1;

//Set FSM
always @(posedge clk or posedge reset) begin
    if(reset) state <= IDLE;
    else state <= next_state;
end

always @(*) begin
    case(state)
        IDLE: next_state <= (IROM_A == 6'h3f)? Opcode : IDLE;
        Opcode: begin
            if(cmd_valid!=1'b1&&next_state==Opcode) next_state <= Opcode;
            else begin
                case(cmd)
                    4'd0: next_state <= Write;
                    4'd1: next_state <= Shiftup;
                    4'd2: next_state <= Shiftdown;
                    4'd3: next_state <= Shiftleft;
                    4'd4: next_state <= Shiftright;
                    4'd5: next_state <= Max;
                    4'd6: next_state <= Min;
                    4'd7: next_state <= Average;
                    4'd8: next_state <= Counterclockwise;
                    4'd9: next_state <= Clockwise;
                    4'd10: next_state <= MirrorX;
                    4'd11: next_state <= MirrorY;
                    default: next_state <= Finish;
                endcase
            end
        end
        Write: next_state <= (IRAM_A == 6'h3f)? Finish : Write;
        Shiftup: next_state <= Opcode;
        Shiftdown: next_state <= Opcode;
        Shiftleft: next_state <= Opcode;
        Shiftright: next_state <= Opcode;
        Max: next_state <= Opcode;
        Min: next_state <= Opcode;
        Average: next_state <= Opcode;
        Counterclockwise: next_state <= Opcode;
        Clockwise: next_state <= Opcode;
        MirrorX: next_state <= Opcode;
        MirrorY: next_state <= Opcode;
        Finish : next_state <= Finish;
        default: next_state <= IDLE;
    endcase
end

//Set IROM_A
always @(posedge clk or posedge reset) begin
    if(reset) IROM_A <= 6'd0;
    else if(state==IDLE) IROM_A <= IROM_A + 6'd1; 
    else IROM_A <= 6'd0;
end

//Set IROM_rd
always @(posedge clk or posedge reset) begin
    if(reset) IROM_rd <= 1'b1;
    else if(next_state==Opcode) IROM_rd <= 1'b0;
    else;
end

//Set IRAM_Valid
always @(posedge clk or posedge reset) begin
    if(reset) IRAM_valid <= 1'b0;
    else if(next_state==Write||state==Write) IRAM_valid <= 1'b1;
    else IRAM_valid <= 1'b0;
end

//Set Delay
reg delay;
always @(posedge clk) begin
    case(state)
        Write: delay <= 1'b1;
        default: delay <= 1'b0;
    endcase
end

//Set IRAM_A
always @(posedge clk or posedge reset) begin
    if(reset) IRAM_A <= 6'd0;
    else if(state==Write&&delay==1'b1) IRAM_A <= IRAM_A + 6'd1;
    else IRAM_A <= 6'd0;
end

//Set IRAM_D
always @(posedge clk) begin
    if(state==Write&&delay==1'b1) IRAM_D <= IROM[IRAM_A+6'd1];
    else if(state==Write) IRAM_D <= IROM[IRAM_A];
    else;
end

//Set operate opint
always @(posedge clk) begin
    case(state)
        IDLE: {point_x,point_y} <= {3'd4,3'd4};
        Shiftup: point_y <= (point_y!=3'd1)? point_y - 3'd1 : point_y;
        Shiftdown: point_y <= (point_y!=3'd7)? point_y + 3'd1 : point_y;
        Shiftleft: point_x <= (point_x!=3'd1)? point_x - 3'd1 : point_x;
        Shiftright: point_x <= (point_x!=3'd7)? point_x + 3'd1 : point_x;
        default:;
    endcase
end

wire [7:0] point1,point2,point3,point4;
wire [9:0] sum; //Extend to 10bits 
assign point1 = point_x + ((point_y-3'd1)<<3) - 8'd1;
assign point2 = point1 + 8'd1;
assign point3 = point1 + 8'd8;
assign point4 = point1 + 8'd9;
assign sum = {2'b0,IROM[point1]} + {2'b0,IROM[point2]} + {2'b0,IROM[point3]} + {2'b0,IROM[point4]};

//Set Max
always @(posedge clk) begin
    if(state==IDLE) IROM[IROM_A] <= IROM_Q; //寫入IROM_Q
    else if(state==Max) begin
        if(IROM[point1]>=IROM[point2]&&IROM[point1]>=IROM[point3]&&IROM[point1]>=IROM[point4]) begin
            {IROM[point2],IROM[point3],IROM[point4]} <= {3{IROM[point1]}};
        end
        else if(IROM[point2]>=IROM[point3]&&IROM[point2]>=IROM[point4]) begin
            {IROM[point1],IROM[point3],IROM[point4]} <= {3{IROM[point2]}};
        end
        else if(IROM[point3]>=IROM[point4]) begin
            {IROM[point1],IROM[point2],IROM[point4]} <= {3{IROM[point3]}};
        end
        else {IROM[point1],IROM[point2],IROM[point3]} <= {3{IROM[point4]}};
    end
    else if(state==Min) begin
        if(IROM[point1]<=IROM[point2]&&IROM[point1]<=IROM[point3]&&IROM[point1]<=IROM[point4]) begin
            {IROM[point2],IROM[point3],IROM[point4]} <= {3{IROM[point1]}};
        end
        else if(IROM[point2]<=IROM[point3]&&IROM[point2]<=IROM[point4]) begin
            {IROM[point1],IROM[point3],IROM[point4]} <= {3{IROM[point2]}};
        end
        else if(IROM[point3]<=IROM[point4]) begin
            {IROM[point1],IROM[point2],IROM[point4]} <= {3{IROM[point3]}};
        end
        else {IROM[point1],IROM[point2],IROM[point3]} <= {3{IROM[point4]}};
    end
    else if(state==Average) begin
        IROM[point1] <= sum >> 2;
        IROM[point2] <= sum >> 2;
        IROM[point3] <= sum >> 2;
        IROM[point4] <= sum >> 2;
    end
    else if(state==Counterclockwise) begin
        IROM[point1] <= IROM[point2];
        IROM[point2] <= IROM[point4];
        IROM[point3] <= IROM[point1];
        IROM[point4] <= IROM[point3];
    end
     else if(state==Clockwise) begin
        IROM[point1] <= IROM[point3];
        IROM[point2] <= IROM[point1];
        IROM[point3] <= IROM[point4];
        IROM[point4] <= IROM[point2];
    end
    else if(state==MirrorX) begin
        IROM[point1] <= IROM[point3];
        IROM[point2] <= IROM[point4];
        IROM[point3] <= IROM[point1];
        IROM[point4] <= IROM[point2];        
    end
    else if(state==MirrorY) begin
        IROM[point1] <= IROM[point2];
        IROM[point2] <= IROM[point1];
        IROM[point3] <= IROM[point4];
        IROM[point4] <= IROM[point3];   
    end
    else;
end

endmodule


