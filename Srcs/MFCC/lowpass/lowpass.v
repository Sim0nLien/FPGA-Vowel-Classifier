


module lowpass #(
    parameter Q_IN  = 15,
    parameter Q_OUT = 15
)(
    input  wire clk,
    input  wire reset,
    input  wire valid_in,
    input  wire signed [Q_IN:0]  data_in,
    output reg  valid_out,
    output reg  signed [Q_OUT:0] data_out
);


    localparam WAITING    = 2'b00;
    localparam OUTPUTTING = 2'b01;

    reg [1:0] state, next_state ;

    reg signed [Q_IN + Q_OUT + 1 :0] mult_result;

    reg signed [Q_IN:0] coeff_prev = '0;
    reg signed [Q_IN:0] coeff = 16'h7C28; // 0.97


    always @(posedge clk) begin
        if (reset) begin
            state     <= WAITING;
            next_state<= WAITING;
            valid_out <= 1'b0;
            mult_result <= '0;
            data_out  <= '0;
        end 
        else begin
            state <= next_state;
            case (state)
                WAITING: begin
                    valid_out <= 1'b0;
                    if (valid_in == 1) begin
                        data_out <= data_in - coeff_prev;
                        mult_result <= data_in * coeff;
                        next_state <= OUTPUTTING;
                    end
                    else begin
                        next_state <= WAITING;
                    end
                end
                OUTPUTTING: begin
                    coeff_prev <= mult_result >>> Q_IN;
                    valid_out <= 1'b1;
                    next_state <= WAITING;
                end
            endcase
        end
    end
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, lowpass);
  end
endmodule





