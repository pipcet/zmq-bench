#
# should run for about 50 seconds.
#

use strict;
use warnings;
use v5.10;
use ZMQ::LibZMQ3;
use ZMQ::FFI::Constants qw(:all);

my $rv;

my $xs_ctx = zmq_ctx_new();
die 'xs ctx error' unless $xs_ctx;

my $xs_socket = zmq_socket($xs_ctx, ZMQ_PUB);
die 'xs socket error' unless $xs_socket;

$rv = zmq_bind($xs_socket, "ipc:///tmp/zmq-xs-bench-$$");
die 'xs bind error' if $rv == -1;

my $i;
while(1) {
  $i++;
  die if -1 == zmq_send($xs_socket, 'ohhai', 5, 0);
  exit if $i == 10_000_000;
}
