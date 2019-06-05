
// for FTDI 245 fifo mode
module ftdi_245fifo #(
    parameter  USER_WRITE_DSIZE = 8,
    parameter  USER_READ_DSIZE  = 8,
    parameter  FTDI_DSIZE       = 8,
    parameter  WRITE_FIFO_ASIZE = 10,
    parameter  READ_FIFO_ASIZE  = 9,
    parameter  TX_MIN_BITS      = 512*8
)(
    input  logic rst_n,    // reset, active low
    // user write interface (FPGA -> USB -> PC)
    input  logic wr_clk,   // write interface clock domain, all write signals aligned on the posedge of wr_clk
    input  logic wr_req,   // when wr_req=1 in one wr_clk cycle, a wr_data is tried to push to the transfer fifo
    output logic wr_gnt,   // when wr_req=1 if wr_gnt=1, data pushed success, if wr_gnt=0, data pushed failed(fifo full)
    input  logic [USER_WRITE_DSIZE-1:0] wr_data, // data to push
    // user read  interface (PC -> USB -> FPGA)
    input  logic rd_clk,   // write interface clock domain, all read signals aligned on the posedge of rd_clk, it can be shared with wr_clk
    input  logic rd_req,   // when rd_req=1 in one rd_clk cycle, a usb recieved data is tried to readout on rd_data
    output logic rd_gnt,   // when rd_req=1, if rd_gnt=1, data read success(rd_data valid), if rd_gnt=0, data read failed(rd_data invalid)
    output logic [ USER_READ_DSIZE-1:0] rd_data,  // data to read
    // FTDI 245FIFO interface, tie these signals to FTDI USB chip 
    input  logic usb_rxf, usb_txe, usb_clk,
    output logic usb_wr, usb_rd, usb_oe,
    inout  logic [FTDI_DSIZE/8-1:0] usb_be, //only a few USB chips have this signal, for example:FT600,FT601. ignore it when the chip do NOT have the signal
    inout  logic [FTDI_DSIZE-1:0] usb_data
);

logic tx_afifo_wfull, tx_afifo_to_sfifo_req_n, tx_afifo_to_sfifo_valid, tx_data_valid;
logic [USER_WRITE_DSIZE-1:0] tx_afifo_to_sfifo_data;
logic [FTDI_DSIZE-1:0] tx_data;
logic [31:0] tx_fifo_cnt;

logic rx_afifo_wfull, rx_afifo_to_sfifo_req_n, rx_afifo_to_sfifo_valid, rx_sfifo_empty_n;
logic [FTDI_DSIZE-1:0] rx_afifo_to_sfifo_data;

enum {IDLE, RXDOE, RXD, TXD} status = IDLE;

assign wr_gnt = wr_req & ~tx_afifo_wfull;
assign rd_gnt = rd_req & rx_sfifo_empty_n;

assign usb_be   = usb_wr ? 8'hzz : 8'hff;
assign usb_data = usb_wr ? 64'hzzzzzzzzzzzzzzzz : tx_data;
assign usb_wr   = ~( tx_data_valid & (status==TXD) & ~usb_txe );
assign usb_oe   = ~( (status==RXDOE) || (status==RXD) );
assign usb_rd   = ~( ~rx_afifo_wfull & (status==RXD) & ~usb_rxf );

async_fifo #(   // TX async fifo
    .DSIZE        ( USER_WRITE_DSIZE        ),
    .ASIZE        ( 7                       ),
    .FALLTHROUGH  ( "TRUE"                  )
) async_fifo_tx_inst (
    .wrst_n       ( rst_n                   ),
    .rrst_n       ( rst_n                   ),
    
    .wclk         ( wr_clk                  ),
    .winc         ( wr_gnt                  ),
    .wdata        ( wr_data                 ),
    .wfull        ( tx_afifo_wfull          ),

    .rclk         ( usb_clk                 ),
    .rinc         ( tx_afifo_to_sfifo_valid ),
    .rdata        ( tx_afifo_to_sfifo_data  ),
    .rempty       ( tx_afifo_to_sfifo_req_n )
);

fifo #(   // TX sync fifo
    .INPUT_DSIZE  ( USER_WRITE_DSIZE ),
    .OUTPUT_DSIZE ( FTDI_DSIZE       ),
    .ASIZE        ( WRITE_FIFO_ASIZE )
) sync_fifo_tx_inst (
    .clk          ( usb_clk          ),
    .rst_n        ( rst_n            ),
    
    .wreq         ( ~tx_afifo_to_sfifo_req_n   ),
    .wdata        ( tx_afifo_to_sfifo_data     ),
    .full_n       ( tx_afifo_to_sfifo_valid    ),
    
    .rinc         ( ~usb_wr          ),
    .rdata        ( tx_data          ),
    .empty_n      ( tx_data_valid    ),
    
    .count        ( tx_fifo_cnt      )
);

async_fifo #(  // RX async fifo
    .DSIZE        ( FTDI_DSIZE              ),
    .ASIZE        ( 7                       ),
    .FALLTHROUGH  ( "TRUE"                  )
) async_fifo_rx_inst (
    .wrst_n       ( rst_n                   ),
    .rrst_n       ( rst_n                   ),
    
    .wclk         ( usb_clk                 ),
    .winc         ( ~usb_rd                 ),
    .wdata        ( usb_data                ),
    .wfull        ( rx_afifo_wfull          ),

    .rclk         ( rd_clk                  ),
    .rinc         ( rx_afifo_to_sfifo_valid ),
    .rdata        ( rx_afifo_to_sfifo_data  ),
    .rempty       ( rx_afifo_to_sfifo_req_n )
);

fifo #(   // RX sync fifo
    .INPUT_DSIZE  ( FTDI_DSIZE       ),
    .OUTPUT_DSIZE ( USER_READ_DSIZE  ),
    .ASIZE        ( READ_FIFO_ASIZE  )
) sync_fifo_rx_inst (
    .clk          ( rd_clk           ),
    .rst_n        ( rst_n            ),
    
    .wreq         ( ~rx_afifo_to_sfifo_req_n   ),
    .wdata        ( rx_afifo_to_sfifo_data     ),
    .full_n       ( rx_afifo_to_sfifo_valid    ),
    
    .rinc         ( rd_req           ),
    .rdata        ( rd_data          ),
    .empty_n      ( rx_sfifo_empty_n )
);

always @ (posedge usb_clk or negedge rst_n)   // TXD or RXD controll FSM
    if(~rst_n)
        status <= IDLE;
    else
        case(status)
        IDLE:
            if(~usb_rxf)   // rx priority > tx priority
                status <= RXDOE;
            else if(~usb_txe && tx_fifo_cnt >= TX_MIN_BITS)
                status <= TXD;
        TXD:
            if(~usb_rxf | usb_txe)   // rx priority > tx priority
                status <= IDLE;
        RXDOE:
            if(usb_rxf)
                status <= IDLE;
            else
                status <= RXD;
        RXD:
            if(usb_rxf)
                status <= IDLE;
        endcase

endmodule

