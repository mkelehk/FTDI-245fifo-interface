`timescale 1ns/1ns

module tb_ftdi_245fifo();

// -----------------------------------------------------------------------------------------------------------------------------
// user signals(loopback)
// -----------------------------------------------------------------------------------------------------------------------------
localparam USER_DEXP = 1;
logic clk=1'b0;
logic tvalid, tready;
logic [(8<<USER_DEXP)-1:0] tdata;
always #5 clk = ~clk;  // generate user clk, 100MHz.


// -----------------------------------------------------------------------------------------------------------------------------
// generate a simple FT232H behavior
// -----------------------------------------------------------------------------------------------------------------------------
logic USB_CLK=1'b0, USB_RXF, USB_TXE;
logic USB_OE,  USB_RD,  USB_WR;
tri   [ 7:0] USB_D;
logic [31:0] usb_clk_cnt = 0;
logic [ 7:0] usb_rdata = '0;
always #8 USB_CLK = ~USB_CLK;  // generate USB_CLK, approximately 60MHz.
assign USB_D = ~USB_OE ? usb_rdata : 'z;
assign USB_RXF = (usb_clk_cnt%97) > 19;
assign USB_TXE = (usb_clk_cnt%53) > 43;
always @ (posedge USB_CLK)
    usb_clk_cnt <= usb_clk_cnt + 1;
always @ (posedge USB_CLK)
    if(~USB_RD & ~USB_RXF)
        usb_rdata <= usb_rdata + 8'd1;

        

// -----------------------------------------------------------------------------------------------------------------------------
// ftdi_245fifo module
// -----------------------------------------------------------------------------------------------------------------------------
ftdi_245fifo #(
    .TX_DEXP       ( USER_DEXP     ),
    .TX_AEXP       ( 10            ),
    .RX_DEXP       ( USER_DEXP     ),
    .RX_AEXP       ( 10            ),
    .C_DEXP        ( 0             )
) ftdi_245fifo_i (
    .rstn          ( 1'b1          ),
    // user write interface, loopback connect to user read  interface
    .tx_clk        ( clk           ),
    .tx_valid      ( tvalid        ),
    .tx_ready      ( tready        ),
    .tx_data       ( tdata         ),
    // user read  interface, loopback connect to user write interface
    .rx_clk        ( clk           ),
    .rx_valid      ( tvalid        ), 
    .rx_ready      ( tready        ),
    .rx_data       ( tdata         ),
    // FTDI USB interface, must connect to FT232H pins
    .usb_clk       ( USB_CLK       ),
    .usb_rxf       ( USB_RXF       ),
    .usb_txe       ( USB_TXE       ),
    .usb_oe        ( USB_OE        ),
    .usb_rd        ( USB_RD        ),
    .usb_wr        ( USB_WR        ),
    .usb_data      ( USB_D         ),
    .usb_be        (               )
);


// -----------------------------------------------------------------------------------------------------------------------------
// simulation control
// -----------------------------------------------------------------------------------------------------------------------------
initial begin
    $dumpfile("target.vcd");
    $dumpvars(0, ftdi_245fifo_i);
    #900000 $stop;  // simulation stop time
end

endmodule
