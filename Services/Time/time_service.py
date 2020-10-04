import sys

sys.path.append('./gen-py')

from difftime import TimeManager
from difftime.ttypes import *

from thrift import Thrift
from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol
from thrift.server import TServer

countries = {
    "Russia": {"Germani" : -1, "USA": -7},
    "Germani": {"Russia" : 1, "USA": -6},
    "USA": {"Germani" : 6, "Russia": 7}
}

class TimeManagerHandler:
	def __init__(self):
		pass
		#self.log = {}

	def get_time(self, country_1, country_2):
		if country_1 not in countries or country_2 not in countries[country_1]:
			raise Thrift.TApplicationException(TApplicationException.INVALID_MESSAGE_TYPE, "Unknown country")
		return countries[country_1][country_2]		

handler = TimeManagerHandler()
processor = TimeManager.Processor(handler)
transport = TSocket.TServerSocket(port=9090)
tfactory = TTransport.TBufferedTransportFactory()
pfactory = TBinaryProtocol.TBinaryProtocolFactory()

server = TServer.TSimpleServer(processor, transport, tfactory, pfactory)

# You could do one of these for a multithreaded server
#server = TServer.TThreadedServer(processor, transport, tfactory, pfactory)
#server = TServer.TThreadPoolServer(processor, transport, tfactory, pfactory)

print ('Starting the server...')
server.serve()
print ('done.')