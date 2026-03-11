// The following module you see before you receives a clock and
// has a synchronous reset. The reset is active high. 

// Extend the module you have been given to drive out_valid,
// out_trigger, and out_header as described in the challenge
// description. You may add or remove code but please do NOT modify
// the module ports. The testbench provided will tell you when you
// have correctly done this. We are looking for the test to pass
// first and foremost.

// You have the ability to view or download the waveform produced
// by the design. You can also synthesize the design. Be aware
// this can take a few minutes to run.


module top (
    input logic                       clk,
    input logic                       reset,

    input logic                       in_valid,
    input logic [15:0]                in_data,

    output logic                      out_valid,
    output logic                      out_trigger,
    output logic [31:0]               out_header
);

    localparam logic [23:0] MATCH_DATA_1 = 24'hDF0132;
    localparam logic [23:0] MATCH_DATA_2 = 24'h4DE91B;
    localparam logic [23:0] MATCH_DATA_3 = 24'h73AC06;
    localparam logic [23:0] MATCH_DATA_4 = 24'hA1C47D;

    // Your code here
    logic       first_cycle;
    logic [7:0] hdr_latch;
    logic [7:0] pay_upper;
    logic [1:0] msg_idx;
    logic       all_match;
    logic [31:0] hdr_concat;
    
    always_ff @(posedge clk) begin
        logic [23:0]    pay_full;
        logic           msg_match;
        logic [31:0]    hdr_next; 
        if (reset) begin
            first_cycle <= 1'b1;
            hdr_latch  <= 8'd0;
            pay_upper <= 8'd0;
            msg_idx <= 2'd0;
            hdr_concat <= 32'd0;
            all_match <= 1'b1;                      // WHY ?? == usign and chain to determine if all messages match, so start with 1 and if any fail it becomes 0
            out_valid <= 1'b0;
            out_trigger <= 1'b0;
            out_header <= 32'b0;
        end else begin
           out_valid <= 1'b0; 
           out_trigger <= 1'b0;
            
            if (in_valid) begin
                if(first_cycle) begin
                    hdr_latch <= in_data[15:8];
                    pay_upper <= in_data[7:0];
                    first_cycle <= 1'b0;
                end else begin
                    pay_full = {pay_upper, in_data[15:0]};
                    hdr_next = {hdr_latch, hdr_concat[31:8]};
                    hdr_concat <= hdr_next;
                    first_cycle <= 1'b1;
                    
                    case(msg_idx)
                        2'd0: msg_match = (pay_full == MATCH_DATA_1);           // Message match is  blocking assignmnet need it to in the same cycle to determine all match, if we use non blocking it will update in the next cycle and we will be checking the old value of msg_match
                        2'd1: msg_match = (pay_full == MATCH_DATA_2);
                        2'd2: msg_match = (pay_full == MATCH_DATA_3);
                        2'd3: msg_match = (pay_full == MATCH_DATA_4); 
                        default: msg_match = 1'b0;
                    endcase
                    
                    all_match <= (all_match & msg_match); 
                    
                    if(msg_idx == 2'd3) begin
                        out_valid <= 1'b1;
                        out_trigger <= (all_match & msg_match);
                        out_header <= hdr_next;
                        msg_idx <= 2'd0;
                        all_match <= 1'b1;
                        hdr_concat <= 32'd0;
                    end else begin
                        msg_idx <= msg_idx + 2'd1;
                    end
                end 
            end
        end       
    end
endmodule