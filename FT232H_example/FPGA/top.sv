
//--------------------------------------------------------------------------------------------------------
// Module  : top
// Type    : synthesizable, FPGA's top, IP's example design
// Standard: SystemVerilog 2005 (IEEE1800-2005)
// Function: an example of ftdi_245fifo, connect FT232H chip
//           send increase data from FT232H chip,
//           recv data from FT232H chip and check whether it is increasing
//--------------------------------------------------------------------------------------------------------

module top (
    input  wire         clk,   // main clock, 50MHz
    output wire         led,   // used to show whether the recv data meets expectations
    // USB2.0 HS (chip: FT232H)
    //output wire         usb_siwu,  // when this pin is exist and connect to FPGA, assign it to 1
    input  wire         usb_rxf, usb_txe, usb_clk,
    output wire         usb_oe, usb_rd, usb_wr,
    inout        [ 7:0] usb_d
);

// for power on reset
reg  [ 3:0] reset_shift = '0;
reg         rstn = '0;

// USB send data stream
wire        usbtx_valid;
wire        usbtx_ready;
reg  [63:0] usbtx_data = '0;

// USB recieved data stream
wire        usbrx_valid;
wire        usbrx_ready;
wire [ 7:0] usbrx_data;

reg  [ 7:0] expect_data = '0;
reg  [31:0] led_cnt = 0;
assign led = led_cnt == 0;


//------------------------------------------------------------------------------------------------------------
// power on reset
//------------------------------------------------------------------------------------------------------------
always @ (posedge clk)
    {rstn, reset_shift} <= {reset_shift, 1'b1};



//------------------------------------------------------------------------------------------------------------
// USB TX behavior
//------------------------------------------------------------------------------------------------------------
assign usbtx_valid = 1'b1;                   // always try to send
always @ (posedge clk or negedge rstn)
    if(~rstn) begin
        usbtx_data <= '0;
    end else begin
        if(usbtx_valid & usbtx_ready)            // if send success,
            usbtx_data <= usbtx_data + 64'd1;    //    send data + 1
    end



//------------------------------------------------------------------------------------------------------------
// USB RX behavior
//------------------------------------------------------------------------------------------------------------
assign usbrx_ready = 1'b1;                   // recv always ready
always @ (posedge clk or negedge rstn)
    if(~rstn) begin
        led_cnt <= 0;
        expect_data <= '0;
    end else begin
        if(led_cnt > 0)
            led_cnt <= led_cnt - 1;
        if(usbrx_valid & usbrx_ready) begin      // if recv success,
            if(expect_data != usbrx_data)        //    if the data does not meet expectations
                led_cnt <= 50000000;
            expect_data <= usbrx_data + 8'd1;
        end
    end


//------------------------------------------------------------------------------------------------------------
// USB TX and RX controller
//------------------------------------------------------------------------------------------------------------
ftdi_245fifo #(
    .TX_DEXP     ( 3           ), // TX data stream width,  0=8bit, 1=16bit, 2=32bit, 3=64bit, 4=128bit ...
    .TX_AEXP     ( 9           ), // TX FIFO depth = 2^TX_AEXP = 2^10 = 1024
    .RX_DEXP     ( 0           ), // RX data stream width,  0=8bit, 1=16bit, 2=32bit, 3=64bit, 4=128bit ...
    .RX_AEXP     ( 10          ), // RX FIFO depth = 2^RX_AEXP = 2^10 = 1024
    .C_DEXP      ( 0           )  // FTDI USB chip data width, 0=8bit, 1=16bit, 2=32bit ... for FT232H is 0, for FT600 is 1, for FT601 is 2.
) usb_rx_tx_i (
    .rstn_async  ( rstn        ),
    .tx_clk      ( clk         ),
    .tx_valid    ( usbtx_valid ),
    .tx_ready    ( usbtx_ready ),
    .tx_data     ( usbtx_data  ),
    .rx_clk      ( clk         ),
    .rx_valid    ( usbrx_valid ), 
    .rx_ready    ( usbrx_ready ),
    .rx_data     ( usbrx_data  ),
    .usb_clk     ( usb_clk     ),
    .usb_rxf     ( usb_rxf     ),
    .usb_txe     ( usb_txe     ),
    .usb_oe      ( usb_oe      ),
    .usb_rd      ( usb_rd      ),
    .usb_wr      ( usb_wr      ),
    .usb_data    ( usb_d       ),
    .usb_be      (             )  // FT232H do not have USB_BE pins
);

// assign usb_siwu = 1'b1;  // while working, usb_siwu=1, means send immidiently


endmodule
