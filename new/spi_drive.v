module spi_drive
(
// ϵͳ�ӿ�
    input                               sys_clk                    ,// 
    input                               clk_1MHZ                   ,
    input                               sys_rst_n                  ,// ��λ�źţ��͵�ƽ��Ч
// �û��ӿ�	
    input                               spi_start                  ,// ���ʹ��俪ʼ�źţ�һ���ߵ�ƽ
    input                               spi_end                    ,// ���ʹ�������źţ�һ���ߵ�ƽ
    input              [   7:0]         data_send                  ,// Ҫ���͵�����
    output reg         [   7:0]         data_rec                   ,// ���յ�������
    output reg                          send_done                  ,// ��������һ���ֽ���ϱ�־λ    
    output reg                          rec_done                   ,// ��������һ���ֽ���ϱ�־λ    
// SPI����ӿ�
    input                               spi_miso                   ,// SPI�������룬�������մӻ�������
    output reg                          spi_sclk                   ,// SPIʱ��
    output reg                          spi_cs                     ,// SPIƬѡ�ź�,�͵�ƽ��Ч
    output reg                          spi_mosi                    // SPI������������ӻ���������          
);

reg                    [   1:0]         cnt                        ;//4��Ƶ������
reg                    [   3:0]         bit_cnt_send               ;//���ͼ�����
reg                    [   3:0]         bit_cnt_rec                ;//���ռ�����
reg                                     spi_end_req                ;//��������

//4��Ƶ������
always @(posedge clk_1MHZ or negedge sys_rst_n)begin
    if(!sys_rst_n)
        cnt <= 2'd0;
    else if(!spi_cs)begin
        if(cnt == 2'd3)
            cnt <= 2'd0;
        else
        cnt <= cnt + 1'b1;
    end
    else
        cnt <= 2'd0;
end
// ����spi_sclkʱ�ӣ�Ϊsys_clk����Ƶ��25MHZ
always @(posedge clk_1MHZ or negedge sys_rst_n)begin
    if(!sys_rst_n)
        spi_sclk <= 1'b0;                                           //ģʽ0Ĭ��Ϊ�͵�ƽ					
    else if(!spi_cs)begin                                           //��SPI���������
        if(cnt == 2'd0 )
            spi_sclk <= 1'b0;
        else if (cnt == 2'd2)
            spi_sclk <= 1'b1;
        else
            spi_sclk <= spi_sclk;
    end
    else
        spi_sclk <= 1'b0;                                           //ģʽ0Ĭ��Ϊ�͵�ƽ		
end
// ����Ƭѡ�ź�spi_cs
always @(posedge sys_clk or negedge sys_rst_n)begin
    if(!sys_rst_n)
        spi_cs <= 1'b1;                                             //Ĭ��Ϊ�ߵ�ƽ						
    else if(spi_start)                                              //��ʼSPI׼�����䣬����Ƭѡ�ź�
        spi_cs <= 1'b0;
	//�յ���SPI�����źţ��ҽ����������һ��BYTE
    else if(spi_end_req && (cnt == 2'd1 && bit_cnt_rec == 4'd0))
        spi_cs <= 1'b1;                                             //����Ƭѡ�źţ�����SPI����
end
// ���ɽ��������ź�(��׽spi_end�ź�)
always @(posedge sys_clk or negedge sys_rst_n)begin
    if(!sys_rst_n)
        spi_end_req <= 1'b0;                                        //Ĭ�ϲ�ʹ��					
    else if(spi_cs)
        spi_end_req <= 1'b0;                                        //����SPI�������������
    else if(spi_end)
        spi_end_req <= 1'b1;                                        //���յ�SPI�����źź�Ͱѽ�����������
end
// �������ݹ���--------------------------------------------------------------------

// ��������
always @(posedge clk_1MHZ or negedge sys_rst_n)begin
    if(!sys_rst_n)begin
        spi_mosi <= 1'b0;                                           //ģʽ0����
        bit_cnt_send <= 4'd0;
    end
    else if(cnt == 2'd0 && !spi_cs)begin                            //ģʽ0��������
        spi_mosi <= data_send[7-bit_cnt_send];                      //����������λ
        if(bit_cnt_send == 4'd7)                                    //������8bit
            bit_cnt_send <= 4'd0;
        else
            bit_cnt_send <= bit_cnt_send + 1'b1;
    end
    else if(spi_cs)begin                                            //�Ǵ���ʱ���
        spi_mosi <= 1'b0;                                           //ģʽ0����
        bit_cnt_send <= 4'd0;
    end
    else begin
        spi_mosi <= spi_mosi;
        bit_cnt_send <= bit_cnt_send;
    end
end
// �������ݱ�־
always @(posedge clk_1MHZ or negedge sys_rst_n)begin
    if(!sys_rst_n)
        send_done <= 1'b0;
    else if(cnt == 2'd0 && bit_cnt_send == 4'd7)                    //��������8bit����
        send_done <= 1'b1;                                          //����һ�����ڣ���ʾ�������	
    else
        send_done <= 1'b0;
end
 
// �������ݹ���--------------------------------------------------------------------
 
// ��������spi_miso
always @(posedge clk_1MHZ or negedge sys_rst_n)begin
    if(!sys_rst_n)begin
        data_rec <= 8'd0;
        bit_cnt_rec <= 4'd0;
    end
    else if(cnt == 2'd2 && !spi_cs)begin                            //ģʽ0��������
        data_rec[7-bit_cnt_rec] <=     spi_miso;                    //��λ����
        if(bit_cnt_rec == 4'd7)                                     //��������8bit
            bit_cnt_rec <= 4'd0;
        else
            bit_cnt_rec <= bit_cnt_rec + 1'b1;
    end
    else if(spi_cs)begin
        bit_cnt_rec <= 4'd0;
    end
    else begin
        data_rec <= data_rec;
        bit_cnt_rec <= bit_cnt_rec;
    end
end
// �������ݱ�־
always @(posedge clk_1MHZ or negedge sys_rst_n)begin
    if(!sys_rst_n)
        rec_done <= 1'b0;
    else if(cnt == 2'd2 && bit_cnt_rec == 4'd7)                     //��������8bit
        rec_done <= 1'b1;                                           //����һ�����ڣ���ʾ�������			
    else
        rec_done <= 1'b0;
end

endmodule
