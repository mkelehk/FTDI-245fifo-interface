
// for FTDI 245 fifo mode
module ftdi_245fifo #(
    parameter   INPUT_DSIZE = 1,  // User-specified SEND interface DATA width(in bytes). this parameter is NOT depend on FT232H chip, you can select 1, 2, 4 or 8...
    parameter   INPUT_ASIZE = 10, // User-specified SEND interface FIFO Depth = 2^INPUT_ASIZE
    parameter  OUTPUT_DSIZE = 1,  // User-specified RECV interface DATA width(in bytes). this parameter is NOT depend on FT232H chip, you can select 1, 2, 4 or 8...
    parameter  OUTPUT_ASIZE = 9,  // User-specified RECV interface FIFO Depth = 2^INPUT_ASIZE
    parameter    FTDI_DSIZE = 1   // FT232H data bus is 8bit width, this parameter is DEPEND on FT232H chip
)(
    // reset, active low
    input  logic rst_n,
    // user send interface (FPGA -> USB -> PC), AXI-stream  slave liked.
    input  logic                      iclk,    // User-specified clock for send interface
    input  logic                      itvalid,
    output logic                      itready,
    input  logic [ INPUT_DSIZE*8-1:0] itdata,
    // user recv interface (PC -> USB -> FPGA), AXI-stream master liked.
    input  logic                      oclk,    // User-specified clock for recv interface
    output logic                      otvalid,
    input  logic                      otready,
    output logic [OUTPUT_DSIZE*8-1:0] otdata,
    // FTDI 245FIFO interface, connect these signals to FTDI USB chip 
    input  logic usb_rxf, usb_txe, usb_clk,
    output logic usb_oe , usb_rd , usb_wr,
    inout  logic [FTDI_DSIZE*8-1:0] usb_data,
    inout  logic [FTDI_DSIZE  -1:0] usb_be // only FT600&FT601 have usb_be signal, ignore it when the chip do NOT have this signal
);

logic tx_a2s_tready, tx_a2s_tvalid;
logic [INPUT_DSIZE*8-1:0] tx_a2s_tdata;
logic rx_a2s_tready, rx_a2s_tvalid;
logic [ FTDI_DSIZE*8-1:0] rx_a2s_tdata;

logic txvalid, rxready, txfifo_sendimm;
logic [FTDI_DSIZE*8-1:0] txdata;
logic [ 3:0] fsm_cnt='0;
logic [15:0] tx_cnt ='0;
enum {RESET, IDLE, RXDOE, RXD, TXD} status = RESET;
wire  fifos_rst_n = (status!=RESET);

wire  txvalidready = ~usb_txe & txvalid;
wire  rxvalidready = ~usb_rxf & rxready;

assign usb_oe   = ~( (status==RXD) | (status==RXDOE) );
assign usb_wr   = ~( (status==TXD) & txvalidready );
assign usb_rd   = ~( (status==RXD) & rxvalidready );
assign usb_be   = usb_wr ? 'z : '1;
assign usb_data = usb_wr ? 'z : txdata;

stream_async_fifo #(   // tx async fifo
    .DSIZE        ( INPUT_DSIZE   ),
    .ASIZE        ( 8             )
) tx_async_fifo_i (
    .rst_n        ( fifos_rst_n   ),
    
    .iclk         ( iclk          ),
    .itvalid      ( itvalid       ),
    .itready      ( itready       ),
    .itdata       ( itdata        ),

    .oclk         ( usb_clk       ),
    .otready      ( tx_a2s_tready ),
    .otvalid      ( tx_a2s_tvalid ),
    .otdata       ( tx_a2s_tdata  )
);

stream_sync_fifo #(   // tx sync fifo
    .IDSIZE       ( INPUT_DSIZE   ),
    .ODSIZE       ( FTDI_DSIZE    ),
    .ASIZE        ( INPUT_ASIZE   )
) tx_sync_fifo_i (
    .rst_n        ( fifos_rst_n   ),
    .clk          ( usb_clk       ),
    
    .itvalid      ( tx_a2s_tvalid ),
    .itready      ( tx_a2s_tready ),
    .itdata       ( tx_a2s_tdata  ),
    
    .otready      ( ~usb_wr       ),
    .otdata       ( txdata        ),
    .otvalid      ( txvalid       ),
    
    .halffull     ( txfifo_sendimm)
);

stream_async_fifo #(   // rx async fifo
    .DSIZE        ( FTDI_DSIZE    ),
    .ASIZE        ( 8             )
) rx_async_fifo_i (
    .rst_n        ( rst_n         ),
    
    .iclk         ( usb_clk       ),
    .itvalid      ( ~usb_rd       ),
    .itready      ( rxready       ),
    .itdata       ( usb_data      ),

    .oclk         ( oclk          ),
    .otready      ( rx_a2s_tready ),
    .otvalid      ( rx_a2s_tvalid ),
    .otdata       ( rx_a2s_tdata  )
);

stream_sync_fifo #(   // rx sync fifo
    .IDSIZE       ( FTDI_DSIZE    ),
    .ODSIZE       ( OUTPUT_DSIZE  ),
    .ASIZE        ( OUTPUT_ASIZE  )
) rx_sync_fifo_i (
    .rst_n        ( rst_n         ),
    .clk          ( oclk          ),
    
    .itvalid      ( rx_a2s_tvalid ),
    .itready      ( rx_a2s_tready ),
    .itdata       ( rx_a2s_tdata  ),
    
    .otready      ( otready       ),
    .otvalid      ( otvalid       ),
    .otdata       ( otdata        )
);

// TXD or RXD controll FSM
always @ (posedge usb_clk or negedge rst_n)
    if(~rst_n) begin
        fsm_cnt<= '0;
        status <= RESET;
        tx_cnt  = '0;
    end else begin
        case(status)
        RESET: begin
            if(fsm_cnt>4'd8) begin
                fsm_cnt <= '0;
                status  <= IDLE;
            end else
                fsm_cnt <= fsm_cnt+4'd1;
        end
        IDLE: begin
            if(txvalidready && tx_cnt[15])
                status <= TXD;
            if(~usb_rxf)
                status <= RXDOE;
            else if(~usb_txe && txfifo_sendimm)
                status <= TXD;
            if(txvalidready)
                if(~tx_cnt[15]) tx_cnt++;
        end
        TXD: begin
            tx_cnt = '0;
            if(~usb_rxf | usb_txe)
                status <= IDLE;
        end
        RXDOE: begin
            tx_cnt = '0;
            if( usb_rxf)
                status <= IDLE;
            else
                status <= RXD;
        end
        RXD: begin
            tx_cnt = '0;
            if( usb_rxf)
                status <= IDLE;
        end
        endcase
    end

endmodule

