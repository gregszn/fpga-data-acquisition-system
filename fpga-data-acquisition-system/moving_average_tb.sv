`timescale 1ns/1ps

module moving_average_tb;

    logic       clk;
    logic       rst_n;
    logic [7:0] data_in;
    logic       data_valid;

    logic [7:0] avg_out;
    logic       avg_valid;


    // Instantiate moving average module
    moving_average dut (
        .clk        (clk),
        .rst_n      (rst_n),
        .data_in    (data_in),
        .data_valid (data_valid),
        .avg_out    (avg_out),
        .avg_valid  (avg_valid)
    );


    // 100 MHz clock
    always #5 clk = ~clk;


    // Send one sample
    task send_sample(input logic [7:0] sample);
        begin
            @(negedge clk);
            data_in = sample;
            data_valid = 1'b1;

            @(negedge clk);
            data_valid = 1'b0;
        end
    endtask


    initial begin

        clk        = 0;
        rst_n      = 0;
        data_in    = 0;
        data_valid = 0;

        // Reset
        #20;
        rst_n = 1;

        #20;

        // First four samples
        // Average = (10 + 20 + 30 + 40) / 4 = 25
        send_sample(8'd10);
        send_sample(8'd20);
        send_sample(8'd30);
        send_sample(8'd40);

        #30;

        // New sample replaces oldest (10)
        // Average = (20 + 30 + 40 + 50) / 4 = 35
        send_sample(8'd50);

        #30;

        // New sample replaces oldest (20)
        // Average = (30 + 40 + 50 + 60) / 4 = 45
        send_sample(8'd60);

        #40;

        $stop;

    end

endmodule