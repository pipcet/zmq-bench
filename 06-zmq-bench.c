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

    for ( int i = 0; i < (10 * 1000 * 1000); i++ ) {
        assert( -1 != zmq_send(socket, "ohhai", strlen("ohhai"), 0) );
    }
}
