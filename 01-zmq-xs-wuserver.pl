use strict;
use warnings;

use ZMQ::LibZMQ3;
use ZMQ::Constants qw(ZMQ_PUB);
use zhelpers;

my $context   = zmq_init();
my $publisher = zmq_socket($context, ZMQ_PUB);
zmq_bind($publisher, 'tcp://*:5556');

my ($zipcode, $temperature, $relhumidity, $update);

# for (1..1_000_000) { # publish constant number when profiling
while (1) {
    $zipcode     = rand(100_000);
    $temperature = rand(215) - 80;
    $relhumidity = rand(50) + 10;

    $update = sprintf(
        '%05d %d %d',
        $zipcode,$temperature,$relhumidity
    );

    s_send($publisher, $update);
}