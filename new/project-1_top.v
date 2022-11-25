module project_1_top(
    input                               sys_clk                    ,// ??????100MHz
    input                               rst_n                      ,// ????????????????
//???????
    input                               clk_fx                     ,
    input                               clk_fx2                    ,
//spi???
    input                               spi_miso                   ,
    output                              spi_sclk                   ,
    output                              spi_cs                     ,
    output                              spi_mosi                   ,

    output             [  11:0]         DATA                       ,
    
    input                               key_in                      //ÆµÂÊÇÐ»»


    );
DDS_use u_DDS_use(
    .sys_clk                           (sys_clk                   ),
    .rst_n                             (rst_n                     ),
    .key_in                            (key_in                    ),
    .DATA                              (DATA                      ) 
);
top u_top(
    .sys_clk                           (sys_clk                   ),
    .rst_n                             (rst_n                     ),
    .clk_fx                            (clk_fx                    ),
    .clk_fx2                           (clk_fx2                   ),
    .spi_sclk                          (spi_sclk                  ),
    .spi_cs                            (spi_cs                    ),
    .spi_mosi                          (spi_mosi                  ),
    .spi_miso                          (spi_miso                  ) 
);


endmodule
