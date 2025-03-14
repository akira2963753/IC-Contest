module JAM (
    input CLK,
    input RST,
    output reg [2:0] W,
    output reg [2:0] J,
    input [6:0] Cost,
    output reg [3:0] MatchCount,
    output reg [9:0] MinCost,
    output reg Valid
);
    parameter [2:0] IDLE = 3'd0, DELAY_CLK = 3'd1, CAL = 3'd2, FIND_PNT = 3'd3, FIND_CPNT =3'd4,SORT = 3'd5, RESULT = 3'd6;
    reg [2:0] state,next_state;
    reg [2:0] n[0:7];
    reg [3:0] cal_counter; 
    reg finish,find_fin,change_fin;
    reg [9:0] sum;

    //Set FSM
    always @(posedge CLK or posedge RST) begin
        if(RST) state <= IDLE;
        else state <= next_state;
    end

    always @(*) begin
        case(state)
            IDLE: next_state = DELAY_CLK;
            DELAY_CLK: next_state = CAL;
            CAL: next_state = (cal_counter == 4'd8)? FIND_PNT : CAL; //計數到第八個代表成本算完也存好了
            FIND_PNT: 
                if(finish) next_state = RESULT; 
                else if(find_fin) next_state = FIND_CPNT;
                else next_state = FIND_PNT;
            FIND_CPNT: next_state = (change_fin)? SORT:FIND_CPNT;
            SORT: next_state = CAL;
            RESULT: next_state = RESULT;
            default: next_state = IDLE;
        endcase
    end

    //Set IDLE Sequence
    integer i;
    always @(posedge CLK or posedge RST) begin
        if(RST) for(i=0;i<8;i=i+1) n[i] <= i;
	else if(state==IDLE) for(i=0;i<8;i=i+1) n[i] <= i;
        else;
    end

    //Set Cal counter
    always @(posedge CLK or posedge RST) begin
        if(RST) cal_counter <= 4'd0;
        else if(state==CAL) cal_counter <= cal_counter + 4'd1;
        else cal_counter <= 4'd0;
    end

    //Set W and J 
    always @(cal_counter) begin
        W <= cal_counter;
        J <= n[cal_counter];
    end
    //Set Sum
    always @(posedge CLK or posedge RST) begin
	if(RST) sum <= 10'd0;
        else if(state==CAL) sum <= sum + Cost;
        else sum <= 10'd0;
    end
    //Set MinCost
    always @(posedge CLK or posedge RST) begin
        if(RST) MinCost <= 10'd0;
        else if(state==CAL && cal_counter==4'd8) begin
            if(MinCost==10'd0) MinCost <= sum;
            else if(sum < MinCost) MinCost <= sum;
            else;
        end
        else;
    end
    //Set MatchCount
    always @(posedge CLK or posedge RST) begin
        if(RST) MatchCount <= 4'd1;
        else if(state==CAL && cal_counter==4'd8 && MinCost != 10'd0) begin
            if(sum == MinCost) MatchCount <= MatchCount + 4'd1;
            else if(sum < MinCost) MatchCount <= 1'b1;
            else;
        end
        else;
    end

    reg [2:0] point;
    reg [2:0] p_counter;
    wire [2:0] p_counter_minus1;
    assign p_counter_minus1 = p_counter - 3'd1;

    //Set p_counter
    always @(posedge CLK or posedge RST) begin  
        if(RST) p_counter <= 3'd7;
        else if(next_state==FIND_PNT) p_counter <= p_counter - 3'd1; //NEXT_STATE
        else p_counter <= 3'd7;
    end
    //Find Point
    always @(posedge CLK or posedge RST) begin
        if(RST) {point,find_fin} <= 4'd0;
        else if(next_state==FIND_PNT) begin //NEXT_STATE
            if(n[p_counter] > n[p_counter_minus1]) begin
                point <= p_counter_minus1;
                find_fin <= 1'b1;
            end
            else;
        end
        else find_fin <= 1'b0;
    end
    //Finish Condition
    always @(posedge CLK or posedge RST) begin
        if(RST) finish <= 1'b0;
        else if(next_state==FIND_PNT&&p_counter==3'd0) finish <= 1'b1; //NEXT_STATE
        else finish <= 1'b0;
    end


    reg [2:0] c_counter;
    reg [2:0] mini_max;
    reg [2:0] c_point;
    
    //Set c_counter
    always @(posedge CLK or posedge RST) begin
        if(RST) c_counter <= 3'd0;
        else if(next_state==FIND_CPNT) c_counter <= c_counter + 3'd1; //NEXT_STATE
        else c_counter <= 3'd0;
    end

    //Find Change Point
    always @(posedge CLK or posedge RST) begin
        if(RST) begin 
            c_point <= 3'd0;
            mini_max <= 3'd7;
        end
        else if(next_state==FIND_CPNT) begin //NEXT_STATE
            if(n[point + c_counter] > n[point]) begin
                if(mini_max >= n[point + c_counter]) begin
                    mini_max <= n[point + c_counter];
                    c_point <= point + c_counter;
                end
                else;
            end
            else;
        end
        else mini_max <= 3'd7;
    end
    //Set Finish for Find Change Point
    always @(posedge CLK or posedge RST) begin
        if(RST) change_fin <= 1'b0;
        else if(next_state==FIND_CPNT && point + c_counter == 3'd7) change_fin <= 1'b1; //NEXT_STATE
        //補這個Condition 可以降低一點Cycle
        else if(next_state==FIND_CPNT && (mini_max == n[point] + 3'd1) && mini_max != 3'd7) change_fin <= 1'b1;
        else change_fin <= 1'b0;
    end
    //Change 當下一個狀態是SORT的時候就可以換了 不用多寫一個State
    always @(posedge CLK) begin
        if(next_state==SORT) begin
            n[point] <= n[c_point];
            n[c_point] <= n[point];
        end
        else;
    end

    //Sort 
    always @(posedge CLK) begin
        if(state==SORT) begin
            case(point)
                3'd0:begin
                    n[1] <= n[7];
                    n[2] <= n[6];
                    n[3] <= n[5];
                    n[7] <= n[1];
                    n[6] <= n[2];
                    n[5] <= n[3];
                end
                3'd1:begin
                    n[2] <= n[7];
                    n[3] <= n[6];
                    n[4] <= n[5];
                    n[7] <= n[2];
                    n[6] <= n[3];
                    n[5] <= n[4];
                end
                3'd2:begin
                    n[3] <= n[7];
                    n[4] <= n[6];
                    n[7] <= n[3];
                    n[6] <= n[4];
                end
                3'd3:begin
                    n[4] <= n[7];
                    n[5] <= n[6];
                    n[7] <= n[4];
                    n[6] <= n[5];
                end
                3'd4:begin
                    n[5] <= n[7];
                    n[7] <= n[5];
                end
                3'd5:begin
                    n[6] <= n[7];
                    n[7] <= n[6];
                end
                default:;
            endcase
        end
        else;
    end
    //Result
    always @(posedge CLK or posedge RST) begin
        if(RST) Valid <= 1'b0;
        else if(state==RESULT) Valid <= 1'b1;
        else Valid <= 1'b0;
    end

endmodule
