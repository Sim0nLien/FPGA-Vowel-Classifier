module window #(
    parameter Q_DATA = 15,
    parameter N      = 256
)(
    input  wire clk,
    input  wire reset,
    input  wire valid_lowpass,
    input  wire valid_window,
    input  wire signed [Q_DATA:0] data_lowpass,
    output reg  paquet_ready,
    output reg  valid_out,
    output reg  signed [Q_DATA:0] data_out
);

    reg signed [Q_DATA:0] memory_0 [0:N-1];
    reg signed [Q_DATA:0] memory_1 [0:N-1];

    reg flag_in;
    reg flag_out;
    reg [$clog2(N)-1:0] counter_in;
    reg [$clog2(N)-1:0] counter_out;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            flag_in      <= 1'b0;
            flag_out     <= 1'b0;
            counter_in   <= 0;
            counter_out  <= 0;
            valid_out    <= 1'b0;
            paquet_ready <= 1'b0;
            data_out     <= 0;
        end 
        else begin
            paquet_ready <= 1'b0;
            valid_out    <= 1'b0;

            if (valid_lowpass) begin
                if (flag_in == 1'b0)
                    memory_0[counter_in] <= data_lowpass;
                else
                    memory_1[counter_in] <= data_lowpass;

                if (counter_in == N-1) begin
                    counter_in   <= 0;
                    flag_in      <= ~flag_in;
                    paquet_ready <= 1'b1;
                end 
                else begin
                    counter_in <= counter_in + 1;
                end
            end

            if (valid_window) begin
                valid_out <= 1'b1;

                if (flag_out == 1'b0)
                    data_out <= memory_0[counter_out];
                else
                    data_out <= memory_1[counter_out];

                if (counter_out == N-1) begin
                    counter_out <= 0;
                    flag_out    <= ~flag_out;
                end 
                else begin
                    counter_out <= counter_out + 1;
                end
            end
        end
    end

endmodule
