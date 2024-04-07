`begin_keywords "1800-2017"
`include "counter.sv"

module ur_detector (
    input logic clk, arstN,
    input logic [3:0] sensor,
    output logic [3:0] ur_list
);
timeunit 100ms;
timeprecision 1ms;

counter a_underuse (
    .clk                    ,
    .arstN                  ,
    .counter_set(sensor[0] ),
    .load       (16'd299   ),
    .flag_0     (ur_list[0])
);
counter b_underuse (
    .clk                    ,
    .arstN                  ,
    .counter_set(sensor[1] ),
    .load       (16'd299   ),
    .flag_0     (ur_list[1])
);
counter c_underuse (
    .clk                    ,
    .arstN                  ,
    .counter_set(sensor[2] ),
    .load       (16'd299   ),
    .flag_0     (ur_list[2])
);
counter d_underuse (
    .clk                    ,
    .arstN                  ,
    .counter_set(sensor[3] ),
    .load       (16'd299   ),
    .flag_0     (ur_list[3])
);

endmodule: ur_detector
    `end_keywords
