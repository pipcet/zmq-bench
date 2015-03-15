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
i=0
while True:
    i+=1
    socket.send(buf, 0)
    if i == 10*1000*1000:
        exit(0)
