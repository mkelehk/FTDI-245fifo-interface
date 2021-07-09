
module stream_async_fifo #(
    parameter DSIZE = 1,
    parameter ASIZE = 7
)(
    input  logic               rst_n,
    
    input  logic               iclk,
    input  logic               itvalid,
    output logic               itready,
    input  logic [DSIZE*8-1:0] itdata,
    
    input  logic               oclk,
    input  logic               otready, 
    output logic               otvalid,
    output logic [DSIZE*8-1:0] otdata
);

initial itready = 1'b0;

logic               rreq;
logic               remptyn = 1'b0;
logic [DSIZE*8-1:0] rdata;

logic [ASIZE:0] rbin=0, rptr=0, wbin=0, wptr=0, rq1_wptr=0, rq2_wptr=0, wq1_rptr=0, wq2_rptr=0;

// Synchronizing the read pointer from read to write clock domain
always @(posedge iclk or negedge rst_n)
    if (~rst_n)
        {wq2_rptr,wq1_rptr} <= 0;
    else
        {wq2_rptr,wq1_rptr} <= {wq1_rptr, rptr};
            
// Handling the write requests
always @(posedge iclk or negedge rst_n)
    if(~rst_n) begin
        wbin = 0;
        wptr = 0;
        itready= 1'b0;
    end else begin
        if(itvalid &  itready) wbin++;
        wptr    = (wbin >> 1) ^ wbin;
        itready = (wptr != {~wq2_rptr[ASIZE:ASIZE-1],wq2_rptr[ASIZE-2:0]});
    end

// Synchronizing the write pointer from write to read clock domain
always @(posedge oclk or negedge rst_n)
    if (~rst_n) 
        {rq2_wptr,rq1_wptr} <= 0;
    else
        {rq2_wptr,rq1_wptr} <= {rq1_wptr,wptr};
    
always @(posedge oclk or negedge rst_n)
    if (~rst_n) begin
        rbin = 0;
        rptr = 0;
        remptyn = 1'b0;
    end else begin
        if(rreq & remptyn) rbin++;
        rptr = (rbin >> 1) ^ rbin;
        remptyn = (rptr != rq2_wptr);
    end

async_ram #(
    .DSIZE  ( DSIZE              ),
    .ASIZE  ( ASIZE              )
) ram_a_i (
    .wclk   ( iclk               ),
    .wen    ( itvalid &  itready ),
    .waddr  ( wbin[ASIZE-1:0]    ),
    .wdata  ( itdata             ),
    .rclk   ( oclk               ),
    .raddr  ( rbin[ASIZE-1:0]    ),
    .rdata  ( rdata              )
);

fifo2axis #(
    .DSIZE        ( DSIZE        )
) afifo2axis_i (
    .rst_n        ( rst_n        ),
    .clk          ( oclk         ),
    
    .i_req        ( rreq         ),
    .i_emptyn     ( remptyn      ),
    .i_data       ( rdata        ),
    
    .o_req        ( otready      ),
    .o_emptyn     ( otvalid      ),
    .o_data       ( otdata       )
);

endmodule




module stream_sync_fifo #(
    parameter  IDSIZE = 1,
    parameter  ODSIZE = 1,
    parameter   ASIZE = 10
)(
    input  logic rst_n, clk,
    
    input  logic                itvalid,
    output logic                itready,
    input  logic [IDSIZE*8-1:0] itdata,
    
    output logic                otvalid,
    input  logic                otready,
    output logic [ODSIZE*8-1:0] otdata,
    
    output logic halffull, quarterfull
);

localparam DSIZE = IDSIZE>ODSIZE ? IDSIZE : ODSIZE;
localparam  INPUT_RATIO_M1 = DSIZE / IDSIZE  - 1;
localparam OUTPUT_RATIO_M1 = DSIZE / ODSIZE - 1;

logic rreq, remptyn;
logic [ODSIZE*8-1:0] rdata;

logic  wr_req;
logic  [ASIZE-1:0] wr_addr;
logic  [DSIZE*8-1:0] wr_data, wr_data_last;
logic  [ASIZE-1:0] wr_pt = 0, rd_pt = 0;
logic  [DSIZE*8-1:0] rd_data;
logic  [31:0] wr_idx=0, wr_idx_next, rd_idx=0, rd_idx_last=0;

assign itready = rst_n & ( rd_pt != (wr_pt+1) );
assign remptyn = rst_n & ( rd_pt !=  wr_pt    );

