`timescale 1ns/1ps

module fifo_buffer_tb;

    logic       clk;
    logic       rst_n;
    logic       wr_en;
    logic [7:0] data_in;
    logic       rd_en;

    logic [7:0] data_out;
    logic       full;
    logic       empty;

    // Instantiate FIFO
    fifo_buffer dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .wr_en    (wr_en),
        .data_in  (data_in),
        .rd_en    (rd_en),
        .data_out (data_out),
        .full     (full),
        .empty    (empty)
    );

    // Generate clock
    always #5 clk = ~clk;

    initial begin

        // Initial values
        clk     = 0;
        rst_n   = 0;
        wr_en   = 0;
        rd_en   = 0;
        data_in = 8'h00;

        // Reset
        #20;
        rst_n = 1;

        // -------------------------
        // WRITE A5
        // -------------------------
        #10;
        data_in = 8'hA5;
        wr_en   = 1;

        #10;
        wr_en = 0;

        // -------------------------
        // WRITE 37
        // -------------------------
        #10;
        data_in = 8'h37;
        wr_en   = 1;

        #10;
        wr_en = 0;

        // -------------------------
        // WRITE 92
        // -------------------------
        #10;
        data_in = 8'h92;
        wr_en   = 1;

        #10;
        wr_en = 0;

        // Wait
        #20;

        // -------------------------
        // READ FIRST BYTE
        // -------------------------
        rd_en = 1;

        #10;
        rd_en = 0;

        #10;

        // -------------------------
        // READ SECOND BYTE
        // -------------------------
        rd_en = 1;

        #10;
        rd_en = 0;

        #10;

        // -------------------------
        // READ THIRD BYTE
        // -------------------------
        rd_en = 1;

        #10;
        rd_en = 0;

        #20;

        $stop;

    end

endmodule