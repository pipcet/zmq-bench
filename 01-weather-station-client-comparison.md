### `wuclient.pl` Time Comparison ###

#### FFI::Raw Implementation ####

    $ perl wuserver.pl &
    $ time perl wuclient.pl
    Collecting updates from weather station...
    Average temperature for zipcode '10001 ' was 21F

    real    1m22.818s
    user    0m0.070s
    sys     0m0.023s


#### FFI::Platypus Implementation ####

    $ perl wuserver.pl &
    $ time perl wuclient.pl
    Collecting updates from weather station...
    Average temperature for zipcode '10001 ' was 38F

    real    0m12.813s
    user    0m0.083s
    sys     0m0.033s


#### XS Implementation (ZMQ::LibZMQ3) ####

    $ perl wuserver.pl &
    $ time perl wuclient.pl
    Collecting updates from weather server...
    Average temperature for zipcode '10001 ' was 34F

    real    0m10.051s
    user    0m0.017s
    sys     0m0.010s
