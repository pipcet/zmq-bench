#
# Directly compare FFI::Platypus vs XS xsubs
#

use strict;
use warnings;
use v5.10;

use FFI::Platypus::Declare;
use ZMQ::LibZMQ3;

use ZMQ::FFI::Constants qw(:all);

use Benchmark qw(:all);

lib 'libzmq.so';

attach(
    ['zmq_ctx_new' => 'zmqffi_ctx_new']
        => [] => 'pointer'
);

attach(
    ['zmq_socket' => 'zmqffi_socket']
        => ['pointer', 'int'] => 'pointer'
);

attach(
    ['zmq_bind' => 'zmqffi_bind']
        => ['pointer', 'string'] => 'int'
);

attach(
    ['zmq_send' => 'zmqffi_send']
        => ['pointer', 'string', 'size_t', 'int'] => 'int'
);

attach(
    ['zmq_version' => 'zmqffi_version'] 
        => ['int*', 'int*', 'int*'] => 'void'
);

my $ffi_ctx = zmqffi_ctx_new();
die 'ffi ctx error' unless $ffi_ctx;

my $ffi_socket = zmqffi_socket($ffi_ctx, ZMQ_PUB);
die 'ffi socket error' unless $ffi_socket;

my $rv;

$rv = zmqffi_bind($ffi_socket, "ipc:///tmp/zmq-ffi-bench-$$");
die 'ffi bind error' if $rv == -1;

my $xs_ctx = zmq_ctx_new();
die 'xs ctx error' unless $xs_ctx;

my $xs_socket = zmq_socket($xs_ctx, ZMQ_PUB);
die 'xs socket error' unless $xs_socket;

$rv = zmq_bind($xs_socket, "ipc:///tmp/zmq-xs-bench-$$");
die 'xs bind error' if $rv == -1;


my ($major, $minor, $patch);
zmqffi_version(\$major, \$minor, \$patch);

say "FFI ZMQ Version: " . join(".", $major, $minor, $patch);
say "XS  ZMQ Version: " . join(".", ZMQ::LibZMQ3::zmq_version());


my $r = timethese 10_000_000, {
    'XS'  => sub {
        die 'xs send error ' if -1 == zmq_send($xs_socket, 'ohhai', 5, 0);
    },

    'FFI' => sub {
        die 'ffi send error' if -1 == zmqffi_send($ffi_socket, 'ohhai', 5, 0);
    },
};

cmpthese($r);

__END__

# results

### Benchmark.pm ###

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

$ time perl bench/zmq-bench.pl
XS ZMQ Version: 4.0.5

real    0m3.539s
user    0m3.507s
sys     0m0.020s

