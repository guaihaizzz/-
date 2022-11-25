module DDS_use(
    sys_clk,
    rst_n  ,
    key_in,
    LOADDAC ,                                                       //高电平有效
    key_1   ,
    DATA
    );
    output                              LOADDAC                    ;

    input                               key_1                      ;

    output             [  11:0]         DATA                       ;
    
    
    input                               sys_clk                    ;
    input                               rst_n                      ;
    input                               key_in                     ;//频率切换
    

assign LOADDAC = key_1;

wire                   [  11:0]         data_r                     ;
wire                   [  11:0]         Pword    =0                ;
wire                   [  31:0]         Fword                      ;
wire                                    key_state                  ;
wire                                    key_flag                   ;


reg                    [   2:0]         Fword_sel                  ;//????????????????????
reg                    [  31:0]         Fword_r                    ;

    parameter                           F_100 = 8590               ;//2**32/50_000_000*100;???????100HZ
    parameter                           F_300 = 25770              ;//2**32/50_000_000*300;???????300HZ
    parameter                           F_1k  = 85899              ;//2**32/50_000_000*1_000;???????1kHZ
    parameter                           F_3k  = 257698             ;//2**32/50_000_000*3_000;???????3kHZ
    parameter                           F_10k = 858993             ;//2**32/50_000_000*10_000;???????10kHZ
// always@(*)begin
//     Data_r1 <= data_r + 2048;
//     Data_r2 <= data_r;
//     if (!key_2) begin
//         DATA <= Data_r1;
//     end
//     else
//         DATA <= Data_r2;

// end
assign DATA = data_r;

//always@(posedge sys_clk or negedge rst_n)begin
//    if(!rst_n)begin
//        Fword_sel <= 0;
//    end
//    else 
//        Fword_sel <= Fword_r_tb;
//    end

//??????
always@(posedge sys_clk or negedge rst_n)begin
    if(!rst_n)
    Fword_r <= F_100;
    else
        case (Fword_sel)
        3'b000 : Fword_r <= F_100;
        3'b001 : Fword_r <= F_300;
        3'b010 : Fword_r <= F_1k;
        3'b011 : Fword_r <= F_3k;
        3'b100 : Fword_r <= F_10k;
            default: Fword_r <= F_10k;
    endcase
end

// always@(*)begin
//     if(Fword_sel == 0)
//         Fword_r <= F_100;
//     else if(Fword_sel == 1)
//         Fword_r <= F_300;
//     else if(Fword_sel == 2)
//         Fword_r <= F_1k;
//     else if(Fword_sel == 3)
//         Fword_r <= F_3k;
//     else 
//         Fword_r <= F_10k;
// end

always@(posedge sys_clk or negedge rst_n)begin
    if(!rst_n)begin
        Fword_sel <= 0;
    end
    else if((Fword_sel == 3'd4) && key_flag && (key_state == 0))
        Fword_sel <= 0;
    else if(key_flag && (key_state == 0) )begin
        Fword_sel <= Fword_sel + 1'b1;
    end
end

assign Fword = Fword_r;

//????????
key_filter key_filter_init(
    .sys_clk                           (sys_clk                   ),
    .rst_n                             (rst_n                     ),
    .key_in                            (key_in                    ),
    .key_flag                          (key_flag                  ),
    .key_state                         (key_state                 ) 
);

DDS u_DDS(
    .sys_clk                           (sys_clk                   ),
    .rst_n                             (rst_n                     ),
    .Fword                             (Fword                     ),
    .Pword                             (Pword                     ),
    .Data                              (data_r                    ) 
);

endmodule
