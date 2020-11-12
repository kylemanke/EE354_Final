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
        output An0
    );

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

    //disable memory ports
    assign {MemOE, MemWR, RamCS, QuadSpiFlashCS} = 4'b1111;

    //create clk25
    reg pulse;
    reg clk25;

    always @(posedge ClkPort)
        pulse = ~pulse;
    always @(posedge pulse)
        clk25 = ~clk25;

    //Instantiate modules
    display_controller dc(.clk(clk25), .hSync(hSync), .vSync(vSync), .bright(bright), .hCount(hc), .vCount(vc));
    maze_controller mc(.clk(clk25), .bright(bright), .hCount(hc), .vCount(vc), .rgb(rgb), .Right(BtnR), .Left(BtnL), .Reset(BtnC), .Up(BtnU), .Down(BtnD), .score(score));

    //itialize
    initial begin
        clk25 = 0;
        pulse = 0;    
    end

endmodule

