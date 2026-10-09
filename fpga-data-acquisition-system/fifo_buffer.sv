module fifo_buffer (
    input  logic       clk,
    input  logic       rst_n,

    input  logic       wr_en,
    input  logic [7:0] data_in,

    input  logic       rd_en,
    output logic [7:0] data_out,

    output logic       full,
    output logic       empty
);

    logic [7:0] memory [0:15];

    logic [3:0] write_ptr;
    logic [3:0] read_ptr;

    logic [4:0] count;

    assign empty = (count == 5'd0);
    assign full  = (count == 5'd16);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            write_ptr <= 4'd0;
            read_ptr  <= 4'd0;
            count     <= 5'd0;
            data_out  <= 8'd0;
        end
        else begin

            // Write data into FIFO
            if (wr_en && !full) begin
                memory[write_ptr] <= data_in;
                write_ptr <= write_ptr + 1'b1;
            end

            // Read data from FIFO
            if (rd_en && !empty) begin
                data_out <= memory[read_ptr];
                read_ptr <= read_ptr + 1'b1;
            end

            // Update number of stored bytes
            case ({wr_en && !full, rd_en && !empty})
                2'b10: count <= count + 1'b1;
                2'b01: count <= count - 1'b1;
                default: count <= count;
            endcase

        end
    end

endmodule 