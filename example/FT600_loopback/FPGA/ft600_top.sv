// FT600(USB3.0) loopback demo

module ft600_top(
    input  logic CLK,   // There is no specific limitation on CLK frequency
    
    output logic [7:0]  LED,
    
    // FT600 pins
    input  logic USB_CLK, USB_RXF, USB_TXE,
    output logic USB_OE,  USB_RD,  USB_WR,
    inout  [15:0] USB_D,
    inout  [ 1:0] USB_BE
);

localparam USER_DSIZE = 4; // user interface DATA width(in bytes), this parameter is NOT depend on FT600 chip, you can select 1, 2, 4 or 8...

logic tvalid, tready;
logic [USER_DSIZE*8-1:0] tdata;

always @ (posedge CLK)     //Display the received data on the LEDs
    if(tvalid & tready)
        LED <= tdata[7:0];

ftdi_245fifo #(
    .INPUT_DSIZE   ( USER_DSIZE    ), // user write interface DATA width(in bytes). this parameter is NOT depend on FT600 chip, you can select 1, 2, 4 or 8...
    .INPUT_ASIZE   ( 11            ), // 2^11 depth for TX fifo is enough
    .OUTPUT_DSIZE  ( USER_DSIZE    ), // user read  interface DATA width(in bytes). this parameter is NOT depend on FT600 chip, you can select 1, 2, 4 or 8...
    .OUTPUT_ASIZE  ( 9             ), // 2^ 9 depth for RX fifo
    .FTDI_DSIZE    ( 2             )  // FT600 data bus is 16bit width
) ft232H_245fifo (
    .rst_n         ( 1'b1          ),
    // user send interface, connect to 
    .iclk          ( CLK           ),
    .itvalid       ( tvalid        ),
    .itready       ( tready        ),
    .itdata        ( tdata         ),
    // user recv interface
    .oclk          ( CLK           ),
    .otvalid       ( tvalid        ), 
    .otready       ( tready        ),
    .otdata        ( tdata         ),
    // FTDI USB interface, must connect to FT600 pins
    .usb_clk       ( USB_CLK       ),
    .usb_rxf       ( USB_RXF       ),
    .usb_txe       ( USB_TXE       ),
    .usb_oe        ( USB_OE        ),
    .usb_rd        ( USB_RD        ),
    .usb_wr        ( USB_WR        ),
    .usb_data      ( USB_D         ),
    .usb_be        ( USB_BE        )
);

endmodule
