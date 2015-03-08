### ØMQ Perl Performance Comparison: FFI vs XS bindings ###

Comparison of the performance of FFI vs XS zeromq bindings.  For FFI the
`ZMQ::FFI` bindings are used, first using `FFI::Raw` on the backend and then
using `FFI::Platypus`.  For XS `ZMQ::LibZMQ3` is used.

Comparison is done using the zeromq weather station example, first by timing
wuclient.pl using the various implementations, and then by profiling
wuserver.pl using `Devel::NYTProf`.  When profiling the server is changed to
simply publish 1 million messages and exit.

Weather station example code was lightly optimized (e.g. don't declare vars in
loop) and modified to be more consistent.

Additionally, a more direct benchmark and comparison of `FFI::Platypus` vs XS
xsubs is also done.

C and Python implementation results are also provided as a baseline for
performance.

All the code that was created or modified for these benchmarks is listed at
the end (C/Python wuclient/wuserver code can be found in the [zmq guide](http://zguide.zeromq.org/page:all#toc13)).

#### Test box ####
    CPU:  Intel Core Quad i7-2600K CPU @ 3.40GHz
    Mem:  4GB
    OS:   Arch Linux
    ZMQ:  4.0.5
    Perl: 5.20.1

    ZMQ::FFI      = 0.19 (FFI::Raw backend), dev (FFI::Platypus backend)
    FFI::Raw      = 0.32
    FFI::Platypus = 0.31
    ZMQ::LibZMQ3  = 1.19

