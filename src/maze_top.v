`timescale 1ns / 1ps

module maze_top(
        input ClkPort,
        // For VGAs
        output hSync, vSync,
        output [3:0] vgaR, vgaG, vgaB,
        // Book Keeping
        output MemOE, MemWR, RamCS, QuadSpiFlashCS
    );

    //VGA Declarations
    wire bright;
    wire [9:0] hc, vc; // denotes the location of the VGA
    wire [11:0] rgb; // denotes the pixel color

    //VGA Assigns
    assign vgaR = rgb[11:8];
    assign vgaG = rgb[7:4];
    assign vgaB = rgb[3:0];

    //disable memory ports
    assign {MemOE, MemWR, RamCS, QuadSpiFlashCS} = 4'b1111;

    //Instantiate modules
    display_controller dc(.clk(ClkPort), .hSync(hSync), .vSync(vSync), .bright(bright), .hCount(hc), .vCount(vc));
    

