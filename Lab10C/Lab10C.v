//----------------------------------------------------------------------
//- VLSI 2025
//-
//- Lab10c: Verilog Behavior-Level
//----------------------------------------------------------------------

module CHIP(
    CLK,
    RESET,
    IN_VALID,
    IN_DATA,
    OUT_VALID,
    OUT_DATA_X,
    OUT_DATA_Y,
    OUT_DATA_SUM
);

//input port
input       CLK;
input       RESET;
input       IN_VALID;
input [7:0] IN_DATA;

//output port
output reg        OUT_VALID;
output reg [3:0]  OUT_DATA_X;
output reg [3:0]  OUT_DATA_Y;
output reg [15:0] OUT_DATA_SUM;

/*
reg OUT_VALID;
reg [3:0] OUT_DATA_X_reg, OUT_DATA_Y_reg;
reg [15:0] OUT_DATA_SUM_reg;
assign OUT_DATA_SUM = OUT_DATA_SUM_reg;
*/
//////////////////////////////////////
//design your code there//////////////
//////////////////////////////////////

reg [4:0] in_cnt, calc_cnt, out_cnt, path_cnt;
reg [7:0] i_data [0:24];
reg [2:0] idx_x  [0:24];  //f(x,y)
reg [2:0] idx_y  [0:24];

integer i;
reg [15:0] dp_sum[0:24];

reg [15:0] path_sum[0:8];
reg [3:0]  path_x[0:8];
reg [3:0]  path_y[0:8];

reg [3:0] state, next_state;
parameter IDLE=3'd0, INPUT=3'd1, CALC=3'd2, OUT=3'd4;
//state

always @(posedge CLK) begin
    if (RESET)
        state <= IDLE;
    else
        state <= next_state;
end

always @(*) begin
    case (state)
        IDLE:begin
            if (IN_VALID)
                next_state <= INPUT;
            else
                next_state <= IDLE;
        end
        INPUT:begin
            if (in_cnt == 23)
                next_state <= CALC;
            else
                next_state <= INPUT;
        end
        CALC:begin
            if (calc_cnt == 24)
                next_state <= OUT;
            else
                next_state <= CALC;
        end
        OUT:begin
            if (out_cnt == 8)
                next_state <= IDLE;
            else
                next_state <= OUT;
        end
    endcase
end

always @(posedge CLK) begin
    if (RESET)begin
        in_cnt <= 0;
        for (i=0; i<=24; i=i+1) i_data[i] <= 0;
    end else begin
        case (state)
            IDLE:begin
                if (IN_VALID) begin
                    i_data[in_cnt+1] <= IN_DATA;
                    in_cnt <= in_cnt + 1;
                end else begin
                    in_cnt <= 0;
                end
            end
            INPUT:begin
                i_data[in_cnt+1] <= IN_DATA;
                in_cnt <= in_cnt + 1;
            end
        endcase
    end
end

always @(posedge CLK) begin
    if (RESET)begin
        for (i=0; i<=24; i=i+1) idx_x[i] <= 0;
        for (i=0; i<=24; i=i+1) idx_y[i] <= 0;
    end else begin
        case (state)
            IDLE:begin
                if (IN_VALID) begin
                    idx_x[in_cnt+1] <= in_cnt+1;
                    idx_y[in_cnt+1] <= 0;
                end
            end
            INPUT:begin
                if (in_cnt <= 3) begin
                    idx_x[in_cnt+1] <= in_cnt+1;
                    idx_y[in_cnt+1] <= 0;
                end else if (in_cnt <= 8) begin
                    idx_x[in_cnt+1] <= in_cnt-4;
                    idx_y[in_cnt+1] <= 1;
                end else if (in_cnt <= 13) begin
                    idx_x[in_cnt+1] <= in_cnt-9;
                    idx_y[in_cnt+1] <= 2;
                end else if (in_cnt <= 18) begin
                    idx_x[in_cnt+1] <= in_cnt-14;
                    idx_y[in_cnt+1] <= 3;
                end else if (in_cnt <= 23) begin
                    idx_x[in_cnt+1] <= in_cnt-19;
                    idx_y[in_cnt+1] <= 4;
                end
            end
        endcase
    end
end

always @(posedge CLK) begin
    if (RESET)begin
        calc_cnt <= 0;
        path_cnt <= 0;
        for (i=0; i<=24; i=i+1) dp_sum[i] <= 0;
    end else begin
        case (state)
            IDLE:begin
                calc_cnt <= 0;
                path_cnt <= 0;
            end
            CALC:begin
                if (idx_x[calc_cnt] <= 3 && idx_y[calc_cnt] <= 3)begin
                    if (i_data[calc_cnt + 1] <= i_data[calc_cnt + 5]) begin //choose right for next step
                        dp_sum[calc_cnt+1] <= dp_sum[calc_cnt] + i_data[calc_cnt+1];
                        calc_cnt <= calc_cnt + 1;
                        path_sum[path_cnt] <= dp_sum[calc_cnt];
                        path_x[path_cnt] <= idx_x[calc_cnt];
                        path_y[path_cnt] <= idx_y[calc_cnt];
                        path_cnt <= path_cnt + 1;
                    end else begin
                        dp_sum[calc_cnt + 5] <= dp_sum[calc_cnt] + i_data[calc_cnt+5];
                        calc_cnt <= calc_cnt + 5;
                        path_sum[path_cnt] <= dp_sum[calc_cnt];
                        path_x[path_cnt] <= idx_x[calc_cnt];
                        path_y[path_cnt] <= idx_y[calc_cnt];
                        path_cnt <= path_cnt + 1;
                    end
                end else if (idx_x[calc_cnt] == 4)begin   //only can go up
                    dp_sum[calc_cnt + 5] <= dp_sum[calc_cnt] + i_data[calc_cnt+5];
                    calc_cnt <= calc_cnt + 5;
                    path_sum[path_cnt] <= dp_sum[calc_cnt];
                    path_x[path_cnt] <= idx_x[calc_cnt];
                    path_y[path_cnt] <= idx_y[calc_cnt];
                    path_cnt <= path_cnt + 1;
                end else begin
                    dp_sum[calc_cnt + 1] <= dp_sum[calc_cnt] + i_data[calc_cnt+1]; //only can go right
                    calc_cnt <= calc_cnt + 1;
                    path_sum[path_cnt] <= dp_sum[calc_cnt];
                    path_x[path_cnt] <= idx_x[calc_cnt];
                    path_y[path_cnt] <= idx_y[calc_cnt];
                    path_cnt <= path_cnt + 1;
                end
            end
        endcase
    end
end

always @(posedge CLK) begin
    if (RESET)begin
        out_cnt <= 0;
        OUT_VALID <= 0;
    end else begin
        case (state)
            IDLE:begin
                OUT_VALID <= 0;
                out_cnt <= 0;
            end
            OUT:begin
                OUT_VALID <= 1;
                out_cnt <= out_cnt + 1;
                OUT_DATA_X <= path_x[out_cnt+1];
                OUT_DATA_Y <= path_y[out_cnt+1];
                OUT_DATA_SUM <= path_sum[out_cnt+1];
            end
        endcase
    end
end
endmodule