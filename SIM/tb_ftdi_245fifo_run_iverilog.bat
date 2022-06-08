del sim.out dump.vcd
iverilog  -g2005-sv  -o sim.out  tb_ftdi_245fifo.sv  ../RTL/ftdi_245fifo.sv  ../RTL/stream_async_fifo.sv  ../RTL/stream_wtrans.sv
vvp -n sim.out
del sim.out
pause