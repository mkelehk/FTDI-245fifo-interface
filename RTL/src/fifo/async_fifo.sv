module async_fifo #(
    parameter DSIZE = 8,
    parameter ASIZE = 4,
    parameter FALLTHROUGH = "TRUE" // First word fall-through
)(
    input  wire             wclk,
    input  wire             wrst_n,
    input  wire             winc,
    input  wire [DSIZE-1:0] wdata,
    output reg              wfull,
    input  wire             rclk,
    input  wire             rrst_n,
    input  wire             rinc,
    output wire [DSIZE-1:0] rdata,
    output reg              rempty
);

reg  [ASIZE  :0] rbin=0, rptr=0, wbin=0, wptr=0, rq1_wptr=0, rq2_wptr=0, wq1_rptr=0, wq2_rptr=0;
    
// Synchronizing the read pointer from read to write clock domain
always @(posedge wclk or negedge wrst_n)
    if (~wrst_n)
        {wq2_rptr,wq1_rptr} <= 0;
    else
        {wq2_rptr,wq1_rptr} <= {wq1_rptr, rptr};
            
// Handling the write requests
always @(posedge wclk or negedge wrst_n)
    if(~wrst_n) begin
        wbin = 0;
        wptr = 0;
        wfull= 1'b0;
    end else begin
        wbin+= (winc & ~wfull);
        wptr = (wbin >> 1) ^ wbin;
        wfull= (wptr == {~wq2_rptr[ASIZE:ASIZE-1],wq2_rptr[ASIZE-2:0]});
    end

// Synchronizing the write pointer from write to read clock domain
always @(posedge rclk or negedge rrst_n)
    if (~rrst_n) 
        {rq2_wptr,rq1_wptr} <= 0;
    else
        {rq2_wptr,rq1_wptr} <= {rq1_wptr,wptr};
    
always @(posedge rclk or negedge rrst_n)
    if (~rrst_n) begin
        rbin = 0;
        rptr = 0;
        rempty = 1'b0;
    end else begin
        rbin+= (rinc & ~rempty);
        rptr = (rbin >> 1) ^ rbin;
        rempty = (rptr == rq2_wptr);
    end

async_ram #(
    .DSIZE  ( DSIZE           ),
    .ASIZE  ( ASIZE           ),
    .FALLTHROUGH (FALLTHROUGH )
) ram_in_async_fifo (
    .rclken ( rinc            ),
    .rclk   ( rclk            ),
    .rdata  ( rdata           ),
    .wdata  ( wdata           ),
    .waddr  ( wbin[ASIZE-1:0] ),
    .raddr  ( rbin[ASIZE-1:0] ),
    .wclken ( winc            ),
    .wfull  ( wfull           ),
    .wclk   ( wclk            )
);

endmodule
