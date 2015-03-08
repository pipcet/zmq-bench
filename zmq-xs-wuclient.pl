use strict;
use warnings;
use v5.10;

use ZMQ::LibZMQ3;
use ZMQ::Constants qw(ZMQ_SUB ZMQ_SUBSCRIBE);
use zhelpers;

say 'Collecting updates from weather server...';

my $context = zmq_init();

my $subscriber = zmq_socket($context, ZMQ_SUB);
zmq_connect($subscriber, 'tcp://localhost:5556');

my $filter = @ARGV ? $ARGV[0] : '10001 ';
zmq_setsockopt($subscriber, ZMQ_SUBSCRIBE, $filter);

my $update_nbr = 100;
my $total_temp = 0;

my ($string, $zipcode, $temperature, $relhumidity);

for (1 .. $update_nbr) {
    $string = s_recv($subscriber);

    ($zipcode, $temperature, $relhumidity) = split ' ', $string;
    $total_temp += $temperature;
}

printf "Average temperature for zipcode '%s' was %dF\n",
    $filter, int($total_temp / $update_nbr);