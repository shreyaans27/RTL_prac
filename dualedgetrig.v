module top_module (
    input clk,
    input d,
    output q
);

    reg n,p;
    
    always @(posedge clk ) begin: dualtrig1
		p <= d;
    end
    
    always @(negedge clk ) begin: dualtrig2
		n <= d;
    end

	assign q = clk ? p : n;
endmodule
