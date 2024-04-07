`begin_keywords "1800-2017"
`include "counter.sv"
`include "ur_detector.sv"

module tl_fsm #(parameter
    logic [15:0] G_SCALE_P = '0,
    logic [15:0] G_SCALE_S = '0,
    logic [15:0] Y_SCALE  = '0,
    logic [15:0] R_SCALE  = '0
) (
    input  logic       clk, arstN,
    input  logic [3:0] sensor,
    output logic [2:0] tl_signal,
    output logic [1:0] index
);
timeunit 100ms;
timeprecision 1ms;
logic        index_inc, p_timeout, s_timeout, init_counter_gp, init_counter_gs;
logic [ 1:0] counter_set, inc_offset;
logic [ 3:0] ur_list        ;
logic [15:0] counter_load[2];
typedef enum logic [1:0] {INIT, G, Y, R} tl_states_t;
tl_states_t current_state, next_state;

counter counter_p (
    // instantiate primary counter
    .arstN                       ,
    .clk                         ,
    .counter_set(counter_set[0] ),
    .load       (counter_load[0]),
    .flag_0     (p_timeout      )
);

counter counter_s (
    // instantiate secondary counter
    .arstN                       ,
    .clk                         ,
    .counter_set(counter_set[1] ),
    .load       (counter_load[1]),
    .flag_0     (s_timeout      )
);

ur_detector counters_ur (
    .arstN,
    .clk,
    .sensor,
    .ur_list
);

always_comb begin // update index increment offset to skip unused road(s)
    inc_offset = '0;
    for (logic [1:0] i = index + 1'b1, j = '0;
        (j < 3) && (ur_list[i] != '0);
        i++, j++) inc_offset++;
end

always_ff @(posedge clk or negedge arstN) begin // index counter
    if (!arstN) index <= '0;
    else if (inc_offset >= 2'h3); // do not update index
    else if (index_inc) index <= index + 1'b1 + inc_offset;
end

always_ff @(posedge clk or negedge arstN) begin // state machine
    if (!arstN) current_state <= INIT;
    else current_state <= next_state;
end

always_comb begin // state logic
    {
        index_inc,
        init_counter_gp,
        init_counter_gs,
        counter_set
    }   = '0;
    counter_load = '{'0,'0};
    case (current_state)
        INIT : begin
            {
                init_counter_gp,
                init_counter_gs
            } = '1;
            next_state = G;
        end
        G : begin
            next_state = G;
            if (sensor[index]) init_counter_gs = '1;
            if ((p_timeout || (s_timeout && !sensor[index])) &&
                (inc_offset <= 2'h2)) begin
                counter_load[0] = Y_SCALE;
                counter_set[0]  = '1;
                next_state      = Y;
            end
        end
        Y : begin
            next_state = Y;
            if (p_timeout) begin
                counter_load[0] = R_SCALE;
                counter_set[0]  = '1;
                next_state      = R;
            end
        end
        R : begin
            next_state = R;
            if (p_timeout) begin
                {
                    init_counter_gp,
                    init_counter_gs
                } = '1;
                index_inc  = '1;
                next_state = G;
            end
        end
        default : next_state = INIT;
    endcase
    if (init_counter_gp) begin
        counter_load[0] = G_SCALE_P;
        counter_set[0]  = '1;
    end
    if(init_counter_gs) begin
        counter_load[1] = G_SCALE_S;
        counter_set[1]  = '1;
    end
end

always_comb begin
    tl_signal = '0; // default to '0
    case(current_state)
        G       : tl_signal = 3'b001;
        Y       : tl_signal = 3'b010;
        R       : tl_signal = 3'b100;
        default : ; // all remain '0
    endcase
end

endmodule: tl_fsm
    `end_keywords
