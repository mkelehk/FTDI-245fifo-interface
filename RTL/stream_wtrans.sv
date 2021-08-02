`timescale 1ns/1ns

module stream_wtrans #(  // stream width transformer
    parameter I_DEXP = 0,  // input width,  0=1Byte, 1=2Byte, 2=4Byte, 3=8Bytes, 4=16Bytes, ...
    parameter O_DEXP = 0   // output width, 0=1Byte, 1=2Byte, 2=4Byte, 3=8Bytes, 4=16Bytes, ...
)(
    input  wire                   rstn,
    input  wire                   clk,
    input  wire                   itvalid,
    output wire                   itready,
    input  wire [(8<<I_DEXP)-1:0] itdata,
    output wire                   otvalid,
    input  wire                   otready,
    output wire [(8<<O_DEXP)-1:0] otdata
);

generate if(I_DEXP == O_DEXP) begin
    
    assign otvalid = rstn & itvalid;
    assign itready = rstn & otready;
    assign otdata = itdata;
    
end else begin

    localparam DEXP = I_DEXP > O_DEXP ? I_DEXP : O_DEXP;

    reg  [2*(8<<DEXP)-1:0] buffer;
    
    reg  [1+DEXP-I_DEXP:0] wptr;
    reg  [1+DEXP-O_DEXP:0] rptr;
    wire          wmsb;
    wire          rmsb;
    wire [DEXP:0] wa;
    wire [DEXP:0] ra;
    
    assign {wmsb, wa} = {wptr, {I_DEXP{1'b0}}};
    assign {rmsb, ra} = {rptr, {O_DEXP{1'b0}}};
    
    wire empty =  {wmsb, wa[DEXP]} == {rmsb, ra[DEXP]};
    wire full  = {~wmsb, wa[DEXP]} == {rmsb, ra[DEXP]};
    
    assign itready = rstn & ~full;
    
    always @ (posedge clk or negedge rstn)
        if(~rstn) begin
            buffer <= '0;
            wptr <= '0;
        end else begin
            if(itvalid & ~full) begin
                buffer[wa*8+:(8<<I_DEXP)] <= itdata;
                wptr <= wptr + (2+DEXP-I_DEXP)'(1);
            end
        end
    
    assign otvalid = ~empty;
    assign otdata = buffer[ra*8+:(8<<O_DEXP)];
    
    always @ (posedge clk or negedge rstn)
        if(~rstn) begin
            rptr <= '0;
        end else begin
            if(otready & ~empty)
                rptr <= rptr + (2+DEXP-O_DEXP)'(1);
        end

end endgenerate

endmodule
