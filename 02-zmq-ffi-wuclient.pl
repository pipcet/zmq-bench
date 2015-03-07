use strict;
use warnings;
use v5.10;

use ZMQ::FFI;
use ZMQ::FFI::Constants qw(ZMQ_SUB);

say "Collecting updates from weather station...";

my $context = ZMQ::FFI->new();
my $subscriber = $context->socket(ZMQ_SUB);
$subscriber->connect("tcp://localhost:5556");

my $filter = $ARGV[0] // "10001 ";
$subscriber->subscribe($filter);

my $update_nbr = 100;
my $total_temp = 0;

my ($string, $zipcode, $temperature, $relhumidity);

for (1..$update_nbr) {
    $string = $subscriber->recv();

    ($zipcode, $temperature, $relhumidity) = split ' ', $string;
    $total_temp += $temperature;
}

printf "Average temperature for zipcode '%s' was %dF\n",
    $filter, int($total_temp / $update_nbr);
