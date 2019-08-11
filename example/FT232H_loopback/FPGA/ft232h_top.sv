//  FT232H(USB2.0) loopback demo

module ft232h_top(
    input  logic CLK,  // There is no specific limitation on CLK frequency
    
    output logic [3: 0]  LED,
    
    input  logic USB_CLK, USB_RXF, USB_TXE,
    output logic USB_OE,  USB_RD,  USB_WR,
    inout  [7:0] USB_D
);

localparam USER_DSIZE = 4; // user interface DATA width(in bytes), this parameter is NOT depend on FT232H chip, you can select 1, 2, 4 or 8...

logic tvalid, tready;
logic [USER_DSIZE*8-1:0] tdata;

always @ (posedge CLK)     //Display the received data on the LEDs
    if(tvalid & tready)
        LED <= tdata[3:0];

ftdi_245fifo #(
    .INPUT_DSIZE   ( USER_DSIZE    ), // user write interface DATA width(in bytes). this parameter is NOT depend on FT232H chip, you can select 1, 2, 4 or 8...
    .INPUT_ASIZE   ( 11            ), // 2^11 depth for TX fifo is enough
    .OUTPUT_DSIZE  ( USER_DSIZE    ), // user read  interface DATA width(in bytes). this parameter is NOT depend on FT232H chip, you can select 1, 2, 4 or 8...
    .OUTPUT_ASIZE  ( 9             ), // 2^ 9 depth for RX fifo
    .FTDI_DSIZE    ( 1             )  // FT232H data bus is 8bit width
) ft232H_245fifo (
    .rst_n         ( 1'b1          ),
    // user write interface
    .iclk          ( CLK           ),
    .itvalid       ( tvalid        ),
    .itready       ( tready        ),
    .itdata        ( tdata         ),
    // user read  interface
    .oclk          ( CLK           ),
    .otvalid       ( tvalid        ), 
    .otready       ( tready        ),
    .otdata        ( tdata         ),
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
