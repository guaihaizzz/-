module spi_start(
    sys_clk        ,
    rst_n    ,
    send8b_done,
    measurement_end_flag,
    phase_end_flag,
    data_send,
    data64,
    spi_start_flag,
    spi_end_flag
    );
    input                               sys_clk                    ;
    input                               rst_n                      ;
    input                               send8b_done                ;
    input                               measurement_end_flag       ;
    input                               phase_end_flag             ;
    input  wire        [  63:0]         data64                     ;

    output reg         [   7:0]         data_send                  ;
    output                              spi_start_flag             ;
    output                              spi_end_flag               ;

reg                                     send8b_done_d0             ;
reg                                     send8b_done_d1             ;
wire                                    send8b_done_flag           ;
//获得send_done信号在基准时钟域的触发脉冲
assign send8b_done_flag = send8b_done_d0 & ~send8b_done_d1;

always@(posedge sys_clk or negedge rst_n)begin
    if(!rst_n)begin
        send8b_done_d0 <= 0;
        send8b_done_d1 <= 0;
    end
    else begin
        send8b_done_d0 <= send8b_done;
        send8b_done_d1 <= send8b_done_d0;
    end
end
//根据send8b_done_flag进行计数，实现8*8=64位数据的发送
//计数0 -> 7
reg                    [   2:0]         cnt_0                      ;
wire                                    add_cnt_0                  ;
wire                                    end_cnt_0                  ;
reg                                     dout                       ;
always @(posedge sys_clk or negedge rst_n)begin
    if(!rst_n)
        cnt_0 <= 0;
    else if(add_cnt_0) begin
        if(end_cnt_0)
            cnt_0 <= 0;
        else if(send8b_done_flag)
            cnt_0 <= cnt_0 + 1;
    end
end
assign add_cnt_0 = dout==1 ;
assign end_cnt_0 = send8b_done_flag && add_cnt_0 && cnt_0==8-1 ;
    always  @(posedge sys_clk or negedge rst_n)begin
    if(!rst_n)
        dout <= 0;
    else if(spi_start_flag)
        dout <= 1;                                                  //en使能dout = 1,开始计数
    else if(end_cnt_0)
        dout <= 0;
    end
//将数据从高到低8位发送\
reg                    [  63:0]         data64_reg                 ;
reg                    [   7:0]         data_send_reg              ;

always @(posedge sys_clk or negedge rst_n)begin
    if(!rst_n)
        data64_reg <= 0;
    else if(end_cnt_0) begin
        data64_reg <= data64;
    end
end
always@(posedge sys_clk or negedge rst_n)begin
    if(!rst_n)begin
        data_send_reg <= 0;
    end
    else if(dout) begin
        data_send_reg[7:0] <= data64_reg[63-(8*cnt_0)-:8];
    end
    else begin
        data_send_reg <= data_send_reg;
    end
end

always @(posedge sys_clk or negedge rst_n)begin
    if(!rst_n)
        data_send <= 0;
    else begin
        data_send <= data_send_reg;
    end
end
//**********************产生spi开始发送和结束的信息
wire                                    spi_start                  ;
reg                                     spi_start_d0               ;
reg                                     spi_start_d1               ;
reg                                     measurement_end_flag_reg   ;//measurement标志寄存信号

always@(posedge sys_clk or negedge rst_n)begin
    if(!rst_n)begin
        measurement_end_flag_reg <= 0;
    end
    else if(measurement_end_flag) begin
        measurement_end_flag_reg <= 1;
    end
    else if(spi_start_flag) begin
        measurement_end_flag_reg <= 0;
    end
end

assign  spi_start = measurement_end_flag_reg && phase_end_flag;
assign  spi_start_flag = spi_start_d0 && ~spi_start_d1;

always@(posedge sys_clk or negedge rst_n)begin
    if(!rst_n)begin
        spi_start_d0<=0;
        spi_start_d1<=0;
    end
    else begin
        spi_start_d0<=spi_start;
        spi_start_d1<=spi_start_d0;
    end
end

wire                                    spi_end                    ;
reg                                     spi_end_d0                 ;
reg                                     spi_end_d1                 ;

    assign  spi_end = end_cnt_0;
    assign  spi_end_flag = spi_end_d0 && ~spi_end_d1;
always@(posedge sys_clk or negedge rst_n)begin
    if(!rst_n)begin
        spi_end_d0<=0;
        spi_end_d1<=0;
    end
    else begin
        spi_end_d0<=spi_end;
        spi_end_d1<=spi_end_d0;
    end
end
endmodule
