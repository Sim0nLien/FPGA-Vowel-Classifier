module butterfly_unit_no_imag #(
    parameter Q_IN    = 15,
    parameter Q_COEFF = 15,
    parameter Q_OUT   = 15
)(
    input  wire clk,
    input  wire reset,
    input  wire valid_in,
    input  wire signed [Q_IN:0]    a_real,
    input  wire signed [Q_IN:0]    b_real,
    input  wire signed [Q_COEFF:0] W_real, W_imag,
    output reg valid_out,
    output reg signed [Q_OUT:0]   y0_real, y0_imag,
    output reg signed [Q_OUT:0]   y1_real, y1_imag
);


    wire signed [Q_COEFF+Q_IN+1:0] mult_real = b_real * W_real ;
    wire signed [Q_COEFF+Q_IN+1:0] mult_imag = b_real * W_imag ;

    wire signed [Q_OUT:0] bw_real = mult_real >>> Q_COEFF;
    wire signed [Q_OUT:0] bw_imag = mult_imag >>> Q_COEFF;

    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            y0_real <= 0;
            y0_imag <= 0;
            y1_real <= 0;
            y1_imag <= 0;
        end else if (valid_in) begin
            y0_real <= a_real + bw_real;
            y0_imag <=  bw_imag;
            y1_real <= a_real - bw_real;
            y1_imag <= - bw_imag;
            valid_out <= 1;
        end
        else begin
            valid_out <= 0;
        end
    end
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, butterfly_unit_no_imag);
  end
endmodule