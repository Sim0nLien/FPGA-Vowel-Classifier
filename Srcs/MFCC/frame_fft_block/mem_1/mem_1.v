module mem_1 #(
    parameter Q_DATA = 15,
    parameter N      = 256
)(
    input  wire clk,
    input  wire reset,
    input  wire valid_window,
    input  wire valid_fft,
    input  wire signed [Q_DATA:0] data_in_0,
    input  wire signed [Q_DATA:0] data_in_1,
    output reg  paquet_ready,
    output reg  valid_out,
    output reg  signed [Q_DATA:0] data_out
);

    reg signed [Q_DATA:0] memory_0 [0:N*2-1];
    reg signed [Q_DATA:0] memory_1 [0:N*2-1];
    reg signed [Q_DATA:0] memory_2 [0:N*2-1];

    reg [$clog2(N)-1:0] counter_in;
    reg [$clog2(N)-1:0] counter_out;
    reg [1:0] counter_mem_in;
    reg [1:0] counter_mem_out;

    always @(posedge clk) begin
        if (reset) begin
            counter_in <= 0;
            counter_out <= 0;
            counter_mem_in <= 0;
            counter_mem_out <= 0;
            paquet_ready <= 1'b0;
            valid_out <= 1'b0;
            data_out <= '0;
        end
        else begin
            paquet_ready <= 1'b0;
            valid_out <= 1'b0;

            if (valid_window) begin
                case (counter_mem_in)
                    2'b00: begin
                        memory_0[counter_in + N] <= data_in_0;
                        memory_1[counter_in]     <= data_in_1;
                        counter_in <= counter_in + 1;
                    end
                    2'b01: begin 
                        memory_1[counter_in + N] <= data_in_0;
                        memory_2[counter_in]     <= data_in_1;
                        counter_in <= counter_in + 1;
                    end   
                    2'b10: begin 
                        memory_2[counter_in + N] <= data_in_0;
                        memory_0[counter_in]     <= data_in_1;
                        counter_in <= counter_in + 1;
                    end
                endcase

                if (counter_in == N - 1) begin
                    counter_in <= 0;
                    counter_mem_in <= counter_mem_in + 1;
                    paquet_ready <= 1'b1;
                    if (counter_mem_in == 2'b10) begin
                        counter_mem_in <= 0;
                    end
                end
            end

            if (valid_fft) begin
                case (counter_mem_out)
                    2'b00: begin
                        data_out <= memory_0[counter_out];
                        valid_out <= 1'b1;
                    end
                    2'b01: begin
                        data_out <= memory_1[counter_out];
                        valid_out <= 1'b1;
                    end
                    2'b10: begin
                        data_out <= memory_2[counter_out];
                        valid_out <= 1'b1;
                    end
                endcase
                
                valid_out <= 1'b1;

                if (counter_out == N - 1) begin
                    counter_out <= 0;
                    counter_mem_out <= counter_mem_out + 1;
                    if (counter_mem_out == 2'b10) begin
                        counter_mem_out <= 0;
                    end
                end
                else begin
                    counter_out <= counter_out + 1;
                end
            end
            else begin
                valid_out <= 1'b0;
            end
        end
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(1, mem_1);
    end
endmodule
