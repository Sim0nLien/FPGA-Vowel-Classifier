module top_fft#(
    parameter Q_IN = 15,
    parameter Q_DATA = 15,
    parameter Q_OUT = 15,
    parameter N = 256
)(
    input  wire clk,
    input  wire reset,
    input  wire valid_in,
    input  wire valid_packet,
    input  wire signed [Q_IN:0] data_in,
    
    output reg valid_out,
    output reg [3:0] addr_out,
    output reg signed [Q_OUT:0] data_fft_real_0,
    output reg signed [Q_OUT:0] data_fft_imag_0,
    output reg signed [Q_OUT:0] data_fft_real_1,
    output reg signed [Q_OUT:0] data_fft_imag_1
);

    reg valid_request_stage_1_unit_1;

    reg valid_out_stage_1_unit_1;

    reg [Q_OUT:0] data_real_stage_1_unit_1;
    reg [Q_OUT:0] data_imag_stage_1_unit_1;

    reg [Q_OUT:0] coeff_real_stage_1_unit_1;
    reg [Q_OUT:0] coeff_imag_stage_1_unit_1;
    

    fft_stage_1 #(
        .Q_IN(Q_IN),
        .Q_OUT(Q_OUT),
        .N(N)
    )inst_fft_stage_1(
        .clk(clk),
        .reset(reset),
        .valid_in(paquet_ready),
        .valid_packet(valid_out),
        .data_in_real(data_in),
        .valid_request(valid_request),
        .valid_out(valid_out),
        .addr_out(addr_out),
        .data_out_real(data_real_stage_1_unit_1),
        .coeff_out_real(coeff_real_stage_1_unit_1),
        .coeff_out_imag(coeff_imag_stage_1_unit_1)
    );


    reg [Q_OUT:0] data_real_0_butter_1_stage_2;
    reg [Q_OUT:0] data_imag_0_butter_1_stage_2;
    reg [Q_OUT:0] data_real_1_butter_1_stage_2;
    reg [Q_OUT:0] data_imag_1_butter_1_stage_2;


    butterfly_unit_no_imag  #(
        .Q_IN(Q_IN),
        .Q_DATA(Q_DATA),
        .Q_OUT(Q_OUT)
    )inst_butterfly_unit_no_imag(
        .clk(clk),
        .reset(reset),
        .valid_in(valid_out_stage_1_unit_1),
        .a_real(data_real_stage_1_unit_1),
        .b_real(data_real_stage_1_unit_1),
        .W_real(coeff_real_stage_1_unit_1),
        .W_imag(coeff_imag_stage_1_unit_1),
        .y0_real(data_real_0_butter_1_stage_2),
        .y0_imag(data_imag_0_butter_1_stage_2),
        .y1_real(data_real_1_butter_1_stage_2),
        .y1_imag(data_imag_1_butter_1_stage_2)
    );

    reg valid_out_stage_2_butter_2;

    reg [Q_OUT:0] data_real_0_stage_2_butter_2;
    reg [Q_OUT:0] data_imag_0_stage_2_butter_2;
    reg [Q_OUT:0] data_real_1_stage_2_butter_2;
    reg [Q_OUT:0] data_imag_1_stage_2_butter_2;
    
    reg [Q_OUT:0] coeff_real_stage_2_butter_2;
    reg [Q_OUT:0] coeff_imag_stage_2_butter_2;

    fft_stage_2  #(
        .Q_IN(Q_IN),
        .Q_OUT(Q_OUT),
        .N(N)
    )inst_fft_stage_2(
        .clk(clk),
        .reset(reset),
        .valid_in(open),
        .data_in_real_0(data_real_0_butter_1_stage_2),
        .data_in_imag_0(data_imag_0_butter_1_stage_2),
        .data_in_real_1(data_real_1_butter_1_stage_2),
        .data_in_imag_1(data_imag_1_butter_1_stage_2),
        
        .valid_out(valid_out_stage_2_butter_2),
        .data_out_real_0(data_real_0_stage_2_butter_2),
        .data_out_imag_0(data_imag_0_stage_2_butter_2),
        .data_out_real_1(data_real_1_stage_2_butter_2),
        .data_out_imag_1(data_imag_1_stage_2_butter_2),
        .coeff_out_real(coeff_real_stage_2_butter_2),
        .coeff_out_imag(coeff_imag_stage_2_butter_2)
    );

    reg [Q_OUT:0] data_real_0_butter_2_stage_3;
    reg [Q_OUT:0] data_imag_0_butter_2_stage_3;
    reg [Q_OUT:0] data_real_1_butter_2_stage_3;
    reg [Q_OUT:0] data_imag_1_butter_2_stage_3;

    reg valid_out_butter_2_stage_3;

    butterfly_unit  #(
        .Q_IN(Q_IN),
        .Q_DATA(Q_DATA),
        .Q_OUT(Q_OUT)
    )inst_butterfly_unit_2(
        .clk(clk),
        .reset(reset),
        .valid_in(valid_out_stage_2_butter_2),
        .a_real(data_real_0_stage_2_butter_2),
        .a_imag(data_imag_0_stage_2_butter_2),
        .b_real(data_real_1_stage_2_butter_2),
        .b_imag(data_imag_1_stage_2_butter_2),
        .W_real(coeff_real_stage_2_butter_2),
        .W_imag(coeff_imag_stage_2_butter_2),
        .valid_out(valid_out_butter_2_stage_3),
        .y0_real(data_real_0_butter_2_stage_3),
        .y0_imag(data_imag_0_butter_2_stage_3),
        .y1_real(data_real_1_butter_2_stage_3),
        .y1_imag(data_imag_1_butter_2_stage_3)
    );

    reg valid_out_stage_3_butter_3;

    reg [Q_OUT:0] data_real_0_stage_3_butter_3;
    reg [Q_OUT:0] data_imag_0_stage_3_butter_3;
    reg [Q_OUT:0] data_real_1_stage_3_butter_3;
    reg [Q_OUT:0] data_imag_1_stage_3_butter_3;

    reg [Q_OUT:0] coeff_real_stage_3_butter_3;
    reg [Q_OUT:0] coeff_imag_stage_3_butter_3;

    fft_stage_3  #(
        .Q_IN(Q_IN),
        .Q_OUT(Q_OUT),
        .N(N)
    )inst_fft_stage_3(
        .clk(clk),
        .reset(reset),
        .valid_in(valid_out_butter_2_stage_3),
        .data_in_real_0(data_real_0_butter_2_stage_3),
        .data_in_imag_0(data_imag_0_butter_2_stage_3),
        .data_in_real_1(data_real_1_butter_2_stage_3),
        .data_in_imag_1(data_imag_1_butter_2_stage_3),

        .valid_out(valid_out_stage_3_butter_3),
        .data_out_real_0(data_real_0_stage_3_butter_3),
        .data_out_imag_0(data_imag_0_stage_3_butter_3),
        .data_out_real_1(data_real_1_stage_3_butter_3),
        .data_out_imag_1(data_imag_1_stage_3_butter_3),
        .coeff_out_real(coeff_real_stage_3_butter_3),
        .coeff_out_imag(coeff_imag_stage_3_butter_3)
    );

    butterfly_unit  #(
        .Q_IN(Q_IN),
        .Q_DATA(Q_DATA),
        .Q_OUT(Q_OUT)
    )inst_butterfly_unit_3(
        .clk(clk),
        .reset(reset),
        .valid_in(valid_out_stage_3_butter_3),
        .a_real(data_real_0_stage_3_butter_3),
        .a_imag(data_imag_0_stage_3_butter_3),
        .b_real(data_real_1_stage_3_butter_3),
        .b_imag(data_imag_1_stage_3_butter_3),
        .W_real(coeff_real_stage_3_butter_3),
        .W_imag(coeff_imag_stage_3_butter_3),
        .valid_out(valid_out),
        .y0_real(data_fft_real_0),
        .y0_imag(data_fft_imag_0),
        .y1_real(data_fft_real_1),
        .y1_imag(data_fft_imag_1)
    );

endmodule