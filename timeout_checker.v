`include "parameters.vh"

module timeout_checker(
    input           sys_clk,
    input           rst_n,
    input           transfer_TAP_AHB,
    input           done_AHB_TAP,
    input           transfer_TAP_APB,
    input           done_APB_TAP,
    output  wire    timeout
);

    //wire            transfer_start;
    //wire            transfer_stop;
    wire            timeout_flag;
    wire    [9:0]   counter_p;
    wire            counter_enable_p;
    wire            counter_stop_p;

    reg             timeout_flag_reg;
    reg             counter_enable;
    reg     [9:0]   counter;

    assign counter_enable_p = transfer_TAP_AHB | transfer_TAP_APB | (~(done_AHB_TAP | done_APB_TAP) & (~timeout_flag) & counter_enable);
    assign counter_p        = (!timeout_flag && counter_enable) ? (counter + 1'b1) : 10'd0;


    assign timeout_flag     = (counter > `TIMEOUT_VALUE);
    assign timeout          = timeout_flag_reg;

    always @(posedge sys_clk or negedge rst_n) begin
        if (!rst_n) begin
            counter_enable <= 1'b0;
        end
        else begin
            counter_enable <= counter_enable_p;
        end
    end

    always @(posedge sys_clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 10'd0;
        end
        else begin
            counter <= counter_p;
        end
    end

    always @(posedge sys_clk or negedge rst_n) begin
        if (!rst_n)
            timeout_flag_reg <= 1'b0;
        else
            timeout_flag_reg <= timeout_flag;
    end

endmodule

