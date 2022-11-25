module clk_1M(
    sys_clk,
    rst_n,
    clk_1MHZ
    );
    input                               sys_clk                    ;
    input                               rst_n                      ;
    output reg                          clk_1MHZ                   ;
reg                    [   7:0]         cnt                        ;
    
    always@(posedge sys_clk or negedge rst_n)begin
        if(!rst_n)begin
            cnt <= 0;
        end
        else if(cnt == 50 - 1) begin
            cnt <= 0;
        end
        else begin
            cnt <= cnt + 1;
        end
    end

    always@(posedge sys_clk or negedge rst_n)begin
        if(!rst_n)begin
            clk_1MHZ <= 0;
        end
        else if(cnt == 50 - 1) begin
            clk_1MHZ <= ~clk_1MHZ;
        end
        else begin
            clk_1MHZ <= clk_1MHZ;
        end
    end
endmodule
