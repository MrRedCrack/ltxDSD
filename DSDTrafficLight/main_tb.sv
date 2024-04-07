`begin_keywords "1800-2017"
`include "main.sv"

module main_tb ();
timeunit 100ms;
timeprecision 1ms;
logic       clk, arstN;
logic [3:0] sensor;
logic [2:0] a, b, c, d;
typedef enum logic [2:0] { // LUT definition
    ALLOFF = 3'b000,
    G      = 3'b001,
    Y      = 3'b010,
    R      = 3'b100
} tl_state_t;
tl_state_t tl_a, tl_b, tl_c, tl_d;

main dut (
    // instantiate main module
    .clk                      ,
    .arstN                    ,
    .sensor                   ,
    .tl_sig_arr('{a, b, c, d})
);

always_comb begin // LUT typecast for testbench display
    tl_a = tl_state_t'(a);
    tl_b = tl_state_t'(b);
    tl_c = tl_state_t'(c);
    tl_d = tl_state_t'(d);
end

initial #1500 $stop;
initial begin
    clk = 0;
    #9.5 forever #0.5 clk = ~clk;
end
initial begin
    sensor = '0;
    $display( // display specs list
        "[DUT Specification]\n",
        "4 Lanes/TL -- A, B, C, D\n",
        "G phase -- 30s, skip @ next clk when sensor active for at least 5s\n",
        "Y phase -- 3s\n",
        "R(All-Red) phase -- 3s\n",
        "===================================================================="
    );

    $timeformat(0,2,"s",6);
    $monitor(
        "[$monitor] [%7t] A=%-6s B=%-6s C=%-6s D=%-6s",
        $realtime,
        tl_a.name,
        tl_b.name,
        tl_c.name,
        tl_d.name
    );

    // test condition 1
    arstN  = '1;
    sensor[2] = '1;
    $display("[Test Condition] sensor = 4'b0100 (sensor @C always detecting car)");
    #1 arstN = '0;
    #1 arstN = '1;
    #748 sensor = 4'b0110;
    $display(
        "[Test Condition Update] [@%7t] sensor = 4'b0110 (sensor @B,C always detecting car)",
        $realtime);
end

endmodule: main_tb
    `end_keywords
