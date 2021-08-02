`timescale 1ns/1ns

module stream_async_fifo #(
    parameter   DSIZE = 8,
    parameter   ASIZE = 10
)(
    input  wire             rstn,
    input  wire             iclk,
    input  wire             itvalid,
    output wire             itready,
    input  wire [DSIZE-1:0] itdata,
    input  wire             oclk,
    output reg              otvalid,
    input  wire             otready,
    output wire [DSIZE-1:0] otdata
);

reg  [DSIZE-1:0] buffer [1<<ASIZE];  // may automatically synthesize to BRAM

logic [ASIZE:0] wptr, wptr_grey, wq_wptr_grey, rq1_wptr_grey, rq2_wptr_grey;
logic [ASIZE:0] rptr, rptr_grey, rq_rptr_grey, wq1_rptr_grey, wq2_rptr_grey;

assign wptr_grey = (wptr >> 1) ^ wptr;
assign rptr_grey = (rptr >> 1) ^ rptr;

always @ (posedge iclk or negedge rstn)
    if(~rstn)
        wq_wptr_grey <= '0;
    else
        wq_wptr_grey <= wptr_grey;

always @ (posedge oclk or negedge rstn)
    if(~rstn)
        {rq2_wptr_grey, rq1_wptr_grey} <= '0;
    else
        {rq2_wptr_grey, rq1_wptr_grey} <= {rq1_wptr_grey, wq_wptr_grey};

always @ (posedge oclk or negedge rstn)
    if(~rstn)
        rq_rptr_grey <= '0;
    else
        rq_rptr_grey <= rptr_grey;

always @ (posedge iclk or negedge rstn)
    if(~rstn)
        {wq2_rptr_grey, wq1_rptr_grey} <= '0;
    else
        {wq2_rptr_grey, wq1_rptr_grey} <= {wq1_rptr_grey, rq_rptr_grey};

wire w_full  = wq2_rptr_grey == {~wptr_grey[ASIZE:ASIZE-1], wptr_grey[ASIZE-2:0]};
wire r_empty = rq2_wptr_grey == rptr_grey;

assign itready = ~w_full;

always @ (posedge iclk or negedge rstn)
    if(~rstn) begin
        wptr <= '0;
    end else begin
        if(itvalid & ~w_full)
            wptr <= wptr + (1+ASIZE)'(1);
    end

always @ (posedge iclk)
    if(itvalid & ~w_full)
        buffer[wptr[ASIZE-1:0]] <= itdata;

reg             rdvalid;
reg [DSIZE-1:0] rddata;
reg [DSIZE-1:0] keepdata;
assign otdata = rdvalid ? rddata : keepdata;

always @ (posedge oclk or negedge rstn)
    if(~rstn) begin
        otvalid <= 1'b0;
        rdvalid <= 1'b0;
        rptr <= '0;
        keepdata <= '0;
    end else begin
        rdvalid <= 1'b0;
        if(rdvalid) keepdata <= rddata;
        if(~r_empty) begin
            if(~otvalid | otready) begin
                otvalid <= 1'b1;
                rdvalid <= 1'b1;
                rptr <= rptr + (1+ASIZE)'(1);
            end
        end else if(otready) begin
            otvalid <= 1'b0;
        end
    end

always @ (posedge oclk)
    rddata <= buffer[rptr[ASIZE-1:0]];

endmodule
