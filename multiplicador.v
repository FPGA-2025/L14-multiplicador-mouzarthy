module Multiplier #(
    parameter N = 4
) (
    input wire clk,
    input wire rst_n,

    input wire start,
    output reg ready,

    input wire   [N-1:0] multiplier,
    input wire   [N-1:0] multiplicand,
    output reg [2*N-1:0] product
);
    reg [2*N-1:0] accumulator;
    reg [N-1:0] shifted_multiplicand;
    reg [N-1:0] current_multiplier;
    reg [N-1:0] counter;
    reg state;

    localparam IDLE = 0;
    localparam MULTIPLYING = 1;
    localparam DONE = 2;

    always @(posedge clk or negedge rst_n) 
    begin
        if (!rst_n) 
        begin
            state <= IDLE;
            ready <= 1'b0;
            product <= 0;
            accumulator <= 0;
            shifted_multiplicand <= 0;
            current_multiplier <= 0;
            counter <= 0;
        end 
        else 
        begin
            case (state)
                IDLE: 
                begin
                    ready <= 1'b0;
                    if(start) 
                    begin
                        state <= MULTIPLYING;
                        accumulator <= 0;
                        shifted_multiplicand <= multiplicand;
                        current_multiplier <= multiplier;
                        counter <= 0;
                    end
                end
                MULTIPLYING: 
                begin
                    if(current_multiplier[0]) 
                    begin
                        accumulator <= accumulator + shifted_multiplicand;
                    end
                    current_multiplier <= current_multiplier >> 1;
                    shifted_multiplicand <= shifted_multiplicand << 1;
                    counter <= counter + 1;
                    if(counter == N) 
                    begin
                        state <= DONE;
                        product <= accumulator;
                        ready <= 1'b1;
                    end 
                    else 
                    begin
                        ready <= 1'b0;
                    end
                end
                DONE: 
                begin
                    ready <= 1'b0;
                    state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end

endmodule