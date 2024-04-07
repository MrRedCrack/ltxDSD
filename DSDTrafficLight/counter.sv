`ifndef COUNTER_M // include only once
`define COUNTER_M

`begin_keywords "1800-2017"

module counter (
    input  logic       arstN, clk, counter_set,
    input  logic [15:0] load,
    output logic       flag_0
);
timeunit 100ms;
timeprecision 1ms;
logic [15:0] current_count;

always_ff @(posedge clk or negedge arstN) begin
    if (!arstN) begin // reset
        current_count <= 0;
    end else if (counter_set) begin  // counter load from input
        current_count <= load;
    end else if (current_count != '0) begin // countdown until 0
        current_count <= current_count - 16'd1;
    end
end

always_comb begin
    flag_0 = ~|current_count; // current_count == '0
end
endmodule: counter
    `end_keywords
`endif
