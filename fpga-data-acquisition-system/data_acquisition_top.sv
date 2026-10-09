module data_acquisition_top (
    input  logic       clk,
    input  logic       rst_n,

    // SPI interface
    input  logic       sclk,
    input  logic       cs_n,
    input  logic       mosi,

    // FIFO read interface
    input  logic       rd_en,

    // Raw FIFO output
    output logic [7:0] data_out,
    output logic       fifo_empty,
    output logic       fifo_full,

    // Moving average output
    output logic [7:0] avg_out,
    output logic       avg_valid
);

    // --------------------------------
    // SPI receiver signals
    // --------------------------------
    logic [7:0] spi_data;
    logic       spi_data_valid;


    // --------------------------------
    // Clock-domain crossing signals
    // --------------------------------
    logic       spi_toggle;
    logic [7:0] spi_data_hold;

    logic       sync_ff1;
    logic       sync_ff2;
    logic       sync_ff2_d;

    logic       fifo_wr_en;


    // =================================
    // SPI Receiver
    // =================================
    spi_rx u_spi_rx (
        .rst_n      (rst_n),
        .sclk       (sclk),
        .cs_n       (cs_n),
        .mosi       (mosi),
        .data_out   (spi_data),
        .data_valid (spi_data_valid)
    );


    // =================================
    // SPI Clock Domain
    // Capture completed SPI byte
    // =================================
    always_ff @(negedge sclk or negedge rst_n) begin

        if (!rst_n) begin
            spi_toggle    <= 1'b0;
            spi_data_hold <= 8'b0;
        end

        else if (spi_data_valid) begin
            spi_toggle    <= ~spi_toggle;
            spi_data_hold <= spi_data;
        end

    end


    // =================================
    // Clock Domain Crossing
    // =================================
    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin
            sync_ff1   <= 1'b0;
            sync_ff2   <= 1'b0;
            sync_ff2_d <= 1'b0;
        end

        else begin
            sync_ff1   <= spi_toggle;
            sync_ff2   <= sync_ff1;
            sync_ff2_d <= sync_ff2;
        end

    end


    // =================================
    // Generate one-clock FIFO write pulse
    // =================================
    assign fifo_wr_en = sync_ff2 ^ sync_ff2_d;


    // =================================
    // FIFO Buffer
    // =================================
    fifo_buffer u_fifo (
        .clk      (clk),
        .rst_n    (rst_n),

        .wr_en    (fifo_wr_en),
        .data_in  (spi_data_hold),

        .rd_en    (rd_en),
        .data_out (data_out),

        .full     (fifo_full),
        .empty    (fifo_empty)
    );


    // =================================
    // Moving Average Filter
    //
    // Each valid SPI sample is sent
    // directly into the filter after
    // crossing into the CLK domain.
    // =================================
    moving_average u_moving_average (
        .clk        (clk),
        .rst_n      (rst_n),
        .data_in    (spi_data_hold),
        .data_valid (fifo_wr_en),
        .avg_out    (avg_out),
        .avg_valid  (avg_valid)
    );


endmodule