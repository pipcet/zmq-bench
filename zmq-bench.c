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
    sprintf(endpoint, "ipc:///tmp/zmq-c-bench-%d", p);

    assert( -1 != zmq_bind(socket, endpoint) );

    int major, minor, patch;
    zmq_version(&major, &minor, &patch);

    printf("C ZMQ Version: %d.%d.%d\n", major, minor, patch);

    for 