`timescale 1ns / 1ps

module maze_controller(
        input clk,
        input move_clk,
        input bright,
        input Up, Down, Left, Right, Reset,
        output reg [3:0] score,
        input [9:0] hCount, vCount,
        output reg [11:0] rgb
    );

    wire coin;
    wire wall;
    wire in_maze;
    wire print_start;
    wire print_finish;
    wire block_fill;
    reg [11:0] background;

    // declare Colors
    parameter BLACK = 12'b0000_0000_0000;
    parameter WHITE = 12'b1111_1111_1111;
    parameter GREEN = 12'b0000_1111_0000;
    parameter RED = 12'b1111_0000_0000;
    parameter BLUE = 12'b0000_0000_1111;
    parameter GOLD = 12'b1111_1100_0000;

    //declare states
    localparam
    INI = 3'b001,
    PLAY = 3'b010,
    DONE = 3'b100;

    // registers to keep track of maze location
    reg [3:0] main_row;
    reg [4:0] mini_row, mini_col; 
    reg [5:0] main_col;

    // registers to keep track of block and coin locations
    reg [9:0] xpos, ypos;
    reg [9:0] xcheck, ycheck;
    reg [9:0] xcoin_pos, ycoin_pos;
    reg [9:0] xcoin [0:3];
    reg [9:0] ycoin [0:3];
    reg coin_flag;
    reg wall_flag;

    //register for states
    reg [2:0] state;

    // maze registers
    reg [59:0] maze [0:14];

    initial begin
        background = RED;
        wall_flag = 0;
        coin_flag = 0;
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
        //initialize different coin positions
        xcoin[0] = 380;
        xcoin[1] = 400;
        xcoin[2] = 520;//
        xcoin[3] = 472;//
        ycoin[0] = 140;
        ycoin[1] = 275;
        ycoin[2] = 415;//
        ycoin[3] = 292;//
    end

    // print maze
    always @(posedge clk)
    begin
        if(~bright)
            rgb = BLACK;
        
        else if(in_maze)
        begin
            rgb = WHITE; // let this be overwritten if a wall
            if (block_fill)
            begin
                if (wall)
                    wall_flag = 1;
                rgb = BLUE;
            end
            else if (coin)
            begin
                if (coin_flag == 1)
                    rgb <= WHITE;
                else
                    rgb = GOLD;
            end
            else if (print_start)
                rgb = RED;
            else if (print_finish)
                rgb = GREEN;
            if (wall)
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
            rgb = background;
    end

    //block movement state machine
    always @(posedge move_clk, posedge Reset)
    begin
        if (Reset)
        begin
            state <= INI;
            xcheck <= 10'bXXXXXXXXXX;
            ycheck <= 10'bXXXXXXXXXX;
            xpos <= 10'bXXXXXXXXXX;
            ypos <= 10'bXXXXXXXXXX;
            xcoin_pos <= 10'bXXXXXXXXXX;
            ycoin_pos <= 10'bXXXXXXXXXX;
            background <= 12'bXXXXXXXXXXXX;
            score <= 4'bXXXX;
            coin_flag <= 1'bX;
        end
        else
        begin
            (* full_case, parallel_case *)
            case (state)
                INI:
                begin
                    background <= RED;
                    state <= PLAY;
                    xcheck <= 324;
                    ycheck <= 415;
                    xpos <= 324;
                    ypos <= 415;
                    xcoin_pos <= 350;
                    ycoin_pos <= 250;
                    coin_flag <= 0;
                    score <= 0; //might not use for multiple coins because more than one coin actually complicates it more than I thought
                end             
                PLAY:
                begin
                    if(Right) 
                    begin
				        xpos<=xpos+2; //change the amount you increment to make the speed faster 
			        end
			        else if(Left) 
                    begin
				        xpos<=xpos-2;
			        end
                    else if(Up) begin
                        ypos<=ypos-2;
                    end
                    else if(Down) begin
                        ypos<=ypos+2;
                    end
                    if (wall_flag)
                        begin
                            xpos <= xcheck;
                            ypos <= ycheck;
                            wall_flag <= 0;
                        end
                    if (block_fill && coin)
                    begin
                        score <= score + 1;
                        xcheck <= xcoin_pos;
                        ycheck <= ycoin_pos;
                        if (score < 5)
                        begin
                            xcoin_pos <= xcoin[score];
                            ycoin_pos <= ycoin[score];
                        end                            
                        else
                            coin_flag <= 1;
                    end
                    if (block_fill && print_finish && coin_flag == 1)
                        state <= DONE;
                end 
                DONE:
                begin
                    background = GREEN;
                end    
                 
            endcase
        end
        
    end

    assign coin = vCount >= (ycoin_pos-2) && vCount <= (ycoin_pos+2) && hCount >= (xcoin_pos-2) && hCount <= (xcoin_pos+2);
    assign wall = (mini_row < 5'b00101 && maze[main_row][main_col] == 1'b1) || (mini_row > 5'b01110 && maze[main_row][main_col - 2] == 1'b1) || (mini_col < 5'b00101 && maze[main_row][main_col - 3] == 1'b1) || (mini_col > 5'b01110 && maze[main_row][main_col - 1] == 1'b1);
    assign block_fill = vCount >= (ypos-2) && vCount <= (ypos+2) && hCount >= (xpos-2) && hCount <= (xpos+2);
    assign in_maze = hCount >= 10'd314 && hCount < 10'd614 && vCount >= 10'd125 && vCount < 10'd425;
    assign print_start = hCount >= 10'd314 && hCount < 10'd334 && vCount >= 10'd405 && vCount < 10'd425;
    assign print_finish = hCount >= 10'd594 && hCount < 10'd614 && vCount >= 10'd125 && vCount < 10'd145;
    

endmodule    