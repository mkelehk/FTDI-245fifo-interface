
module fifo #(
    parameter  INPUT_DSIZE = 8,
    parameter OUTPUT_DSIZE = 8,
    parameter        ASIZE = 10
)(
    input  logic clk, rst_n,
    output logic [31:0] count,   // count the data in fifo (unit:bit)
    output logic full_n, empty_n,
    input  logic wreq,
    output logic wgnt,
    input  logic [ INPUT_DSIZE-1:0] wdata,
    input  logic rinc,
    output logic [OUTPUT_DSIZE-1:0] rdata
);

localparam DSIZE = INPUT_DSIZE>OUTPUT_DSIZE ? INPUT_DSIZE : OUTPUT_DSIZE;
localparam  INPUT_RATIO_M1 = DSIZE / INPUT_DSIZE  - 1;
localparam OUTPUT_RATIO_M1 = DSIZE / OUTPUT_DSIZE - 1;

logic  [ASIZE-1:0] wr_pt = 0, rd_pt = 0, rd_pt_next;
logic  [31:0] wr_idx = 0, wr_idx_next;
logic  [31:0] rd_idx = 0, rd_idx_next;
logic  [DSIZE-1:0] rd_data;
logic  [DSIZE-1:0] wr_data, wr_data_last;
logic  wr_req;

assign full_n  = ( rd_pt != (wr_pt+1) ) ;
assign empty_n = ( rd_pt !=  wr_pt    ) && ( (rd_pt+1) !=  wr_pt    );
assign count = (wr_pt - rd_pt) * DSIZE;

always @ (*) begin
    wr_data = wr_data_last;
    if(wreq & full_n) begin
        wgnt = 1'b1;
        wr_data[(INPUT_DSIZE*wr_idx)+:INPUT_DSIZE] = wdata;
        if( wr_idx < INPUT_RATIO_M1 ) begin
            wr_req = 1'b0;
            wr_idx_next = wr_idx + 1;
        end else begin
            wr_req = 1'b1;
            wr_idx_next = 0;
        end
    end else begin
        wgnt   = 1'b0;
        wr_req = 1'b0;
        wr_idx_next = wr_idx;
    end
end

always @ (posedge clk or negedge rst_n)
    if(~rst_n) begin
        wr_pt <= 0;
        wr_data_last <= 0;
        wr_idx <= 0;
    end else begin
        if(wr_req)
            wr_pt++;
        wr_data_last <= wr_data;
        wr_idx <= wr_idx_next;
    end
    
always @ (*)
    if(rinc & empty_n) begin
        if( rd_idx < OUTPUT_RATIO_M1 ) begin
            rd_pt_next  = rd_pt;
            rd_idx_next = rd_idx + 1;
        end else begin
            rd_pt_next  = rd_pt + 1;
            rd_idx_next = 0;
        end
    end else begin
        rd_pt_next  = rd_pt;
        rd_idx_next = rd_idx;
    end
    
always @ (posedge clk or negedge rst_n)
    if(~rst_n) begin
        rd_pt  <= 0;
        rd_idx <= 0;
    end else begin
        rd_pt  <= rd_pt_next;
        rd_idx <= rd_idx_next;
    end
    
assign rdata = rd_data[(OUTPUT_DSIZE*rd_idx)+:OUTPUT_DSIZE];

ram #(
    .ADDR_LEN     ( ASIZE              ),
    .DATA_LEN     ( DSIZE              )
) ram_dual_port_for_sync_fifo_inst (
    .clk          ( clk                ),
    .wr_req       ( wr_req             ),
    .wr_addr      ( wr_pt              ),
    .wr_data      ( wr_data            ),
    .rd_addr      ( rd_pt_next         ),
    .rd_data      ( rd_data            )
);

endmodule
