
module fft_stage_1#(
    parameter Q_IN  = 15,
    parameter Q_OUT = 15,
    parameter N     = 8
)(
    input wire clk,
    input wire reset,
    input wire valid_in,
    input wire valid_packet,
    input wire signed [Q_IN:0] data_in_real,
    input wire signed [Q_IN:0] data_in_imag,

    output reg valid_request,
    output reg valid_out,
    output reg [3:0] addr_out,
    output reg signed [Q_OUT:0] data_out_real,
    output reg signed [Q_OUT:0] data_out_imag,
    output reg signed [Q_OUT:0] coeff_out_real,
    output reg signed [Q_OUT:0] coeff_out_imag
    );
    
    
    localparam INIT      = 3'b000;
    localparam WAITING_1 = 3'b001;
    localparam REQUEST   = 3'b010;
    localparam WAITING_2 = 3'b011;
    localparam SEND      = 3'b100;
    
    reg [2:0] state = INIT; 

    reg signed [Q_IN:0] data_list [0:7];
    reg signed [Q_IN:0] coeff [0:1];

    initial begin
        data_list[0] = 0;
        data_list[1] = 4;
        data_list[2] = 2;
        data_list[3] = 6;
        data_list[4] = 1;
        data_list[5] = 5;
        data_list[6] = 3;
        data_list[7] = 7;

        coeff[0] = 1;
        coeff[1] = -1;
    end

    
    reg signed [Q_IN:0] tmp_0 = 0;
    reg signed [Q_IN:0] tmp_1 = 0;

    reg [3:0] counter = 0;

    always @(posedge clk)
    begin
        if (reset) begin
            tmp_0 = 0;
            tmp_1 = 0;
            state = INIT;
            valid_out = 0;
            data_out_real = 0;
            data_out_imag = 0;
            coeff_out_real = 0;
            coeff_out_imag = 0;
            valid_request = 0;
        end else begin
            case (state)
                INIT : begin
                    state = WAITING_1;
                end
                WAITING_1 : begin
                    if (valid_packet) begin
                        state = REQUEST;
                    end
                end
                REQUEST : begin
                    valid_request = 1;
                    state = WAITING_2;
                end
                WAITING_2 : begin
                    valid_request = 0;
                    if (valid_in) begin
                        data_out_real = data_in_real;
                        data_out_imag = data_in_imag;
                        coeff_out_real = coeff[0];
                        coeff_out_imag = coeff[1];
                        valid_out = 1;
                        state = SEND;
                    end
                end

                SEND : begin
                    valid_out = 0;
                    if (counter == (N/2 - 1)) begin
                        counter = 0;
                        state = INIT;
                    end else begin
                        counter = counter + 1;
                        state = REQUEST;
                    end
                end
            endcase
        end
    end
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, fft_stage_1);
end
endmodule
