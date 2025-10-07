module window #(
    parameter Q_IN  = 15,
    parameter Q_COEFF = 15, 
    parameter Q_OUT = 15,
    parameter N     = 256
)(
    input wire clk,
    input wire reset,
    input wire valid_in,
    input wire valid_packet,
    input wire signed [Q_IN:0] data_in,
    output reg valid_request,
    output reg valid_out,
    output reg signed [Q_OUT:0] data_out
);

    localparam INIT =    3'b000;
    localparam WAITING = 3'b001;
    localparam REQUEST = 3'b010;
    localparam COMPUTE = 3'b011;
    localparam SEND =    3'b100;
    localparam DONE =    3'b101;

    reg [2:0] state;

    reg signed [Q_COEFF:0] window_coeff [0:N-1];
    reg signed [Q_IN:0] data ;

    reg signed [Q_IN + Q_COEFF + 1:0] tmp ;

    reg [7:0] counter;

    initial begin
        $readmemh("window_hamming.mem", window_coeff);
    end

    always @(posedge clk)
    begin
        if (reset) begin
            state     <= INIT;
            valid_out <= 1'b0;
            data_out  <= '0;
            counter   <= 0;
            data      <= '0;
            valid_request <= 1'b0;
            tmp       <= '0;
        end
        else begin
            case (state)
                INIT: begin
                    state <= WAITING;
                end
                WAITING: begin
                    valid_out <= 1'b0;
                    if (valid_packet) begin
                        counter <= 0;
                        state <= REQUEST;
                        valid_request <= 1'b1;
                    end
                end
                REQUEST: begin
                    valid_out <= 1'b0;
                    valid_request <= 1'b1;
                    if (valid_in) begin
                        state <= COMPUTE;
                        data <= data_in;
                    end
                end
                COMPUTE: begin
                    valid_request <= 1'b0;
                    tmp <= (data * window_coeff[counter]);
                    state <= SEND;
                end
                SEND: begin
                    valid_out <= 1'b1;
                    data_out <= (tmp >>> Q_COEFF);
                    if (counter == N-1) begin
                        state <= DONE;
                    end
                    else begin
                        counter <= counter + 1;
                        state <= REQUEST;
                    end
                end
                DONE: begin
                    valid_out <= 1'b0;
                    state <= WAITING;
                end
            endcase
        end
    end
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, window);
end
endmodule
            

 
                    
                        


