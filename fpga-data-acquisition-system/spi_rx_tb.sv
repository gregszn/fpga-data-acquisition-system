`timescale 1ns/1ps

module spi_rx_tb;

    // Testbench signals
    logic rst_n;
    logic sclk;
    logic cs_n;
    logic mosi;

    logic [7:0] data_out;
    logic data_valid;


    // Instantiate the SPI receiver
    // DUT = Device Under Test
    spi_rx dut (
        .rst_n      (rst_n),
        .sclk       (sclk),
        .cs_n       (cs_n),
        .mosi       (mosi),
        .data_out   (data_out),
        .data_valid (data_valid)
    );


    // Test sequence
    initial begin

        // Initial conditions
        rst_n = 0;
        sclk  = 0;
        cs_n  = 1;
        mosi  = 0;

        // Hold reset for 20 ns
        #20;
        rst_n = 1;

        // Wait 20 ns
        #20;

        // Start SPI transaction
        cs_n = 0;


        // Send 0xA5 = 1010 0101

        // Bit 7 = 1
        mosi = 1;
        #10 sclk = 1;
        #10 sclk = 0;

        // Bit 6 = 0
        mosi = 0;
        #10 sclk = 1;
        #10 sclk = 0;

        // Bit 5 = 1
        mosi = 1;
        #10 sclk = 1;
        #10 sclk = 0;

        // Bit 4 = 0
        mosi = 0;
        #10 sclk = 1;
        #10 sclk = 0;

        // Bit 3 = 0
        mosi = 0;
        #10 sclk = 1;
        #10 sclk = 0;

        // Bit 2 = 1
        mosi = 1;
        #10 sclk = 1;
        #10 sclk = 0;

        // Bit 1 = 0
        mosi = 0;
        #10 sclk = 1;
        #10 sclk = 0;

        // Bit 0 = 1
        mosi = 1;
        #10 sclk = 1;
        #10 sclk = 0;


        // End SPI transaction
        cs_n = 1;

        // Give simulation some time
        #20;

        // Stop simulation
        $stop;

    end

endmodule