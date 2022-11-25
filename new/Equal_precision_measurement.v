module Equal_precision_measurement(
    sys_clk,                                                        //系统时钟
    rst_n,
    clk_fx,                                                         //待测信号

    fs_cnt,                                                         //待测信号频率
    measurement_end_flag
    );
//信号    
    input                               sys_clk                    ;
    input                               rst_n                      ;
    input                               clk_fx                     ;

    output reg         [  31:0]         fs_cnt                     ;//门控时间内基准时钟的计数值
    output reg                          measurement_end_flag       ;
//常数
    parameter                           CLK_FS    = 28'd100_000_000;//时钟信号100MHZ     
    parameter                           GATE_TIME = 16'd100        ;//实际门控时间，即被测信号边沿次数，越大误差越小，但测量时间也会变长    

//reg define
reg                                     gate_fx                    ;//门控信号，被测信号域下         
reg                                     gate_fs                    ;//同步到基准时钟的门控信号	
reg                                     gate_fs_r                  ;//用于同步gate信号的寄存器
reg                                     gate_fs_d0                 ;//用于采集基准时钟下gate下降沿
reg                                     gate_fs_d1                 ;//用于采集基准时钟下gate下降沿
reg                                     gate_fx_d0                 ;//用于采集被测时钟下gate下降沿
reg                                     gate_fx_d1                 ;//用于采集被测时钟下gate下降沿
reg                    [  15:0]         gate_cnt                   ;//门控计数
//reg    [31:0]   	fs_cnt      ;           //门控时间内基准时钟的计数值
reg                    [  31:0]         fs_cnt_temp                ;//fs_cnt 临时值
reg                    [  31:0]         fx_cnt                     ;//门控时间内被测时钟的计数值
reg                    [  31:0]         fx_cnt_temp                ;//fx_cnt 临时值

reg                    [  31:0]         fx_reg                     ;

//wire define
wire                                    neg_gate_fs                ;//基准时钟下门控信号下降沿=
wire                                    neg_gate_fx                ;//被测时钟下门控信号下降沿

//下降沿采集
assign      neg_gate_fs = gate_fs_d1 & ~gate_fs_d0;
assign      neg_gate_fx = gate_fx_d1 & ~gate_fx_d0;

//clk打拍
always@(posedge sys_clk or negedge rst_n)begin
    if(!rst_n)begin
        gate_fs_d1 <= 1'b0;
        gate_fs_d0 <= 1'b0;
    end
    else  begin
        gate_fs_d0 <= gate_fs;
        gate_fs_d1 <= gate_fs_d0;
    end
end
//fs打拍
always@(posedge clk_fx or negedge rst_n)begin
    if(!rst_n)begin
        gate_fx_d1 <= 1'b0;
        gate_fx_d0 <= 1'b0;
    end
    else  begin
        gate_fx_d0 <= gate_fx;
        gate_fx_d1 <= gate_fx_d0;
    end
end
//门控计数
always@(posedge clk_fx or negedge rst_n)begin
    if(!rst_n)begin
        gate_cnt <= 16'd0;
    end
    else if(gate_cnt == 2*GATE_TIME) begin
        gate_cnt <= 16'b0;
    end
    else    begin
            gate_cnt <= gate_cnt + 1'b1;
    end
end
//被测门控生成
always@(posedge clk_fx or negedge rst_n)begin
    if(!rst_n)begin
        gate_fx <= 1'b0;
    end
    else if(gate_cnt == GATE_TIME) begin
        gate_fx <= 1'b1;
    end
    else if(gate_cnt == 2*GATE_TIME) begin
        gate_fx <= 1'b0;
    end
    else    begin
        gate_fx <= gate_fx;
    end
end
//基准门控生成
//把闸门从被测时钟域同步到基准时钟域
always @(posedge sys_clk or negedge rst_n) begin
    if(!rst_n) begin
        gate_fs_r <= 1'b0;
        gate_fs   <= 1'b0;
    end
    else begin
        gate_fs_r <= gate_fx;
        gate_fs   <= gate_fs_r;
    end
end
//基准时钟计数
always@(posedge sys_clk or negedge rst_n)begin
    if(!rst_n)begin
        fs_cnt_temp <= 32'b0;
        fs_cnt <= 32'b0;
    end
    else if(gate_fx == 1) begin
        fs_cnt_temp <= fs_cnt_temp + 1'b1;
    end
    else if(neg_gate_fs)   begin
        fs_cnt <= fs_cnt_temp;
        fs_cnt_temp <= 0;
    end
    else
        fs_cnt_temp <= fs_cnt_temp;
end
//被测信号计数
always@(posedge clk_fx or negedge rst_n)begin
    if(!rst_n)begin
        fx_cnt_temp <= 32'b0;
        fx_cnt <= 32'b0;
    end
    else if(gate_fx == 1) begin
        fx_cnt_temp <= fx_cnt_temp + 1;
    end
    else if(neg_gate_fx)    begin
        fx_cnt <= fx_cnt_temp;
        fx_cnt_temp <= 0;
    end
    else
        fx_cnt_temp <= fx_cnt_temp;
end
//寄存neg_gate_fs打一拍实现measurement_end_flag
always@(posedge sys_clk or negedge rst_n)begin
    if(!rst_n)begin
        measurement_end_flag <= 0;
    end
    else begin
        measurement_end_flag <= neg_gate_fs;
    end
end
////输出频率
//always@(posedge sys_clk or negedge rst_n)begin
//    if(!rst_n)begin
//        fx_reg <= 0;
//    end
//    else if(neg_gate_fx == 1'b0) begin
////        fx[63:32] <= fx_cnt; 
////        fx[63:32] <= 0;
//        fx_reg <= fs_cnt;
//    end
//end
////寄存fx打一拍
//always@(posedge sys_clk or negedge rst_n)begin
//    if(!rst_n)begin
//        fx <= 0;
//    end
//    else begin
//        fx <= fx_reg;
//    end
//end
//always@(negedge sys_clk or negedge rst_n)begin
//    if(!rst_n)begin
//        fx_reg1 <= 0;
//    end
//    else begin
//        fx_reg1 <= fx;
//    end
//end
//always@(posedge sys_clk or negedge rst_n)begin
//    if(!rst_n)begin
//        measurement_end_flag <= 0;
//    end
//    else if(fx_reg1 !== fx) begin
//        measurement_end_flag <= 1;
//    end
//    else begin
//        measurement_end_flag <= 0;
//    end
//end
endmodule