wire   [ASIZE-1:0] count = (wr_pt - rd_pt);

initial halffull=1'b0;
initial quarterfull=1'b0;
always @ (posedge clk or negedge rst_n)
    if(~rst_n) begin
        halffull <= 1'b0;
        quarterfull <= 1'b0;
    end else begin
        halffull <= count[ASIZE-1];
        quarterfull <= count[ASIZE-1] | count[ASIZE-2];
    end

always @ (*) begin
    wr_data = wr_data_last;
    if(itvalid&itready) begin
        wr_data[(IDSIZE*8*wr_idx)+:IDSIZE*8] = itdata;
        if( wr_idx < INPUT_RATIO_M1 ) begin
            wr_req = 1'b0;
            wr_idx_next = wr_idx + 1;
        end else begin
            wr_req = 1'b1;
            wr_idx_next = 0;
        end
    end else begin
        wr_req = 1'b0;
        wr_idx_next = wr_idx;
    end
    wr_addr = wr_pt;
end

always @ (posedge clk or negedge rst_n)
    if(~rst_n) begin
        wr_pt <= 0;
        wr_data_last <= 0;
        wr_idx <= 0;
    end else begin
        if(wr_req) wr_pt++;
        wr_data_last <= wr_data;
        wr_idx <= wr_idx_next;
    end
    
always @ (posedge clk or negedge rst_n)
    if(~rst_n) begin
        rd_pt  = 0;
        rd_idx_last = 0;
        rd_idx = 0;
    end else begin
        rd_idx_last = rd_idx;
        if(rreq & remptyn) begin
            if(rd_idx<OUTPUT_RATIO_M1) begin
                rd_idx++;
            end else begin
                rd_pt++;
                rd_idx = '0;
            end
        end
    end
    
assign rdata = rd_data[(ODSIZE*8*rd_idx_last)+:ODSIZE*8];

async_ram #(
    .DSIZE    ( DSIZE      ),
    .ASIZE    ( ASIZE      )
) ram_s_i (
    .wclk     ( clk        ),
    .wen      ( wr_req     ),
    .waddr    ( wr_addr    ),
    .wdata    ( wr_data    ),
    .rclk     ( clk        ),
    .raddr    ( rd_pt      ),
    .rdata    ( rd_data    )
);

fifo2axis #(
    .DSIZE    ( ODSIZE     )
) sfifo2axis_i (
    .rst_n    ( rst_n      ),
    .clk      ( clk        ),
    
    .i_req    ( rreq       ),
    .i_emptyn ( remptyn    ),
    .i_data   ( rdata      ),
    
    .o_req    ( otready    ),
    .o_emptyn ( otvalid    ),
    .o_data   ( otdata     )
);

endmodule



module fifo2axis #(
    parameter DSIZE = 1
) (
    input  logic               clk, rst_n,
    output logic               i_req,
    input  logic               i_emptyn,
    input  logic [DSIZE*8-1:0] i_data,
    input  logic               o_req,
    output logic               o_emptyn,
    output logic [DSIZE*8-1:0] o_data
);

logic dvalid=1'b0, valid=1'b0;
logic [DSIZE*8-1:0] datareg='0;

assign o_emptyn = (valid | dvalid);
assign i_req    = rst_n & i_emptyn & ( o_req | ~o_emptyn );
assign o_data   = dvalid ? i_data : datareg;

always @ (posedge clk)
    if(~rst_n) begin
        dvalid <= 1'b0;
        valid  <= 1'b0;
    end else begin
        dvalid <= i_req;
        if(dvalid)
            datareg <= i_data;
        if(o_req)
            valid <= 1'b0;
        else if(dvalid)
            valid <= 1'b1;
    end

endmodule



module async_ram #(
    parameter  DSIZE = 1,    // Memory data word width (in bytes)
    parameter  ASIZE = 4     // Number of mem address bits
)(
    input  logic               wclk,
    input  logic               wen,
    input  logic [ASIZE  -1:0] waddr,
    input  logic [DSIZE*8-1:0] wdata,
    input  logic               rclk,
    input  logic [ASIZE  -1:0] raddr,
    output logic [DSIZE*8-1:0] rdata
);
    
localparam DEPTH = 1<<ASIZE;
    
reg [DSIZE*8-1:0] mem [0:DEPTH-1];

initial rdata = '0;

always @(posedge rclk)
    rdata <= mem[raddr];

always @(posedge wclk)
    if (wen) 
        mem[waddr] <= wdata;

endmodule
