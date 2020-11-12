`timescale 1ns / 1ps

module maze_controller(
        input clk, 
        input bright,
        input [9:0] hCount, vCount,
        output reg [11:0] rgb
    );

    wire in_maze;
    wire print_start;
    wire print_finish;

    // declare Black and White
    parameter BLACK = 12'b0000_0000_0000;
    parameter WHITE = 12'b1111_1111_1111;
    parameter GREEN = 12'b0000_1111_0000;
    parameter RED = 12'b1111_0000_0000;


    // registers to keep track of location
    reg [3:0] main_row;
    reg [4:0] mini_row, mini_col; 
    reg [5:0] main_col;

    // maze registers
    reg [59:0] maze [0:14];
    initial begin
        //initialize counters
        main_row = 4'b0000;
        main_col = 6'b111011;
        mini_row = 5'b00000;
        mini_col = 5'b00000;
        //initialize maze
        maze[0] = 60'h9AAAA_EBAAA_C9AAC;
        maze[1] = 60'h59C9A_C9AAA_65D96;
        maze[2] = 60'h55369_20C9A_A455D;
        maze[3] = 60'h538E3_C7559_A6534;
        maze[4] = 60'h1E59C_59671_CB286;
        maze[5] = 60'h59653_63AC7_1AC3C;
        maze[6] = 60'h5596B_8CD3C_3E5D5;
        maze[7] = 60'h557B8_63496_9C555;
        maze[8] = 60'h169A4_9C75B_43655;
        maze[9] = 60'h592C7_53C3C_5BA45;
        maze[10] = 60'h53E3C_592E5_59C34;
        maze[11] = 60'h3AAA6_53AA6_363C7;
        maze[12] = 60'h9AAAA_6BAA8_AAC3C;
        maze[13] = 60'h59AAC_9C9C3_CD3A4;
        maze[14] = 60'h36BA2_6363A_63AA6;
    end
    

    // print maze
    always @(posedge clk)
    begin
        if(~bright)
            rgb = BLACK;
        else if(in_maze)
        begin
            rgb = WHITE; // let this be overwritten if a wall
            if (print_start)
                rgb = GREEN;
            else if (print_finish)
                rgb = RED;
            if (mini_row < 5'b00101 && maze[main_row][main_col] == 1'b1)
                rgb = BLACK;
            else if (mini_row > 5'b01110 && maze[main_row][main_col - 2] == 1'b1)
                rgb = BLACK;
            else if (mini_col < 5'b00101 && maze[main_row][main_col - 3] == 1'b1)
                rgb = BLACK;
            else if (mini_col > 5'b01110 && maze[main_row][main_col - 1] == 1'b1)
                rgb = BLACK;
            mini_col <= mini_col + 1;
            if (mini_col == 5'b10011)
            begin
                mini_col <= 0;
                main_col <= main_col - 4;
                if (main_col == 6'b000011)
                begin
                    main_col <= 6'b111011;
                    mini_row <= mini_row + 1;
                    if (mini_row == 5'b10011)
                    begin
                        main_row <= main_row + 1;
                        mini_row <= 0;
                        if (main_row == 4'b1110)
                        begin
                            main_row <= 0;
                        end
                    end
                end
            end
        end
        else
            rgb = WHITE;
    end

    assign in_maze = hCount >= 10'd314 && hCount < 10'd614 && vCount >= 10'd125 && vCount < 10'd425;
    assign print_start = hCount >= 10'd314 && hCount < 10'd334 && vCount >= 10'd405 && vCount < 10'd425;
    assign print_finish = hCount >= 10'd594 && hCount < 10'd614 && vCount >= 10'd125 && vCount < 10'd145;
    

endmodule    