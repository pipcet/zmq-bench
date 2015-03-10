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

# Process 1000 updates
for i in range(10*1000*1000):
    socket.send('ohhai', 0, True)
