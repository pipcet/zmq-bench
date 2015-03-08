### Benchmark.pm results ###

$ perl zmq-bench.pl
FFI ZMQ Version: 4.0.5
XS  ZMQ Version: 4.0.5

Benchmark: timing 10000000 iterations of FFI, XS...
       FFI:  4 wallclock secs ( 3.31 usr +  0.01 sys =  3.32 CPU) @ 3012048.19/s (n=10000000)
        XS:  2 wallclock secs ( 2.16 usr +  0.00 sys =  2.16 CPU) @ 4629629.63/s (n=10000000)

         Rate   FFI    XS     C
FFI 3012048/s    --  -35%  -82%
XS  4629630/s   54%    --  -73%
C* 16835017/s  559%  364%    --

*I wrote equivalent code in C and timed it (see below), just 'faking' the
results into the table so it's easy to compare a baseline

$ time zmq-bench-c
C ZMQ Version: 4.0.5

real    0m0.594s
user    0m0.570s
sys     0m0.017s

$ echo '10000000 / 0.594' | bc -lq
16835016.835 # Rate


# For profiling and timing in the shell below send in a for loop instead of via Benchmark

### Devel::NYTProf profiling data ###

# spent 15.5s within main::zmqffi_send which was called 10000000 times, avg 2µs/call: # 10000000 times (15.5s+0s) by main::RUNTIME at line 68, avg 2µs/call
sub main::zmqffi_send; # xsub

# spent 15.6s within ZMQ::LibZMQ3::zmq_send which was called 10000000 times, avg 2µs/call: # 10000000 times (15.6s+0s) by main::RUNTIME at line 67 of zmq-bench.pl, avg 2µs/call
sub ZMQ::LibZMQ3::zmq_send; # xsub


Q: Why does the profiler indicate basically identical performance of the xsubs,
but Benchmark reports substantial performance difference?

A: ???


### shell time zmq-bench.pl ###

$ time perl bench/zmq-bench.pl
FFI ZMQ Version: 4.0.5

real    0m3.541s
user    0m3.510s
sys     0m0.027s

$ echo '10000000 / 3.541' | bc -lq
2824060.999 # Rate

$ time perl bench/zmq-bench.pl
XS ZMQ Version: 4.0.5

real    0m2.390s
user    0m2.363s
sys     0m0.020s

$ echo '10000000 / 2.390' | bc -lq
4184100.418 # Rate