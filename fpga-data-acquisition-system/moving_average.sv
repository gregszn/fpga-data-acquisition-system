module moving_average (
    input  logic       clk,
    input  logic       rst_n,

    input  logic       data_valid,
    input  logic [7:0] data_in,

    output logic       avg_valid,
    output logic [7:0] avg_out
);

    // Store the four most recent samples
    logic [7:0] sample0;
    logic [7:0] sample1;
    logic [7:0] sample2;
    logic [7:0] sample3;

    // 10 bits are needed because four 8-bit
    // values can add up to 1020
    logic [9:0] sum;

    // Number of samples received so far
    logic [2:0] sample_count;


    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin
            sample0      <= 8'b0;
            sample1      <= 8'b0;
            sample2      <= 8'b0;
            sample3      <= 8'b0;

            sum           <= 10'b0;
            sample_count  <= 3'b0;

            avg_out       <= 8'b0;
            avg_valid     <= 1'b0;
        end

        else begin

            // Normally no new average
            avg_valid <= 1'b0;

            if (data_valid) begin

                // Shift samples
                sample3 <= sample2;
                sample2 <= sample1;
                sample1 <= sample0;
                sample0 <= data_in;

                // Wait until we have received 4 samples
                if (sample_count < 3) begin

                    sum <= sum + data_in;
                    sample_count <= sample_count + 1'b1;

                end

                else if (sample_count == 3) begin

                    // Fourth sample creates first average
                    sum <= sum + data_in;

                    avg_out <=
                        (sum + data_in) >> 2;

                    avg_valid <= 1'b1;

                    sample_count <= 3'd4;

                end

                else begin

                    // Remove oldest sample and add newest
                    sum <= sum - sample3 + data_in;

                    avg_out <=
                        (sum - sample3 + data_in) >> 2;

                    avg_valid <= 1'b1;

                end

            end

        end

    end

endmodule