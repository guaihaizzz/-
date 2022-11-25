module Equal_precision_measurement(
    sys_clk,                                                        //ϵͳʱ��
    rst_n,
    clk_fx,                                                         //�����ź�

    fs_cnt,                                                         //�����ź�Ƶ��
    measurement_end_flag
    );
//�ź�    
    input                               sys_clk                    ;
    input                               rst_n                      ;
    input                               clk_fx                     ;

    output reg         [  31:0]         fs_cnt                     ;//�ſ�ʱ���ڻ�׼ʱ�ӵļ���ֵ
    output reg                          measurement_end_flag       ;
//����
    parameter                           CLK_FS    = 28'd100_000_000;//ʱ���ź�100MHZ     
    parameter                           GATE_TIME = 16'd100        ;//ʵ���ſ�ʱ�䣬�������źű��ش�����Խ�����ԽС��������ʱ��Ҳ��䳤    

//reg define
reg                                     gate_fx                    ;//�ſ��źţ������ź�����         
reg                                     gate_fs                    ;//ͬ������׼ʱ�ӵ��ſ��ź�	
reg                                     gate_fs_r                  ;//����ͬ��gate�źŵļĴ���
reg                                     gate_fs_d0                 ;//���ڲɼ���׼ʱ����gate�½���
reg                                     gate_fs_d1                 ;//���ڲɼ���׼ʱ����gate�½���
reg                                     gate_fx_d0                 ;//���ڲɼ�����ʱ����gate�½���
reg                                     gate_fx_d1                 ;//���ڲɼ�����ʱ����gate�½���
reg                    [  15:0]         gate_cnt                   ;//�ſؼ���
//reg    [31:0]   	fs_cnt      ;           //�ſ�ʱ���ڻ�׼ʱ�ӵļ���ֵ
reg                    [  31:0]         fs_cnt_temp                ;//fs_cnt ��ʱֵ
reg                    [  31:0]         fx_cnt                     ;//�ſ�ʱ���ڱ���ʱ�ӵļ���ֵ
reg                    [  31:0]         fx_cnt_temp                ;//fx_cnt ��ʱֵ

reg                    [  31:0]         fx_reg                     ;

//wire define
wire                                    neg_gate_fs                ;//��׼ʱ�����ſ��ź��½���=
wire                                    neg_gate_fx                ;//����ʱ�����ſ��ź��½���

//�½��زɼ�
assign      neg_gate_fs = gate_fs_d1 & ~gate_fs_d0;
assign      neg_gate_fx = gate_fx_d1 & ~gate_fx_d0;

//clk����
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
//fs����
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
//�ſؼ���
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
//�����ſ�����
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
//��׼�ſ�����
//��բ�Ŵӱ���ʱ����ͬ������׼ʱ����
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
//��׼ʱ�Ӽ���
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
//�����źż���
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
//�Ĵ�neg_gate_fs��һ��ʵ��measurement_end_flag
always@(posedge sys_clk or negedge rst_n)begin
    if(!rst_n)begin
        measurement_end_flag <= 0;
    end
    else begin
        measurement_end_flag <= neg_gate_fs;
    end
end
////���Ƶ��
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
////�Ĵ�fx��һ��
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
