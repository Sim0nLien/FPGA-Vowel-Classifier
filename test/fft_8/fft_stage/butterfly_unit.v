
module butterfly_unit #(
    parameter Q_IN    = 15,
    parameter Q_COEFF = 15,
    parameter Q_OUT   = 15
)(
    input  wire signed [Q_IN:0]    a_real, a_imag,
    input  wire signed [Q_IN:0]    b_real, b_imag,
    input  wire signed [Q_COEFF:0] W_real, W_imag,
    output wire signed [Q_OUT:0]   y0_real, y0_imag,
    output wire signed [Q_OUT:0]   y1_real, y1_imag
);

    wire signed [Q_COEFF*Q_IN+1:0] mult_real = b_real * W_real - b_imag * W_imag;
    wire signed [Q_COEFF*Q_IN+1:0] mult_imag = b_real * W_imag + b_imag * W_real;

    wire signed [Q_OUT:0] bw_real = mult_real >>> Q_COEFF;
    wire signed [Q_OUT:0] bw_imag = mult_imag >>> Q_COEFF;

    assign y0_real = a_real + bw_real;
    assign y0_imag = a_imag + bw_imag;
    assign y1_real = a_real - bw_real;
    assign y1_imag = a_imag - bw_imag;

endmodule
