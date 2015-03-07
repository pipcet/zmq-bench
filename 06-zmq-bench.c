#include <zmq.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <assert.h>
#include <string.h>

int main(void)
{
    void *ctx = zmq_ctx_new();
    assert(ctx);

    void *socket = zmq_socket(ctx, ZMQ_PUB);
    assert(socket);

    pid_t p = getpid();

    char *endpoint = malloc(256);
    sprintf(endpoint, "ipc:///tmp/c-zmq-bench-%d", p);

    assert( -1 != zmq_bind(socket, endpoint) );

    int major, minor, patch;
    zmq_version(&major, &minor, &patch);

    printf("C ZMQ Version: %d.%d.%d\n", major, minor, patch);

    for ( int i = 0; i < (10 * 1000 * 1000); i++ ) {
        assert( -1 != zmq_send(socket, "ohhai", 5, 0) );
    }
}

/*

OUTPUT
------
$ time /tmp/zmq-bench-c
C ZMQ Version: 4.0.5

real    0m0.594s
user    0m0.570s
sys     0m0.017s

$ echo '10000000 / 0.594' | bc -lq
16835016.83501683501683501683 # Rate

*/
