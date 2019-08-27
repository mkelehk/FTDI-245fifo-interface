// FT232H(USB2.0) massive data send demo

module ft232h_top(
    input  logic CLK,  // There is no specific limitation on CLK frequency
    
    output logic [3: 0]  LED,
    
    input  logic USB_CLK, USB_RXF, USB_TXE,
    output logic USB_OE,  USB_RD,  USB_WR,
    inout  [7:0] USB_D
);

localparam SEND_DSIZE = 1;  // User-specified SEND interface DATA width = 1 Byte. this parameter is NOT depend on FT232H chip, you can select 1, 2, 4 or 8...
localparam RECV_DSIZE = 1;  // User-specified RECV interface DATA width = 1 Byte. this parameter is NOT depend on FT232H chip, you can select 1, 2, 4 or 8...

// user send stream signals
logic itvalid=1'b0, itready;
logic [SEND_DSIZE*8-1:0] itdata = 0;

// user recv stream signals
logic otvalid, otready=1'b0;
logic [RECV_DSIZE*8-1:0] otdata;

always @ (posedge CLK) begin
    itvalid <= 1'b1;       // always try to send data in every clock cycle
    if(itvalid & itready)  // data increase when a word is sended successfully
        itdata++;
end

always @ (posedge CLK) begin
    otready <= 1'b1;       // always try to recv data in every clock cycle
    if(otvalid & otready)  // display data on LED when a word is recieved successfully
        LED <= otdata[3:0];
end

ftdi_245fifo #(
    .INPUT_DSIZE   ( SEND_DSIZE    ), // User-specified SEND interface DATA width(in bytes). this parameter is NOT depend on FT232H chip, you can select 1, 2, 4 or 8...
    .INPUT_ASIZE   ( 11            ), // 2^11 words in TX fifo is enough
    .OUTPUT_DSIZE  ( RECV_DSIZE    ), // User-specified RECV interface DATA width(in bytes). this parameter is NOT depend on FT232H chip, you can select 1, 2, 4 or 8...
    .OUTPUT_ASIZE  ( 9             ), // 2^ 9 words in RX fifo
    .FTDI_DSIZE    ( 1             )  // FT232H data bus is 8bit width
) ft232H_245fifo (
    .rst_n         ( 1'b1          ),
    // user send stream interface, clock domain = iclk, AXI-stream slave  liked
    .iclk          ( CLK           ),
    .itvalid       ( itvalid       ),
    .itready       ( itready       ),
    .itdata        ( itdata        ),
    // user recv stream interface, clock domain = oclk, AXI-stream master liked
    .oclk          ( CLK           ),
    .otvalid       ( otvalid       ),
    .otready       ( otready       ),
    .otdata        ( otdata        ),
    // FTDI USB interface, must connect to FT232H pins
    .usb_clk       ( USB_CLK       ),
    .usb_rxf       ( USB_RXF       ),
    .usb_txe       ( USB_TXE       ),
    .usb_oe        ( USB_OE        ),
    .usb_rd        ( USB_RD        ),
    .usb_wr        ( USB_WR        ),
    .usb_data      ( USB_D         )
);

endmodule
