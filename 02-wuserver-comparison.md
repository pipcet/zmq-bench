### `wuserver.pl` Hot Spot Comparison (Devel::NYTProf) ###

#### FFI::Raw Implementation ####

    $self->_zmq3_ffi->{zmq_send}->($self->_socket, $msg, $length, $flags)
    # spent 19.9s making 1000000 calls to FFI::Raw::__ANON__[FFI/Raw.pm:94], avg 20µs/call
    # spent 5.72s making 2000000 calls to FFI::Raw::coderef, avg 3µs/call
    # spent 2.90s making 1000000 calls to ZMQ::FFI::ZMQ3::Socket::_zmq3_ffi, avg 3µs/call


#### FFI::Platypus Implementation ####

    zmq_send($socket, $msg, $length, $flags)
    # spent 1.33s making 1000000 calls to ZMQ::FFI::ZMQ3::Socket::zmq_send, avg 1µs/call

    sub ZMQ::FFI::ZMQ3::Socket::zmq_send; # xsub


#### XS Implementation (ZMQ::LibZMQ3) ####

    zmq_send($socket, $string, -1);
    # spent 1.23s making 1000000 calls to ZMQ::LibZMQ3::zmq_send, avg 1µs/call

    sub ZMQ::LibZMQ3::zmq_send; # xsub
