use strict;
use warnings;
use v5.10;

use FFI::Platypus::Declare;
use ZMQ::LibZMQ3;

use ZMQ::FFI::Constants qw(:all);

use Benchmark qw(:all);

lib 'libzmq.so';

attach(
    ['zmq_ctx_new' => 'zmqffi_ctx_new'] => [] => 'pointer'
);

attach(
    ['zmq_socket' => 'zmqffi_socket'] => ['pointer', 'int'] => 'pointer'
);

attach(
    ['zmq_bind' => 'zmqffi_bind'] => ['pointer', 'string'] => 'int'
);

attach(
    ['zmq_send' => 'zmqffi_send'] => ['pointer', 'string', 'int'] => 'int'
);

attach(
    ['zmq_version' => 'zmqffi_version'] => ['int*', 'int*', 'int*'] => 'void'
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

$rv = zmq_bind($xs_socket, "ipc:///tmp/xs-bench-$$");
die 'xs bind error' if $rv == -1;


my ($major, $minor, $patch);
zmqffi_version(\$major, \$minor, \$patch);

say "FFI ZMQ Version: " . join(".", $major, $minor, $patch);
say "XS  ZMQ Version: " . join(".", ZMQ::LibZMQ3::zmq_version());


my $r = timethese 10_000_000, {
    'XS'  => sub {
        die 'xs send error ' if -1 == zmq_send($xs_socket, 'ohhai', -1)
    },

    'FFI' => sub {
        die 'ffi send error' if -1 == zmqffi_send($ffi_socket, 'ohhai', 0);
    },
};

cmpthese($r);

__END__

RESULT
------
FFI ZMQ Version: 4.0.5
XS  ZMQ Version: 4.0.5
Benchmark: timing 10000000 iterations of FFI, XS...
       FFI:  4 wallclock secs ( 2.85 usr +  0.00 sys =  2.85 CPU) @ 3508771.93/s (n=10000000)
        XS:  3 wallclock secs ( 2.28 usr +  0.00 sys =  2.28 CPU) @ 4385964.91/s (n=10000000)
         Rate  FFI   XS
FFI 3508772/s   -- -20%
XS  4385965/s  25%   --
