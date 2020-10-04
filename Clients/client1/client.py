import sys
sys.path.append('./src')

from country import CountryManager
from country.ttypes import *

from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol
from thrift import Thrift

try:
    transport = TSocket.TSocket('localhost', 9090)

    transport = TTransport.TBufferedTransport(transport)

    protocol = TBinaryProtocol.TBinaryProtocol(transport)

    client = CountryManager.Client(protocol)
    transport.open()

    country = client.get_country('USA')
    print("{}:\n\tCapital is {}\n\tCurrency is {}".format(country.name, country.capital, country.currency))

except Thrift.TException as tx:
    print(tx.message)
finally:
    transport.close()