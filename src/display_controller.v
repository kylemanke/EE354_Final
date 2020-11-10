`timescale 1ns / 1ps

module display_controller (
        input clk,
        output hSync, vSync,
        output reg bright,
        output reg [9:0] hCount,
        output reg [9:0] vCount
    );
    
    always @(posedge clk)
    begin 
        if (hCount < 10'd799)
            hCount <= hCount + 1;
        else if (vCount < 10'd524)
            begin
                hCount <= 0;
                vCount <= vCount + 1;
            end
        else
            begin
               hCount <= 0;
               vCount <= 0; 
            end
    end

    assign hSync = (hCount < 96) ? 0:1;
    assign vSync = (vCount < 2) ? 0:1;

    always @(posedge clk)
	begin
		if(hCount > 10'd143 && hCount < 10'd784 && vCount > 10'd34 && vCount < 10'd516)
			bright <= 1;
		else
			bright <= 0;
	end	

endmodule
