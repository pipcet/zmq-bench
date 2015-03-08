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


#### C Reference Implementation ####

    $ ./wuserver &
    $ time ./wuclient
    Collecting updates from weather server...
    Average temperature for zipcode '10001 ' was 26F

    real    0m2.842s
    user    0m0.000s
    sys     0m0.023s

#### Python Reference Implementation ####

    Python: 3.4.2
    PyZMQ:  14.5.0

I was initially impressed with the performance of the Python example:

    $ python wuserver.py &
    $ time python wuclient.py
    Collecting updates from weather server...
    Average temperature for zipcode '10001' was 49F

    real    0m4.599s
    user    0m0.063s
    sys     0m0.020s

Wow, that's almost as fast as C!  But then I noticed:

```python
# Process 5 updates
total_temp = 0
for update_nbr in range(5)
    ...
```

So where the C and Perl implementations are processing 100 updates, the Python
version only processes 5, or **1/20** as many. What about if we use 100
updates like the other languages?

    $ python wuserver.py &
    $ time python wuclient.py
    Collecting updates from weather server...
    Average temperature for zipcode '10001' was 17F

    real    1m41.108s
    user    0m0.077s
    sys     0m0.017s

If nothing else, at least the Perl bindings blow the doors off the Python
ones :)
