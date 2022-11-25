module compose(
    sys_clk     ,
    rst_n       ,
    high_times,
    all_times ,
    fx          ,
    data64
    );
    input                               sys_clk                    ;
    input                               rst_n                      ;
    input              [  15:0]         high_times                 ;
    input              [  15:0]         all_times                  ;
    input              [  31:0]         fx                         ;

    output reg         [  63:0]         data64                     ;
reg                    [  63:0]         data64_reg                 ;
    always@(posedge sys_clk or negedge rst_n)begin
        if(!rst_n)begin
            data64_reg <= 64'b0;
        end
        else begin
            data64_reg[63:48] <= high_times;
            data64_reg[47:32] <= all_times;
            data64_reg[31:0] <= fx;
        end
    end
        always@(posedge sys_clk or negedge rst_n)begin
        if(!rst_n)begin
            data64 <= 64'b0;
        end
        else begin
            data64 <= data64_reg;
        end
    end
endmodule
