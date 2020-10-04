import sys

from thrift import Thrift
from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol

sys.path.append('./src')

from currency import CurrencyManager
from currency.ttypes import *

try:
    transport = TSocket.TSocket('localhost', 9091)
    transport = TTransport.TBufferedTransport(transport)
    protocol = TBinaryProtocol.TBinaryProtocol(transport)
    client = CurrencyManager.Client(protocol)
    transport.open()
    print(client.convert("RUB", "USD", 100))
    transport.close()

except Thrift.TException as tx:
    print(tx.message)