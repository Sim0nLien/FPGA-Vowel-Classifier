
module fft_stage_1#(
    parameter Q_IN  = 15,
    parameter Q_OUT = 15,
    parameter N     = 256
)(
    input wire clk,
    input wire reset,
    input wire valid_in,
    input wire valid_packet,
    input wire signed [Q_IN:0] data_in_real,

    output reg valid_request,
    output reg valid_out,
    output reg [3:0] addr_out,
    output reg signed [Q_OUT:0] data_out_real
    );
    
    
    localparam INIT      = 3'b000;
    localparam WAITING_1 = 3'b001;
    localparam REQUEST   = 3'b010;
    localparam WAITING_2 = 3'b011;
    localparam SEND      = 3'b100;
    
    reg [2:0] state = INIT; 

    reg signed [8:0] data_list [0:N];

    reg [8:0] counter_request = 0;
    reg [8:0] counter = 0;

    initial begin
        $readmemh("indice.mem", data_list);
    end

    always @(posedge clk)
    
    begin
        if (reset) begin
            state <= INIT;
            valid_out <= 0;
            data_out_real <= 0;
            valid_request <= 0;
        end else begin
            case (state)
                INIT : begin
                    state = WAITING_1;
                end
                WAITING_1 : begin
                    if (valid_packet) begin
                        state <= REQUEST;
                    end
                end
                REQUEST : begin
                    valid_request <= 1;
                    state <= WAITING_2;
                    addr_out <= data_list[counter_request];
                end
                WAITING_2 : begin
                    valid_request <= 0;
                    if (valid_in) begin
                        data_out_real <= data_in_real;
                        valid_out <= 1;
                        state <= SEND;
                    end
                end

                SEND : begin
                    valid_out <= 0;
                    if (counter == (N - 1)) begin
                        counter <= 0;
                        state <= INIT;
                    end else begin
                        counter <= counter + 1;
                        state <= REQUEST;
                    end
                end
            endcase
        end
    end
initial begin
    // $dumpfile("dump.vcd");
    $dumpvars(1, fft_stage_1);
end
endmodule
