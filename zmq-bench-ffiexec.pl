#
# should run for about 50 seconds.
#

use strict;
use warnings;
use v5.10;
use ZMQ::FFI::Constants qw(:all);
use FFI::TinyCC;
use FFI::Platypus::Declare;
use Carp::Always;

lib 'libzmq.so';

attach(
    ['zmq_bind' => 'zmqffi_bind']
	=> ['pointer', 'string'] => 'int'
);


attach(
    ['zmq_ctx_new' => 'zmqffi_ctx_new']
	=> [] => 'pointer'
);

attach(
    ['zmq_socket' => 'zmqffi_socket']
	=> ['pointer', 'int'] => 'pointer'
);

attach(
  ['zmq_send' => 'zmqffi_send']
  => ['pointer', 'string', 'size_t', 'int'] => 'int',
    );

attach(
    ['zmq_version' => 'zmqffi_version']
	=> ['int*', 'int*', 'int*'] => 'void'
);

our $ffi_ctx = main::zmqffi_ctx_new();
die 'ffi ctx error' unless $ffi_ctx;

our $ffi_socket = main::zmqffi_socket($ffi_ctx, ZMQ_PUB);
die 'ffi socket error' unless $ffi_socket;

my $rv;

$rv = zmqffi_bind($ffi_socket, "ipc:///tmp/zmq-ffi-bench-$$");
die 'ffi bind error' if $rv == -1;

my ($major, $minor, $patch);
zmqffi_version(\$major, \$minor, \$patch);

say "FFI ZMQ Version: " . join(".", $major, $minor, $patch);

my $i;
while(1) {
  $i++;
  die if -1 == zmqffi_send($ffi_socket, 'ohhai', 5, 0);
  exit if $i == 10_000_000;
}
