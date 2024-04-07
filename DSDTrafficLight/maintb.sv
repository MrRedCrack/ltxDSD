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

initial #8000 $stop;
initial begin
    clk = 0;
    #9.5 forever #0.5 clk = ~clk;
end
initial begin
    sensor = '0;

    $timeformat(0,2,"s",6);
    $monitor(
        "[$monitor] [%7t] A=%-6s B=%-6s C=%-6s D=%-6s",
        $realtime,
        tl_a.name,
        tl_b.name,
        tl_c.name,
        tl_d.name
    );

    arstN  = '1;
    sensor = 4'b0101;
    $display("[Test Condition 1] sensor = 4'b0101 ",
        "(sensor @A,C always detecting car)");
    #1 arstN = '0;
    #1 arstN = '1;
    #748 sensor = 4'b1010;
    $display("[Test Condition 2 Update] [@%7t] sensor = 4'b1010 ",$realtime,
        "(sensor @B,D always detecting car)");
    arstN = '0;
    arstN = '1;
    #748 sensor = 4'b1111;
    $display("[Test Condition 3 Update] [@%7t] sensor = 4'b1111 ",$realtime,
        "(sensor @A,B,C,D always detecting car)");
    arstN = '0;
    arstN  = '1;
    #1496 sensor = 4'b0011;
    $display("[Test Condition 4 Update] sensor = 4'b0011 ",
        "(sensor @A,B detected car)");
    #1 arstN = '0;
    #1 arstN = '1;
    #350 sensor = 4'b0101;
    $display("[Test Condition 5 Update] [@%7t] sensor = 4'b0101 ",$realtime,
        "(sensor @B no car detected after 5s, turns to sensor @C)");
    arstN = '0;
    arstN = '1;
    #60 sensor = 4'b1001;
    $display("[Test Condition 6 Update] [@%7t] sensor = 4'b1001 ",$realtime,
        "(sensor @C no car detected after 5s, turns to sensor @D)");
    arstN = '0;
    arstN  = '1;
    #1000 sensor = 4'b1101;
    $display("[Test Condition 7 Update] sensor = 4'b1101 ",
        "(sensor @A,C,D always detecting car)");
    #1 arstN = '0;
    #1 arstN = '1;
    #1050 sensor = 4'b0000;
    $display("[Test Condition 8 Update] [@%7t] sensor = 4'b0000 ",$realtime,
        "(sensor @A,C,D no car detected, so green light stuck at sensor @D)");

end

endmodule: main_tb
    `end_keywords

