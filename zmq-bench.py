#
#   Weather update client
#   Connects SUB socket to tcp://localhost:5556
#   Collects weather updates and finds avg temp in zipcode
#

import sys
import zmq

#  Socket to talk to server
context = zmq.Context()
socket = context.socket(zmq.PUB)

socket.bind('ipc:///tmp/zmq-py-bench')

buf = bytes('ohhai')
# Process 1000 updates
for i in range(100*1000*1000):
    socket.send(buf, 0)
