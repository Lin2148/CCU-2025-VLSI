//---------------------------------------------------------//
//- VLSI 2025                                              //
//-                                                        //
//- Lab11b: Logic Synthesis                                //
//---------------------------------------------------------//

`timescale 1ns/10ps

module SQRT(
    RST,
    CLK,
    IN_VALID,
    IN,
    OUT_VALID,
    OUT
);
input CLK;
input RST;
input [15:0] IN;
input IN_VALID;
output reg [11:0] OUT;
output reg OUT_VALID;

// Write your synthesizable code here
reg [25:0] operand; //16+10
reg [12:0] root;    //8+4+1 bit
reg [12:0] bitmask;
reg [3:0] cnt; //bitmask do 13 times

wire [25:0] temp;
assign temp = (root | bitmask) * (root | bitmask);

reg [1:0] state, next_state;
parameter IDLE=2'd0, CALC=2'd1, OUTPUT=2'd2;
//state

always @(posedge CLK) begin
    if (RST)
        state <= IDLE;
    else
        state <= next_state;
end

always @(*) begin
    case (state)
        IDLE:begin
            if (IN_VALID)
                next_state <= CALC;
            else
                next_state <= IDLE;
        end
        CALC:begin
            if (cnt == 13)
                next_state <= OUTPUT;
            else
                next_state <= CALC;
        end
        OUTPUT:begin
            if (OUT_VALID)
                next_state <= IDLE;
            else
                next_state <= OUTPUT;
        end
    endcase
end

always @(posedge CLK or posedge RST) begin
    if (RST)begin
        operand <= 0;
        root <= 0;
        bitmask <= 13'h1000;   //top down check
        cnt <= 0;
    end else begin
        case (state)
            IDLE:begin
                if (IN_VALID) begin
                    operand <= {IN,10'b0};
                    root <= 0;
                    bitmask <= 13'h1000;
                    cnt <= 0;
                end
            end
            CALC:begin
                if (cnt <= 12) begin
                    if (temp <= operand)begin
                        root <= (root | bitmask) ;
                    end
                    bitmask <= bitmask >> 1;
                    cnt <= cnt + 1;
                end
            end
        endcase
    end
end

always @(posedge CLK or posedge RST) begin
    if (RST)begin
        OUT_VALID <= 0;
        OUT <= 0;
    end else begin
        case (state)
            IDLE:begin
                OUT_VALID <= 0;
                OUT <= 0;
            end
            CALC:begin
                if (cnt == 13) begin
                    OUT <= (root[0]) ? ((root[12:1]) + 1) : (root[12:1]);
                    OUT_VALID <= 1;
                end
            end
            OUTPUT:begin
                OUT_VALID <= 0;
            end
        endcase
    end
end
endmodule