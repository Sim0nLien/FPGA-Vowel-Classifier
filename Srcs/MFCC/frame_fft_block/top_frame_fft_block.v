module top_frame_fft_block#(
    parameter Q_IN = 15,
    parameter Q_DATA = 15,
    parameter Q_OUT = 15,
    parameter N = 256
)(
    input wire clk,
    input wire reset,    
    input wire  valid_in,
    input wire  signed [Q_OUT:0] data_in,
    
    output reg valid_out,
    output reg signed [Q_OUT:0] data_fft_real_0,
    output reg signed [Q_OUT:0] data_fft_imag_0,
    output reg signed [Q_OUT:0] data_fft_real_1,
    output reg signed [Q_OUT:0] data_fft_imag_1
);


    reg valid_packet_window;
    reg valid_out_mem_window;

    reg valid_window_mem;

    reg [Q_IN:0] data_mem_window;

    mem #(
        .Q_DATA(Q_DATA),
        .N(128)
    )inst_mem(
        .clk(clk),
        .reset(reset),
        .valid_lowpass(valid_in),
        .valid_window(valid_window_mem),
        .data_lowpass(data_in),
        .paquet_ready(valid_packet_window),
        .valid_out(valid_out_mem_window),
        .data_out(data_mem_window)
    );

    reg valid_out_window_mem_1;

    reg [Q_IN:0] data_window_mem_1_0;
    reg [Q_IN:0] data_window_mem_1_1;

    window #(
    .Q_IN(Q_IN),
    .Q_COEFF(Q_DATA), 
    .Q_OUT(Q_OUT),
    .N(128)
    )inst_window(
    .clk(clk),
    .reset(reset),
    .valid_in(valid_out_mem_window),
    .valid_packet(valid_packet_window),
    .data_in(data_mem_window),
    .valid_request(valid_window_mem),
    .valid_out(valid_out_window_mem_1),
    .data_out_0(data_window_mem_1_0),
    .data_out_1(data_window_mem_1_1)
    );

    reg valid_out_mem_1_top_fft;
    reg valid_request_fft_mem_1;

    reg paquet_ready_mem_1_top_fft;

    reg [8:0] addr_fft_mem_1;

    reg [Q_IN:0] data_mem_1_top_fft;
    

    mem_1 #(
        .Q_DATA(Q_DATA),
        .N(128)
    )inst_mem_1(
        .clk(clk),
        .reset(reset),
        .valid_window(valid_out_window_mem_1),
        .valid_fft(valid_request_fft_mem_1),
        .addr_in(addr_fft_mem_1),
        .data_in_0(data_window_mem_1_0),
        .data_in_1(data_window_mem_1_1),
        .paquet_ready(paquet_ready_mem_1_top_fft),
        .valid_out(valid_out_mem_1_top_fft),
        .data_out(data_mem_1_top_fft)
    );


    top_fft #(
        .Q_IN(Q_IN),
        .Q_DATA(Q_DATA),
        .Q_OUT(Q_OUT),
        .N(N)
    )inst_top_fft(
        .clk(clk),
        .reset(reset),
        .valid_in(valid_out_mem_1_top_fft),
        .valid_packet(paquet_ready_mem_1_top_fft),
        .data_in(data_mem_1_top_fft),
        
        .valid_request(valid_request_fft_mem_1),
        .valid_out(valid_out),
        .addr_out(addr_fft_mem_1),
        .data_fft_real_0(data_fft_real_0),
        .data_fft_imag_0(data_fft_imag_0),
        .data_fft_real_1(data_fft_real_1),
        .data_fft_imag_1(data_fft_imag_1)
    );


    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(1, top_frame_fft_block);
    end

endmodule