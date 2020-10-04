#!/usr/bin/env python

import sys
sys.path.append('./src')

from difftime import TimeManager
from difftime.ttypes import *

from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol
from thrift import Thrift

try:
    transport = TSocket.TSocket('localhost', 9090)

    transport = TTransport.TBufferedTransport(transport)

    protocol = TBinaryProtocol.TBinaryProtocol(transport)

    client = TimeManager.Client(protocol)
    transport.open()
    print(client.get_time("Russia", "USA"))
    transport.close()

except Thrift.TException as tx:
    print(tx.message)
finally:
    transport.close()