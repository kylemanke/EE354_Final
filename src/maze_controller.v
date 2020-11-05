`timescale 1ns / 1ps

module maze_controller(
        input clk, 
        input bright,
        input [9:0] hCount, vCount,
        output reg [11:0] rgb
    );

    wire in_maze;

    // declare Black and White
    parameter BLACK = 12'b0000_0000_0000;
    parameter WHITE = 12'b1111_1111_1111;

    // registers to keep track of location
    reg [3:0] main_row, main_col;
    reg [3:0] mini_row, mini_col; 

    // maze registers
    reg [59:0] row_0 = 15'hFFFFFFFFFFFFFFF;
    reg [59:0] row_1 = 15'hFFFFFFFFFFFFFFF;
    reg [59:0] row_2 = 15'hFFFFFFFFFFFFFFF;
    reg [59:0] row_3 = 15'hFFFFFFFFFFFFFFF;
    reg [59:0] row_4 = 15'hFFFFFFFFFFFFFFF;
    reg [59:0] row_5 = 15'hFFFFFFFFFFFFFFF;
    reg [59:0] row_6 = 15'hFFFFFFFFFFFFFFF;
    reg [59:0] row_7 = 15'hFFFFFFFFFFFFFFF;
    reg [59:0] row_8 = 15'hFFFFFFFFFFFFFFF;
    reg [59:0] row_9 = 15'hFFFFFFFFFFFFFFF;
    reg [59:0] row_10 = 15'hFFFFFFFFFFFFFFF;
    reg [59:0] row_11 = 15'hFFFFFFFFFFFFFFF;
    reg [59:0] row_12 = 15'hFFFFFFFFFFFFFFF;
    reg [59:0] row_13 = 15'hFFFFFFFFFFFFFFF;
    reg [59:0] row_14 = 15'hFFFFFFFFFFFFFFF;

    // print maze
    always @(*)
    begin
        if(~bright)
            rgb = BLACK;
        else if (in_maze)
            rgb = BLACK;
        else
            rgb = WHITE;
    end

    assign in_maze = hCount > 10'd389 && hCount < 10'd539 && vCount > 10'd200 && vCount < 10'd350;

endmodule

    