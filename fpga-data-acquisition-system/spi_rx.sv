module spi_rx (
    input  logic       rst_n,
    input  logic       sclk,
    input  logic       cs_n,
    input  logic       mosi,

    output logic [7:0] data_out,
    output logic       data_valid
);

    logic [7:0] shift_reg;
    logic [2:0] bit_count;

    always_ff @(posedge sclk or negedge rst_n) begin

        if (!rst_n) begin
            shift_reg  <= 8'b0;
            bit_count  <= 3'b0;
            data_out   <= 8'b0;
            data_valid <= 1'b0;
        end

        else if (!cs_n) begin

            data_valid <= 1'b0;

            // Shift incoming MOSI bit into register
            shift_reg <= {shift_reg[6:0], mosi};

            // After 8 bits, output completed byte
            if (bit_count == 3'd7) begin
                data_out   <= {shift_reg[6:0], mosi};
                data_valid <= 1'b1;
                bit_count  <= 3'd0;
            end
            else begin
                bit_count <= bit_count + 1'b1;
            end

        end

        else begin
            bit_count  <= 3'd0;
            data_valid <= 1'b0;
        end

    end

endmodule