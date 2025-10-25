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

    

    fft_stage_1 #(
        .Q_IN(Q_IN),
        .Q_OUT(Q_OUT),
        .N(N)
    )inst_fft_stage_1(
        .clk(clk),
        .reset(reset),
        .valid_in(valid_in),
        .valid_packet(valid_packet),
        .data_in_real(data_in),
        .valid_request(valid_request),
        .valid_out(valid_out_stage_1_unit_1),
        .addr_out(addr_out),
        .data_out_real(data_real_stage_1_unit_1)
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
        .valid_out(valid_out_butter_1_stage_2),
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
        .Q_DATA(Q_DATA),
        .Q_OUT(Q_OUT),
        .N(N)
    )inst_fft_stage_2(
        .clk(clk),
        .reset(reset),
        .valid_in(valid_out_butter_1_stage_2),
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
        .Q_DATA(Q_DATA),
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



    reg [Q_OUT:0] data_real_0_butter_3_stage_4;
    reg [Q_OUT:0] data_imag_0_butter_3_stage_4;
    reg [Q_OUT:0] data_real_1_butter_3_stage_4;
    reg [Q_OUT:0] data_imag_1_butter_3_stage_4;

    reg valid_out_butter_3_stage_4;


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
        .valid_out(valid_out_butter_3_stage_4),
        .y0_real(data_real_0_butter_3_stage_4),
        .y0_imag(data_imag_0_butter_3_stage_4),
        .y1_real(data_real_1_butter_3_stage_4),
        .y1_imag(data_imag_1_butter_3_stage_4)
    );


    reg valid_out_stage_4_butter_4;

    reg [Q_OUT:0] data_real_0_stage_4_butter_4;
    reg [Q_OUT:0] data_imag_0_stage_4_butter_4;
    reg [Q_OUT:0] data_real_1_stage_4_butter_4;
    reg [Q_OUT:0] data_imag_1_stage_4_butter_4;

    reg [Q_OUT:0] coeff_real_stage_4_butter_4;
    reg [Q_OUT:0] coeff_imag_stage_4_butter_4;

    fft_stage_4  #(
        .Q_IN(Q_IN),
        .Q_DATA(Q_DATA),
        .Q_OUT(Q_OUT),
        .N(N)
    )inst_fft_stage_4(
        .clk(clk),
        .reset(reset),
        .valid_in(valid_out_butter_3_stage_4),
        .data_in_real_0(data_real_0_butter_3_stage_4),
        .data_in_imag_0(data_imag_0_butter_3_stage_4),
        .data_in_real_1(data_real_1_butter_3_stage_4),
        .data_in_imag_1(data_imag_1_butter_3_stage_4),

        .valid_out(valid_out_stage_4_butter_4),
        .data_out_real_0(data_real_0_stage_4_butter_4),
        .data_out_imag_0(data_imag_0_stage_4_butter_4),
        .data_out_real_1(data_real_1_stage_4_butter_4),
        .data_out_imag_1(data_imag_1_stage_4_butter_4),
        .coeff_out_real(coeff_real_stage_4_butter_4),
        .coeff_out_imag(coeff_imag_stage_4_butter_4)
    );



    reg [Q_OUT:0] data_real_0_butter_4_stage_5;
    reg [Q_OUT:0] data_imag_0_butter_4_stage_5;
    reg [Q_OUT:0] data_real_1_butter_4_stage_5;
    reg [Q_OUT:0] data_imag_1_butter_4_stage_5;

    reg valid_out_butter_4_stage_5;


    butterfly_unit  #(
        .Q_IN(Q_IN),
        .Q_DATA(Q_DATA),
        .Q_OUT(Q_OUT)
    )inst_butterfly_unit_4(
        .clk(clk),
        .reset(reset),
        .valid_in(valid_out_stage_4_butter_4),
        .a_real(data_real_0_stage_4_butter_4),
        .a_imag(data_imag_0_stage_4_butter_4),
        .b_real(data_real_1_stage_4_butter_4),
        .b_imag(data_imag_1_stage_4_butter_4),
        .W_real(coeff_real_stage_4_butter_4),
        .W_imag(coeff_imag_stage_4_butter_4),
        .valid_out(valid_out_butter_4_stage_5),
        .y0_real(data_real_0_butter_4_stage_5),
        .y0_imag(data_imag_0_butter_4_stage_5),
        .y1_real(data_real_1_butter_4_stage_5),
        .y1_imag(data_imag_1_butter_4_stage_5)
    );



    reg valid_out_stage_5_butter_5;

    reg [Q_OUT:0] data_real_0_stage_5_butter_5;
    reg [Q_OUT:0] data_imag_0_stage_5_butter_5;
    reg [Q_OUT:0] data_real_1_stage_5_butter_5;
    reg [Q_OUT:0] data_imag_1_stage_5_butter_5;

    reg [Q_OUT:0] coeff_real_stage_5_butter_5;
    reg [Q_OUT:0] coeff_imag_stage_5_butter_5;

    fft_stage_5  #(
        .Q_IN(Q_IN),
        .Q_DATA(Q_DATA),
        .Q_OUT(Q_OUT),
        .N(N)
    )inst_fft_stage_5(
        .clk(clk),
        .reset(reset),
        .valid_in(valid_out_butter_4_stage_5),
        .data_in_real_0(data_real_0_butter_4_stage_5),
        .data_in_imag_0(data_imag_0_butter_4_stage_5),
        .data_in_real_1(data_real_1_butter_4_stage_5),
        .data_in_imag_1(data_imag_1_butter_4_stage_5),

        .valid_out(valid_out_stage_5_butter_5),
        .data_out_real_0(data_real_0_stage_5_butter_5),
        .data_out_imag_0(data_imag_0_stage_5_butter_5),
        .data_out_real_1(data_real_1_stage_5_butter_5),
        .data_out_imag_1(data_imag_1_stage_5_butter_5),
        .coeff_out_real(coeff_real_stage_5_butter_5),
        .coeff_out_imag(coeff_imag_stage_5_butter_5)
    );



    reg [Q_OUT:0] data_real_0_butter_5_stage_6;
    reg [Q_OUT:0] data_imag_0_butter_5_stage_6;
    reg [Q_OUT:0] data_real_1_butter_5_stage_6;
    reg [Q_OUT:0] data_imag_1_butter_5_stage_6;

    reg valid_out_butter_5_stage_6;


    butterfly_unit  #(
        .Q_IN(Q_IN),
        .Q_DATA(Q_DATA),
        .Q_OUT(Q_OUT)
    )inst_butterfly_unit_5(
        .clk(clk),
        .reset(reset),
        .valid_in(valid_out_stage_5_butter_5),
        .a_real(data_real_0_stage_5_butter_5),
        .a_imag(data_imag_0_stage_5_butter_5),
        .b_real(data_real_1_stage_5_butter_5),
        .b_imag(data_imag_1_stage_5_butter_5),
        .W_real(coeff_real_stage_5_butter_5),
        .W_imag(coeff_imag_stage_5_butter_5),
        .valid_out(valid_out_butter_5_stage_6),
        .y0_real(data_real_0_butter_5_stage_6),
        .y0_imag(data_imag_0_butter_5_stage_6),
        .y1_real(data_real_1_butter_5_stage_6),
        .y1_imag(data_imag_1_butter_5_stage_6)
    );


    reg valid_out_stage_6_butter_6;

    reg [Q_OUT:0] data_real_0_stage_6_butter_6;
    reg [Q_OUT:0] data_imag_0_stage_6_butter_6;
    reg [Q_OUT:0] data_real_1_stage_6_butter_6;
    reg [Q_OUT:0] data_imag_1_stage_6_butter_6;

    reg [Q_OUT:0] coeff_real_stage_6_butter_6;
    reg [Q_OUT:0] coeff_imag_stage_6_butter_6;

    fft_stage_6  #(
        .Q_IN(Q_IN),
        .Q_DATA(Q_DATA),
        .Q_OUT(Q_OUT),
        .N(N)
    )inst_fft_stage_6(
        .clk(clk),
        .reset(reset),
        .valid_in(valid_out_butter_5_stage_6),
        .data_in_real_0(data_real_0_butter_5_stage_6),
        .data_in_imag_0(data_imag_0_butter_5_stage_6),
        .data_in_real_1(data_real_1_butter_5_stage_6),
        .data_in_imag_1(data_imag_1_butter_5_stage_6),

        .valid_out(valid_out_stage_6_butter_6),
        .data_out_real_0(data_real_0_stage_6_butter_6),
        .data_out_imag_0(data_imag_0_stage_6_butter_6),
        .data_out_real_1(data_real_1_stage_6_butter_6),
        .data_out_imag_1(data_imag_1_stage_6_butter_6),
        .coeff_out_real(coeff_real_stage_6_butter_6),
        .coeff_out_imag(coeff_imag_stage_6_butter_6)
    );


    reg [Q_OUT:0] data_real_0_butter_6_stage_7;
    reg [Q_OUT:0] data_imag_0_butter_6_stage_7;
    reg [Q_OUT:0] data_real_1_butter_6_stage_7;
    reg [Q_OUT:0] data_imag_1_butter_6_stage_7;

    reg valid_out_butter_6_stage_7;


    butterfly_unit  #(
        .Q_IN(Q_IN),
        .Q_DATA(Q_DATA),
        .Q_OUT(Q_OUT)
    )inst_butterfly_unit_6(
        .clk(clk),
        .reset(reset),
        .valid_in(valid_out_stage_6_butter_6),
        .a_real(data_real_0_stage_6_butter_6),
        .a_imag(data_imag_0_stage_6_butter_6),
        .b_real(data_real_1_stage_6_butter_6),
        .b_imag(data_imag_1_stage_6_butter_6),
        .W_real(coeff_real_stage_6_butter_6),
        .W_imag(coeff_imag_stage_6_butter_6),

        .valid_out(valid_out_butter_6_stage_7),
        .y0_real(data_real_0_butter_6_stage_7),
        .y0_imag(data_imag_0_butter_6_stage_7),
        .y1_real(data_real_1_butter_6_stage_7),
        .y1_imag(data_imag_1_butter_6_stage_7)
    );


    reg valid_out_stage_7_butter_7;

    reg [Q_OUT:0] data_real_0_stage_7_butter_7;
    reg [Q_OUT:0] data_imag_0_stage_7_butter_7;
    reg [Q_OUT:0] data_real_1_stage_7_butter_7;
    reg [Q_OUT:0] data_imag_1_stage_7_butter_7;

    reg [Q_OUT:0] coeff_real_stage_7_butter_7;
    reg [Q_OUT:0] coeff_imag_stage_7_butter_7;

    fft_stage_7  #( 
        .Q_IN(Q_IN),
        .Q_DATA(Q_DATA),
        .Q_OUT(Q_OUT),
        .N(N)
    )inst_fft_stage_7(
        .clk(clk),
        .reset(reset),
        .valid_in(valid_out_butter_6_stage_7),
        .data_in_real_0(data_real_0_butter_6_stage_7),
        .data_in_imag_0(data_imag_0_butter_6_stage_7),
        .data_in_real_1(data_real_1_butter_6_stage_7),
        .data_in_imag_1(data_imag_1_butter_6_stage_7),

        .valid_out(valid_out_stage_7_butter_7),
        .data_out_real_0(data_real_0_stage_7_butter_7),
        .data_out_imag_0(data_imag_0_stage_7_butter_7),
        .data_out_real_1(data_real_1_stage_7_butter_7),
        .data_out_imag_1(data_imag_1_stage_7_butter_7),
        .coeff_out_real(coeff_real_stage_7_butter_7),
        .coeff_out_imag(coeff_imag_stage_7_butter_7)
    );

    
    reg [Q_OUT:0] data_real_0_butter_7_stage_8;
    reg [Q_OUT:0] data_imag_0_butter_7_stage_8;
    reg [Q_OUT:0] data_real_1_butter_7_stage_8;
    reg [Q_OUT:0] data_imag_1_butter_7_stage_8;

    reg valid_out_butter_7_stage_8;


    butterfly_unit  #(
        .Q_IN(Q_IN),
        .Q_DATA(Q_DATA),
        .Q_OUT(Q_OUT)
    )inst_butterfly_unit_7(
        .clk(clk),
        .reset(reset),
        .valid_in(valid_out_stage_7_butter_7),
        .a_real(data_real_0_stage_7_butter_7),
        .a_imag(data_imag_0_stage_7_butter_7),
        .b_real(data_real_1_stage_7_butter_7),
        .b_imag(data_imag_1_stage_7_butter_7),
        .W_real(coeff_real_stage_7_butter_7),
        .W_imag(coeff_imag_stage_7_butter_7),

        .valid_out(valid_out_butter_7_stage_8),
        .y0_real(data_real_0_butter_7_stage_8),
        .y0_imag(data_imag_0_butter_7_stage_8),
        .y1_real(data_real_1_butter_7_stage_8),
        .y1_imag(data_imag_1_butter_7_stage_8)
    );


    reg valid_out_stage_8_butter_8;

    reg [Q_OUT:0] data_real_0_stage_8_butter_8;
    reg [Q_OUT:0] data_imag_0_stage_8_butter_8;
    reg [Q_OUT:0] data_real_1_stage_8_butter_8;
    reg [Q_OUT:0] data_imag_1_stage_8_butter_8;

    reg [Q_OUT:0] coeff_real_stage_8_butter_8;
    reg [Q_OUT:0] coeff_imag_stage_8_butter_8;

    fft_stage_8  #( 
        .Q_IN(Q_IN),
        .Q_DATA(Q_DATA),
        .Q_OUT(Q_OUT),
        .N(N)
    )inst_fft_stage_8(
        .clk(clk),
        .reset(reset),
        .valid_in(valid_out_butter_7_stage_8),
        .data_in_real_0(data_real_0_butter_7_stage_8),
        .data_in_imag_0(data_imag_0_butter_7_stage_8),
        .data_in_real_1(data_real_1_butter_7_stage_8),
        .data_in_imag_1(data_imag_1_butter_7_stage_8),

        .valid_out(valid_out_stage_8_butter_8),
        .data_out_real_0(data_real_0_stage_8_butter_8),
        .data_out_imag_0(data_imag_0_stage_8_butter_8),
        .data_out_real_1(data_real_1_stage_8_butter_8),
        .data_out_imag_1(data_imag_1_stage_8_butter_8),
        .coeff_out_real(coeff_real_stage_8_butter_8),
        .coeff_out_imag(coeff_imag_stage_8_butter_8)
    );


    butterfly_unit  #(
        .Q_IN(Q_IN),
        .Q_DATA(Q_DATA),
        .Q_OUT(Q_OUT)
    )inst_butterfly_unit_8(
        .clk(clk),
        .reset(reset),
        .valid_in(valid_out_stage_8_butter_8),
        .a_real(data_real_0_stage_8_butter_8),
        .a_imag(data_imag_0_stage_8_butter_8),
        .b_real(data_real_1_stage_8_butter_8),
        .b_imag(data_imag_1_stage_8_butter_8),
        .W_real(coeff_real_stage_8_butter_8),
        .W_imag(coeff_imag_stage_8_butter_8),

        .valid_out(valid_out),
        .y0_real(data_fft_real_0),
        .y0_imag(data_fft_imag_0),
        .y1_real(data_fft_real_1),
        .y1_imag(data_fft_imag_1)
    );


    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(1, top_fft);
    end

endmodule