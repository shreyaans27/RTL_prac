module top_module (
    input clk,
    input reset,
    input [31:0] in,
    output [31:0] out
);
    
    reg [31:0] prev; 
    always @(posedge clk) begin: edgecapture
        
        prev <= in;
        
        if(reset) begin
           out <= 32'b0; 
        end
        else begin
            out <= out | (prev & ~in);
        end
    end
endmodule