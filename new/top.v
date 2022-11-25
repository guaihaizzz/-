module top(
        sys_clk        ,
        rst_n    ,
        clk_fx      ,
        clk_fx2     ,
        spi_sclk    ,
        spi_cs      ,
        spi_mosi    ,
        spi_miso

    );
//?????
    input                               sys_clk                    ;// ??????100MHz
    input                               rst_n                      ;// ????????????????
//???????
    input                               clk_fx                     ;
    input                               clk_fx2                    ;
//spi???
    input                               spi_miso                   ;
    output                              spi_sclk                   ;
    output                              spi_cs                     ;
    output                              spi_mosi                   ;

wire                                    send8b_done                ;
wire                                    spi_end_flag               ;
wire                                    spi_start_flag             ;
wire                   [   7:0]         data_send                  ;
wire                   [  31:0]         fx                         ;

wire                   [  15:0]         high_times                 ;
wire                   [  15:0]         all_times                  ;
wire                   [  63:0]         data64                     ;
//    assign fx = 64'h0000_1000_0001_0000;
wire                                    measurement_end_flag       ;
wire                                    phase_end_flag             ;

spi_drive u_spi_drive(
    .sys_clk                           (sys_clk                   ),
    .clk_1MHZ                          (clk_1MHZ                  ),
    .sys_rst_n                         (rst_n                     ),
    .spi_start                         (spi_start_flag            ),
    .spi_end                           (spi_end_flag              ),
    .data_send                         (data_send                 ),
    .data_rec                          (                          ),
    .send_done                         (send8b_done               ),
    .rec_done                          (                          ),
    .spi_miso                          (spi_miso                  ),
    .spi_sclk                          (spi_sclk                  ),
    .spi_cs                            (spi_cs                    ),
    .spi_mosi                          (spi_mosi                  ) 
);
Equal_precision_measurement u_Equal_precision_measurement(
    .sys_clk                           (sys_clk                   ),
    .rst_n                             (rst_n                     ),
    .clk_fx                            (clk_fx                    ),
    .fs_cnt                            (fx                        ),
    .measurement_end_flag              (measurement_end_flag      ) 
);
clk_1M u_clk_1M (
    .sys_clk                           (sys_clk                   ),
    .rst_n                             (rst_n                     ),
    .clk_1MHZ                          (clk_1MHZ                  ) 
);
Phase u_Phase(
    .fx1                               (clk_fx                    ),
    .fx2                               (clk_fx2                   ),
    .sys_clk                           (sys_clk                   ),
    .rst_n                             (rst_n                     ),
    .high_times                        (high_times                ),
    .all_times                         (all_times                 ),
    .phase_end_flag                    (phase_end_flag            ) 
);
compose u_compose(
    .sys_clk                           (sys_clk                   ),
    .rst_n                             (rst_n                     ),
    .high_times                        (high_times                ),
    .all_times                         (all_times                 ),
    .fx                                (fx                        ),
    .data64                            (data64                    ) 
);
spi_start u_spi_start(
    .sys_clk                           (sys_clk                   ),
    .rst_n                             (rst_n                     ),
    .send8b_done                       (send8b_done               ),
    .measurement_end_flag              (measurement_end_flag      ),
    .phase_end_flag                    (phase_end_flag            ),
    .data_send                         (data_send                 ),
    .data64                            (data64                    ),
    .spi_start_flag                    (spi_start_flag            ),
    .spi_end_flag                      (spi_end_flag              ) 
);

endmodule
