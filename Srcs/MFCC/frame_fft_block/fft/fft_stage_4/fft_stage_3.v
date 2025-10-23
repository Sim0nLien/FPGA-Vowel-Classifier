
module fft_stage_3#(
    parameter Q_IN  = 15,
    parameter Q_DATA = 15,
    parameter Q_OUT = 15,
    parameter N     = 8
)(
    input wire clk,
    input wire reset,
    input wire valid_in,

    input wire signed [Q_IN:0] data_in_real_0,
    input wire signed [Q_IN:0] data_in_imag_0,
    input wire signed [Q_IN:0] data_in_real_1,
    input wire signed [Q_IN:0] data_in_imag_1,

    output reg valid_out,
    output reg signed [Q_OUT:0] data_out_real_0,
    output reg signed [Q_OUT:0] data_out_imag_0,
    output reg signed [Q_OUT:0] data_out_real_1,
    output reg signed [Q_OUT:0] data_out_imag_1,
    output reg signed [Q_OUT:0] coeff_out_real,
    output reg signed [Q_OUT:0] coeff_out_imag
    );
    


    localparam INIT = 3'b00;
    localparam WAIT_DATA = 3'b001;
    localparam GET = 3'b010;
    localparam SEND = 3'b011;
    localparam WAIT_CALCULUS = 3'b100;

    reg [2:0] state = INIT; 

    reg signed [Q_IN:0] data_list_real [0:7];
    reg signed [Q_IN:0] data_list_imag [0:7];

    reg signed [Q_IN:0] indice_list [0:7];
    reg signed [Q_DATA:0] coeff_real [0:3];
    reg signed [Q_DATA:0] coeff_imag [0:3];

    // TODO : valeur à déterminer

    initial begin
        indice_list[0] = 0;
        indice_list[1] = 2;
        indice_list[2] = 4;
        indice_list[3] = 6;
        indice_list[4] = 1;
        indice_list[5] = 3;
        indice_list[6] = 5;
        indice_list[7] = 7;
    end

    initial begin
        $readmemh("fft_stage_3/real.mem", coeff_real);
        $readmemh("fft_stage_3/imag.mem", coeff_imag);
    end

    reg [3:0] counter_get = 0;
    reg [3:0] counter_send = 0;
    reg [1:0] counter_wait = 0;

    reg [2:0] idx = 0;



    always @(posedge clk)
    begin
        if (reset) begin
            state <= INIT;
            valid_out <= 0;
            counter_get <= 0;
            counter_send <= 0;
            counter_wait <= 0;
            data_out_real_0 <= 0;
            data_out_imag_0 <= 0;
            data_out_real_1 <= 0;
            data_out_imag_1 <= 0;
            coeff_out_real <= 0;
            coeff_out_imag <= 0;
            idx <= 0;
            
        end else begin
            case (state)
                INIT: begin
                    counter_get <= 0;
                    counter_send <= 0;
                    counter_wait <= 0;
                    valid_out <= 0;
                    state <= WAIT_DATA;
                    idx <= 0;
                end
                WAIT_DATA: begin
                    if (valid_in) begin
                        data_list_real[indice_list[counter_get]] <= data_in_real_0;
                        data_list_imag[indice_list[counter_get]] <= data_in_imag_0;
                        data_list_real[indice_list[counter_get + 1]] <= data_in_real_1;
                        data_list_imag[indice_list[counter_get + 1]] <= data_in_imag_1;
                        state <= GET;
                    end
                end
                GET: begin
                    if (counter_get < N / 2 + 1) begin
                        counter_get <= counter_get + 2;
                        state <= WAIT_DATA;
                    end else begin
                        counter_get <= 0;
                        state <= SEND;
                    end 
                    if (idx == 4) begin
                        idx <= 0;
                    end
                end
                SEND: begin
                    if (counter_wait == 0) begin
                        valid_out <= 1;
                        coeff_out_real <= coeff_real[idx];
                        coeff_out_imag <= coeff_imag[idx];
                        data_out_real_0 <= data_list_real[counter_send];
                        data_out_imag_0 <= data_list_imag[counter_send];
                        data_out_real_1 <= data_list_real[counter_send + 1];
                        data_out_imag_1 <= data_list_imag[counter_send + 1];
                        counter_wait <= counter_wait + 1;
                    end else if (counter_wait == 1) begin
                        idx <= idx + 1;
                        valid_out <= 0;
                        counter_wait <= counter_wait + 1; 
                        counter_send <= counter_send + 2;
                    end else if (counter_wait == 2) begin
                        counter_wait <= 0;
                        if (counter_send < N) begin
                            state <= SEND;
                        end else begin
                            counter_send <= 0;
                            state <= INIT;
                        end
                    end
                end
            endcase
        end
    end
    initial begin
        // $dumpfile("dump.vcd");
        $dumpvars(1, fft_stage_3);
    end
endmodule
