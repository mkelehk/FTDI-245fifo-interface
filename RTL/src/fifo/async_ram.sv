
module async_ram #(
    parameter  DSIZE = 8,    // Memory data word width
    parameter  ASIZE = 4,    // Number of mem address bits
    parameter  FALLTHROUGH = "TRUE" // First word fall-through
)(
    input wire                wclk,
    input wire                wclken,
    input wire [ASIZE-1:0] waddr,
    input wire [DSIZE-1:0] wdata,
    input wire                wfull,
    input                     rclk,
    input                     rclken,
    input wire [ASIZE-1:0] raddr,
    output reg [DSIZE-1:0] rdata
);
    
localparam DEPTH = 1<<ASIZE;
    
reg [DSIZE-1:0] mem [0:DEPTH-1];
    
always @(posedge wclk)
    if (wclken && !wfull) 
        mem[waddr] <= wdata;

generate
    if (FALLTHROUGH == "TRUE")
      begin : fallthrough
        always @*
          rdata = mem[raddr];
      end
    else
      begin : registered_read
        always @(posedge rclk) begin
          if (rclken)
            rdata <= mem[raddr];
        end
      end
endgenerate

endmodule
