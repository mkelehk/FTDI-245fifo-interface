
module ft600_top(
    // CLK must less than 200MHz, RST_N active low
    input  CLK, RST_N,
    
    output reg [15: 0]  LED,
    
    input  USB_RXF, USB_TXE, USB_CLK,
    output USB_OE, USB_RD, USB_WR,
    output [ 1: 0] USB_BE,
    inout  [15: 0] USB_D
);

logic send_gnt;
logic [15:0] send_data = 0;
logic recv_gnt;
logic [15:0] recv_data;

always @ (posedge CLK)
    if(send_gnt) // send_data increase when a word is sended successfully
        send_data++;

always @ (posedge CLK)
    if(recv_gnt) // display data on LED when a word is recieved successfully
        LED <= recv_data;

ftdi_245fifo #(
    .USER_WRITE_DSIZE ( 16            ), // user write interface DATA width. this value is NOT depend on FT600 chip, you can select 8, 16, 32 or 64...
    .USER_READ_DSIZE  ( 16            ), // user read  interface DATA width. this value is NOT depend on FT600 chip too.
    .FTDI_DSIZE       ( 16            ), // FT600 data bus is 16bit width
    .WRITE_FIFO_ASIZE ( 14            ), // 2^14 words in TX fifo is enough
    .READ_FIFO_ASIZE  ( 9             )  // 2^ 9 words in RX fifo
) ft600_245fifo (
    .rst_n            ( RST_N         ),
    // user write interface, clock domain = wr_clk = CLK
    .wr_clk           ( CLK           ),
    .wr_req           ( 1'b1          ), // always try to send in every clock cycle
    .wr_gnt           ( send_gnt      ), // when high, the send_data is accept
    .wr_data          ( send_data     ), // width = USER_WRITE_DSIZE
    // user read  interface, clock domain = rd_clk = CLK
    .rd_clk           ( CLK           ),
    .rd_req           ( 1'b1          ), // always try to read data in every clock cycle
    .rd_gnt           ( recv_gnt      ), // when high, the recv_data is available
    .rd_data          ( recv_data     ),
    // FTDI USB interface
    .usb_clk          ( USB_CLK       ),
    .usb_rxf          ( USB_RXF       ),
    .usb_txe          ( USB_TXE       ),
    .usb_wr           ( USB_WR        ),
    .usb_rd           ( USB_RD        ),
    .usb_oe           ( USB_OE        ),
    .usb_be           ( USB_BE        ), // for FT600, you must connect BE signals. this signal is ignored when using FT232H
    .usb_data         ( USB_D         )
);

endmodule
