`timescale 1ns/1ps

module data_acquisition_top_tb;

    logic       clk;
    logic       rst_n;

    logic       sclk;
    logic       cs_n;
    logic       mosi;

    logic       rd_en;

    logic [7:0] data_out;
    logic       fifo_empty;
    logic       fifo_full;

    logic [7:0] avg_out;
    logic       avg_valid;

    integer pass_count;
    integer fail_count;


    // =========================================
    // Instantiate complete data acquisition system
    // =========================================
    data_acquisition_top dut (
        .clk        (clk),
        .rst_n      (rst_n),

        .sclk       (sclk),
        .cs_n       (cs_n),
        .mosi       (mosi),

        .rd_en      (rd_en),

        .data_out   (data_out),
        .fifo_empty (fifo_empty),
        .fifo_full  (fifo_full),

        .avg_out    (avg_out),
        .avg_valid  (avg_valid)
    );


    // =========================================
    // 100 MHz system clock
    // =========================================
    always #5 clk = ~clk;


    // =========================================
    // Send one SPI byte
    // =========================================
    task send_spi_byte(input logic [7:0] data);
        integer i;

        begin
            cs_n = 0;

            for (i = 7; i >= 0; i = i - 1) begin

                mosi = data[i];

                #10;
                sclk = 1;

                #10;
                sclk = 0;

            end

            #10;
            cs_n = 1;

            #30;
        end
    endtask


    // =========================================
    // Check moving-average result
    // =========================================
    task check_average(input logic [7:0] expected);

        begin

            @(posedge avg_valid);

            // Small delay so avg_out has settled
            #1;

            if (avg_out == expected) begin

                $display(
                    "PASS: Expected %0d, Got %0d",
                    expected,
                    avg_out
                );

                pass_count = pass_count + 1;

            end
            else begin

                $display(
                    "FAIL: Expected %0d, Got %0d",
                    expected,
                    avg_out
                );

                fail_count = fail_count + 1;

            end

        end
    endtask


    // =========================================
    // Main test
    // =========================================
    initial begin

        // Initial values
        clk   = 0;
        rst_n = 0;

        sclk = 0;
        cs_n = 1;
        mosi = 0;

        rd_en = 0;

        pass_count = 0;
        fail_count = 0;


        // Reset
        #20;
        rst_n = 1;

        #30;


        // =====================================
        // First three samples
        // =====================================

        send_spi_byte(8'd10);
        send_spi_byte(8'd20);
        send_spi_byte(8'd30);


        // =====================================
        // Fourth sample
        //
        // Expected:
        // (10 + 20 + 30 + 40) / 4 = 25
        //
        // Checker and SPI transmission run
        // simultaneously.
        // =====================================

        fork

            check_average(8'd25);

            send_spi_byte(8'd40);

        join


        // =====================================
        // Fifth sample
        //
        // Expected:
        // (20 + 30 + 40 + 50) / 4 = 35
        // =====================================

        fork

            check_average(8'd35);

            send_spi_byte(8'd50);

        join


        // =====================================
        // Sixth sample
        //
        // Expected:
        // (30 + 40 + 50 + 60) / 4 = 45
        // =====================================

        fork

            check_average(8'd45);

            send_spi_byte(8'd60);

        join


        // =====================================
        // Final results
        // =====================================

        #50;

        $display("");
        $display("--------------------------------");

        if (fail_count == 0 && pass_count == 3) begin

            $display("ALL TESTS PASSED");
            $display("%0d / 3 tests passed",
                     pass_count);

        end
        else begin

            $display("TEST FAILED");

            $display(
                "%0d passed, %0d failed",
                pass_count,
                fail_count
            );

        end

        $display("--------------------------------");
        $display("");

        #20;

        $stop;

    end

endmodule