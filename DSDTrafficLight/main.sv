`begin_keywords "1800-2017"
`include "tl_fsm.sv"

module main (
    input  logic       clk, arstN,
    input  logic [3:0] sensor    ,
    output logic [2:0] tl_sig_arr[4]
);
timeunit 100ms;
timeprecision 1ms;
logic [2:0] tl_signal;
logic [1:0] index    ;

tl_fsm #(
    // instantiate state machine
    .G_SCALE_P(16'd299),
    .G_SCALE_S(16'd49 ),
    .Y_SCALE  (16'd29 ),
    .R_SCALE  (16'd29 )
) ctrl (.clk,.arstN,.sensor,.tl_signal,.index);

always_comb begin // interpret state machine outputs and output to tl_sig_arr
    for (int i = 0; i < 4; i++) tl_sig_arr[i] = '0; // default to '0
    if (|tl_signal) begin // detect light signal available
        for (int i = 0; i < 4; i++) begin
            tl_sig_arr[i] = 3'b100; // default to red
            if (i[1:0] == index) tl_sig_arr[i] = tl_signal;
        end
    end
end
endmodule: main
    `end_keywords
