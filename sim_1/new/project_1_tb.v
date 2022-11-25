`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/22 16:55:59
// Design Name: 
// Module Name: tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_1();
reg                                     sys_clk                    ;// ??????100MHz
reg                                     rst_n                      ;// ????????????????
reg                                     clk_fx                     ;
reg                                     clk_fx2                    ;
//spi???                                                         
reg                                     spi_miso                   ;
wire                                    spi_sclk                   ;
wire                                    spi_cs                     ;
wire                                    spi_mosi                   ;
//    wire                              LOADDAC                    ;                                                                 
//    reg                               key_1                      ;                                                                 
//    wire             [  11:0]         DATA                       ;

//    reg                               key_in                      ;//频率切换


//    Equal_precision_measurement U1(
//    .sys_clk  (sys_clk  )  ,    //系统时钟
//    .rst_n    (rst_n    )  ,    
//    .clk_fx   (clk_fx   )  ,    //待测信号
//    .fx       (fx   )   //待测信号频率
//    );
project_1_top u_project_1_top(
    .sys_clk                           (sys_clk                   ),
    .rst_n                             (rst_n                     ),
    .clk_fx                            (clk_fx                    ),
    .clk_fx2                           (clk_fx2                   ),
    .spi_miso                          (spi_miso                  ),
    .spi_sclk                          (spi_sclk                  ),
    .spi_cs                            (spi_cs                    ),
    .spi_mosi                          (spi_mosi                  ),
    .LOADDAC                           (                          ),
    .key_1                             (                          ),
    .DATA                              (                          ),
    .key_in                            (                          ) 
);

initial begin
    #1  sys_clk   = 1'b0;
    #1  rst_n     = 1'b0;

    #100    rst_n = 1'b1;
end
always #5 sys_clk <= ~sys_clk;
initial fork begin
    #1;
    clk_fx   = 1'b0;
    forever begin
        #100000;
        clk_fx <= ~clk_fx;
    end
end
join
initial fork begin
    #5001;
    clk_fx2   = 1'b0;
    forever begin
        #100000;
        clk_fx2 <= ~clk_fx2;
    end
end
join
endmodule
