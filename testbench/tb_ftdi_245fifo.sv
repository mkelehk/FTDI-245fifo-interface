`timescale 1ns/1ns

module tb_ftdi_245fifo();

// -----------------------------------------------------------------------------------------------------------------------------
// FT232H chip signals
// -----------------------------------------------------------------------------------------------------------------------------
logic USB_CLK=1'b0, USB_RXF, USB_TXE;
logic USB_OE,  USB_RD,  USB_WR;
tri   [7:0] USB_D;


// -----------------------------------------------------------------------------------------------------------------------------
// user signals(loopback)
// -----------------------------------------------------------------------------------------------------------------------------
localparam USER_DSIZE = 1;
logic clk=1'b0;
logic tvalid, tready;
logic [USER_DSIZE*8-1:0] tdata;
always #5 clk = ~clk;  // generate user clk, 100MHz.


// -----------------------------------------------------------------------------------------------------------------------------
// generate a simple FT232H behavior
// -----------------------------------------------------------------------------------------------------------------------------
logic [31:0] usb_cnt = 0;
logic [ 7:0] usb_rdata = '0;
always #8 USB_CLK = ~USB_CLK;  // generate USB_CLK, 60MHz.
assign USB_D = ~USB_OE ? usb_rdata : 7'hzz;
assign USB_RXF = (usb_cnt%97) > 19;
assign USB_TXE = (usb_cnt%53) > 43;
always @ (posedge USB_CLK)
    usb_cnt++;
    
always @ (posedge USB_CLK)
    if(~USB_RD)
        usb_rdata++;

        

// -----------------------------------------------------------------------------------------------------------------------------
// ftdi_245fifo module
// -----------------------------------------------------------------------------------------------------------------------------
ftdi_245fifo #(
    .INPUT_DSIZE   ( USER_DSIZE    ), // user write interface DATA width(in bytes). this parameter is NOT depend on FT232H chip, you can select 1, 2, 4 or 8...
    .INPUT_ASIZE   ( 5             ), // 2^5 depth for TX fifo
    .OUTPUT_DSIZE  ( USER_DSIZE    ), // user read  interface DATA width(in bytes). this parameter is NOT depend on FT232H chip, you can select 1, 2, 4 or 8...
    .OUTPUT_ASIZE  ( 5             ), // 2^5 depth for RX fifo
    .FTDI_DSIZE    ( 1             )  // FT232H data bus is 8bit width
) ftdi_245fifo_i (
    .rst_n         ( 1'b1          ),
    // user write interface, loopback connect to user read  interface
    .iclk          ( clk           ),
    .itvalid       ( tvalid        ),
    .itready       ( tready        ),
    .itdata        ( tdata         ),
    // user read  interface, loopback connect to user write interface
    .oclk          ( clk           ),
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


// -----------------------------------------------------------------------------------------------------------------------------
// simulation control
// -----------------------------------------------------------------------------------------------------------------------------
initial begin
    $dumpfile("target.vcd");
    $dumpvars(0, ftdi_245fifo_i);
    #900000 $stop;  // simulation stop time
end

endmodule
