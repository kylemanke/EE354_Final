`timescale 1ns / 1ps

module maze_top(
        input ClkPort,
        // For VGAs
        output hSync, vSync,
        output [3:0] vgaR, vgaG, vgaB,
        // Book Keeping
        output MemOE, MemWR, RamCS, QuadSpiFlashCS,
        // For movement
        input BtnC, BtnL, BtnR, BtnD, BtnU,
        // SSDs
        output Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp,
        output An0, An1, An2, An3, An4, An5, An6, An7
    );

    //Button Assigns
    wire Reset;
    assign Reset = BtnC;

    //VGA Declarations
    wire bright;
    wire [9:0] hc, vc; // denotes the location of the VGA
    wire [11:0] rgb; // denotes the pixel color

    //VGA Assigns
    assign vgaR = rgb[11:8];
    assign vgaG = rgb[7:4];
    assign vgaB = rgb[3:0];

    // For the Score
    wire [3:0] score;

    //SSD Declarations
    reg [3:0] SSD;
    wire [3:0] SSD3, SSD2, SSD1, SSD0;
    reg [7:0] SSD_CATHODES;
    wire [1:0] ssdscan_clk;

    //disable memory ports
    assign {MemOE, MemWR, RamCS, QuadSpiFlashCS} = 4'b1111;

    // Create Div Clock
    reg [27:0] DIV_CLK;
    always @(posedge ClkPort, posedge Reset)
    begin : CLOCK_DIVIDER
        if (Reset)
            DIV_CLK <= 0;
        else
            DIV_CLK <= DIV_CLK + 1'b1;
    end

    wire move_clk;
	assign move_clk=DIV_CLK[19];

    //create clk25
    reg pulse;
    reg clk25;

    always @(posedge ClkPort)
        pulse = ~pulse;
    always @(posedge pulse)
        clk25 = ~clk25;

    //Instantiate modules
    display_controller dc(.clk(clk25), .hSync(hSync), .vSync(vSync), .bright(bright), .hCount(hc), .vCount(vc));
    maze_controller mc(.clk(clk25), .move_clk(move_clk), .bright(bright), .hCount(hc), .vCount(vc), .rgb(rgb), .Right(BtnR), .Left(BtnL), .Reset(Reset), .Up(BtnU), .Down(BtnD), .score(score));

    //itialize
    initial begin
        clk25 = 0;
        pulse = 0;    
    end

    // SSD Leg Work
    assign SSD3 = 4'b0000;
    assign SSD2 = 4'b0000;
    assign SSD1 = 4'b0000;
    assign SSD0 = score;
    assign {Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp} = {SSD_CATHODES};

    assign ssdscan_clk = DIV_CLK[19:18];
    assign An0	= !(~(ssdscan_clk[1]) && ~(ssdscan_clk[0]));  
	assign An1	= !(~(ssdscan_clk[1]) &&  (ssdscan_clk[0]));  
	assign An2	=  !((ssdscan_clk[1]) && ~(ssdscan_clk[0])); 
	assign An3	=  !((ssdscan_clk[1]) &&  (ssdscan_clk[0])); 
    assign {An7, An6, An5, An4} = 4'b1111; 

    always @(ssdscan_clk, SSD0, SSD1, SSD2, SSD3)
    begin : SSD_SCAN_OUT
        case (ssdscan_clk)
            2'b00: SSD = SSD0;
            2'b01: SSD = SSD1;
            2'b10: SSD = SSD2;
            2'b11: SSD = SSD3;
        endcase
    end

    always @(SSD)
    begin: HEX_2_SSD
        case (SSD)
            4'b0000: SSD_CATHODES = 8'b00000011; // 0
			4'b0001: SSD_CATHODES = 8'b10011111; // 1
			4'b0010: SSD_CATHODES = 8'b00100101; // 2
			4'b0011: SSD_CATHODES = 8'b00001101; // 3
			4'b0100: SSD_CATHODES = 8'b10011001; // 4
			4'b0101: SSD_CATHODES = 8'b01001001; // 5
			4'b0110: SSD_CATHODES = 8'b01000001; // 6
			4'b0111: SSD_CATHODES = 8'b00011111; // 7
			4'b1000: SSD_CATHODES = 8'b00000001; // 8
			4'b1001: SSD_CATHODES = 8'b00001001; // 9
			4'b1010: SSD_CATHODES = 8'b00010001; // A
			4'b1011: SSD_CATHODES = 8'b11000001; // B
			4'b1100: SSD_CATHODES = 8'b01100011; // C
			4'b1101: SSD_CATHODES = 8'b10000101; // D
			4'b1110: SSD_CATHODES = 8'b01100001; // E
			4'b1111: SSD_CATHODES = 8'b01110001; // F
        endcase
    end 

endmodule

