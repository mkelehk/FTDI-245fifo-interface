iverilog -g2012 -o target.vcd tb_ftdi_245fifo.sv ../RTL/*.sv
vvp -n target.vcd -lxt2
rename target.vcd target.lxt
gtkwave target.lxt
del target.lxt