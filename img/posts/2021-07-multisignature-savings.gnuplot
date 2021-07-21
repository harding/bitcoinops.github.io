#!/usr/bin/gnuplot

set style line 1 lc rgb '#8b1a0e' pt 4 ps 0.25 lt 1 lw 2
set style line 2 lc rgb '#5e9c36' pt 4 ps 0.25 lt 1 lw 2
set style line 3 lc rgb '#0025ad' pt 4 ps 0.25 lt 1 lw 2
set style line 4 lc rgb '#d95319' pt 4 ps 0.25 lt 1 lw 2

set terminal pngcairo size 800,200 font "Sans,12" transparent enhanced


unset border
#unset key
set key at 6,440
set key inside left top Right

set xtics 5
set ytics 100
set tics nomirror

set xlabel "Aggregate scriptPubKey and witness size for x signatures for x to 15 signers"
set ylabel "vbytes"
set xrange [1.1:15]
#unset xtics
#unset ytics
#set key horizontal tmargin Left reverse
#set samples 1000

#set style fill transparent solid 0.5 noborder

#              OP_1 PUSH Key   WitStackSize   ElementSize   Signature
keypath_vbytes = 1  + 1  + 32 + (1            + 1           + 64)/4.0
#                        OP_k  n*(PUSH key)  OP_n OP_CMS
witness_script_bytes(n) = 1  + n*(1  + 33) + 1  + 1

## Could be +/- a couple bytes due to PUSH_n vs PUSHDATA2
#                   OP_0 PUSH Hash WitStackSize k*(ElementSize sig)   ElementSize WitScript
p2wsh_vbytes(k,n) = 1  + 1  + 32 + (1         + k*(1          + 72) + 1 + witness_script_bytes(n))/4.0

set yrange [0:]

set output './2021-07-multisignature-savings.png'
plot "<for i in $( seq 1 15 ) ; do for ii in $( seq 1 $i ) ; do echo $ii $i ; done ; done" u 2:(p2wsh_vbytes($1, $2)) title "Scripted multisig" ls 1\
  ,  "<for i in $( seq 1 15 ) ; do for ii in $( seq 1 $i ) ; do echo $ii $i ; done ; done" u 2:(keypath_vbytes) title "Scriptless multisignatures" ls 2
