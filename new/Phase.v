module Phase(
    fx1,
    fx2,
    sys_clk,
    rst_n,
    high_times,
    all_times,
    phase_end_flag
    );

    input                               fx1                        ;
    input                               fx2                        ;
    input                               sys_clk                    ;
    input                               rst_n                      ;
    output reg         [  15:0]         high_times                 ;
    output reg         [  15:0]         all_times                  ;
    output reg                          phase_end_flag             ;

wire                                    catin_pos                  ;//??????????????????????
wire                                    XOR_reg                    ;
reg                                     XOR                        ;
    
reg                                     syn1                       ;
reg                    [  15:0]         high_times_reg             ;
reg                    [  15:0]         all_times_reg              ;
//????????????????????
assign XOR_reg = fx1^fx2;
    always@(posedge sys_clk or negedge rst_n)begin
        if(!rst_n)begin
            syn1 <= 0;
        end
        else begin
            XOR <= XOR_reg;
            syn1 <= XOR;
        end
    end
//?????????????????????????????
assign catin_pos = XOR & (~syn1);
//?????????¡§????????????????
always@(posedge sys_clk or negedge rst_n)begin
    if(!rst_n)begin
        high_times_reg <= 1 ;
        all_times_reg <=  1 ;
    end
    else if(catin_pos) begin
        high_times_reg <= 1 ;
        all_times_reg  <= 1 ;
    end
    else if(XOR) begin
        high_times_reg <= high_times_reg + 1;
        all_times_reg <= all_times_reg  + 1 ;
    end
    else if(!XOR) begin
        all_times_reg <= all_times_reg  + 1 ;
    end
    else begin
        high_times_reg <= high_times_reg ;
        all_times_reg <= all_times_reg   ;
    end
end
//?????????????????????????????????
always@(posedge sys_clk or negedge rst_n)begin
    if(!rst_n)begin
        high_times <= 0;
        all_times  <= 0;
    end
    else if(catin_pos) begin
        high_times <= high_times_reg ;
        all_times  <= all_times_reg  ;
    end
    else begin
        high_times <= high_times ;
        all_times  <= all_times  ;
    end
end

always@(posedge sys_clk or negedge rst_n)begin
    if(!rst_n)begin
        phase_end_flag <= 0;
    end
    else begin
        phase_end_flag <= catin_pos;
    end
end
endmodule
