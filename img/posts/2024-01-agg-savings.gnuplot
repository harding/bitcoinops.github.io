set terminal pngcairo size 800,300

set style line 1 lc rgb 'black' lt 1 lw 3    # Black line style
set style line 2 lc rgb 'grey' lt 1 lw 3     # Grey line style

set key off  # Turn off the legend

savings(x, y) = ( (x - y) / x ) * 100

# All sizes for P2TR keypath from https://bitcoinops.org/en/tools/calc-size/
# 10.5 is overhead; 43 is output size
tx_size(inouts, input_size) = 10.5 + inouts * input_size + inouts * 43
# 57.5 is P2TR keypath spend, of which 16 bytes is the signature
unagg_size(inouts) = tx_size(inouts, 57.5)
# Half agg is n*8 + 8
halfagg_size(inouts) = tx_size(inouts, 57.5 - 8) + 8
# Full agg is n*0 + 16
fullagg_size(inouts) = tx_size(inouts, 57.5 - 16) + 16

#unset xtics
#unset ytics
set grid
set xtics 1
set ytics 4
set format y "%g%%"
set xlabel "Number of inputs (with an equal number of outputs, as in a prototypical coinjoin)"
set ylabel "Reduction in transaction size"

set label "Full aggregation" at 5,14.5
set label "Half aggregation" at 5,8

set xrange [1:10]
set yrange [0:17]
set output '2024-01-agg-savings.png'
#plot unagg_size(x) ls 1, halfagg_size(x) ls 2, fullagg_size(x) ls 3
plot savings(unagg_size(x), halfagg_size(x)) ls 2, savings(unagg_size(x), fullagg_size(x)) ls 1
