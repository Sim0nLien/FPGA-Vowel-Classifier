module window #(
    parameter Q_IN  = 15,
    parameter Q_OUT = 15,
    parameter N     = 256
)(
    input wire clk,
    input wire reset,
    input wire valid_in,
    input wire signed [Q_IN:0] data_in,
    output reg valid_out,
    output reg signed [Q_OUT:0] data_out
);

    localparam WAITING = 2'b00;
    localparam COMPUTE = 2'b01;
    localparam SENDING = 2'b10;

    reg [1:0] state, next_state;
    
    signed [0:N-1] data_memory [0:Q_IN];
    signed [0:N-1] window [0:Q_IN];

    initial begin
        $readmemh("window_hamming.mem", window);
    end

    always @(posedge clk)
    

         if re










