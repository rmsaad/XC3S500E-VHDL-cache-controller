#!/bin/sh

# Clean up the results directory
rm -rf results
mkdir results

#Synthesize the Wrapper Files
echo 'Synthesizing XST wrapper file (core_top.vhd) with XST';
echo 'Synthesizing example design with XST';
xst -ifn xst.scr
cp bram_top.ngc ./results/


# Copy the netlist generated by Coregen
echo 'Copying files from the netlist directory to the results directory'
cp ../../bram.ngc results/

#  Copy the constraints files generated by Coregen
echo 'Copying files from constraints directory to results directory'
cp ../example_design/bram_top.ucf results/

cd results

echo 'Running ngdbuild'
ngdbuild -p xc3s500e-fg320-5 bram_top

echo 'Running map'
map bram_top -o mapped.ncd -pr i

echo 'Running par'
par mapped.ncd routed.ncd

echo 'Running trce'
trce -e 10 routed.ncd mapped.pcf -o routed

echo 'Running design through bitgen'
bitgen -w routed

echo 'Running netgen to create gate level VHDL model'
netgen -ofmt vhdl -sim -tm bram_top -pcf mapped.pcf -w routed.ncd routed.vhd
