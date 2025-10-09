
module fft_stage#(
    parameter Q_IN  = 15,
    parameter Q_OUT = 15,
    parameter N     = 8,
)(
    input wire clk,
    input wire reset,
    input wire valid_in,
    input wire valid_packet,
    input wire signed [Q_IN:0] data_in_real,
    output reg valid_out,
    output reg [3:0] addr_out,
    output reg signed [Q_OUT:0] data_out_real_0,
    )
    
    // Déclaration d'un tableau de 8 valeurs (par exemple, pour stocker des entiers signés)
    
    localparam INIT      = 3'b000;
    localparam WAITING_1 = 3'b001;
    localparam REQUEST   = 3'b010;
    localparam WAITING_2 = 3'b011;
    localparam SEND      = 3'b100;
    
    reg [2:0] state = INIT; 

    reg signed [Q_IN:0] data_list [0:7] = {0, 4, 2, 6, 1, 5, 3, 7};
    
    reg signed [Q_IN:0] tmp_0 = 0;
    reg signed [Q_IN:0] tmp_1 = 0;

    reg [3:0] counter = 0;

    always @(posedge clk)
        if (reset) begin
            tmp_0 = 0;
            tmp_1 = 0;
        end else begin
            if()



                
          


endmodule
                
    




















