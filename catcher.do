vlib work
vlog -timescale 1ns/1ns LedTop.v cube.v uart.v RNG.v draw_gameover.v game_over_ROM.v
vsim -L altera_mf_ver -t 1ns LedTop


log -r {/*}
add wave {/*}

force CLOCK_50 1 0, 0 {2 ns} -r 5

force {KEY[3]} 0
force {KEY[0]} 1
run 1000ns

force {KEY[3]} 1
force {KEY[0]} 0
run 100ns

force {KEY[0]} 1
run 200ms