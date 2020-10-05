import sys
sys.path.append('./src')

from country import CountryManager
from country.ttypes import *

from country import CurrencyManager

from country import TimeManager

from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol
from thrift import Thrift



from http.server import BaseHTTPRequestHandler,HTTPServer

PORT_NUMBER = 9080

# This class will handle any incoming request from
# a browser 
class myHandler(BaseHTTPRequestHandler):

    # Handler for the GET requests
    def do_GET(self):
        print   ('Get request received')
        self.send_response(200)
        self.send_header('Content-type','text/html')
        self.end_headers()
        # Send the html message

        try:
            transport = TSocket.TSocket('localhost', 9090)

            transport = TTransport.TBufferedTransport(transport)

            protocol = TBinaryProtocol.TBinaryProtocol(transport)

            client = CountryManager.Client(protocol)
            transport.open()

            country = client.get_country('USA')
            print("{}:\n\tCapital is {}\n\tCurrency is {}".format(country.name, country.capital, country.currency))

            self.wfile.write(str.encode("{}:\n\tCapital is {}\n\tCurrency is {}".format(country.name, country.capital, country.currency))) 
        except Thrift.TException as tx:
            print(tx.message)
        finally:
            transport.close()

        try:
            transport = TSocket.TSocket('localhost', 9091)
            transport = TTransport.TBufferedTransport(transport)
            protocol = TBinaryProtocol.TBinaryProtocol(transport)
            client = CurrencyManager.Client(protocol)
            transport.open()
            print(client.convert("RUB", "USD", 100))
            self.wfile.write(str.encode(str(client.convert("RUB", "USD", 100))))
            transport.close()

        except Thrift.TException as tx:
            print(tx.message)
        finally:
            transport.close()

        try:
            transport = TSocket.TSocket('localhost', 9092)

            transport = TTransport.TBufferedTransport(transport)

            protocol = TBinaryProtocol.TBinaryProtocol(transport)

            client = TimeManager.Client(protocol)
            transport.open()
            print(client.get_time("Russia", "USA"))
            self.wfile.write(str.encode(str(client.get_time("Russia", "USA")))           )
            transport.close()

        except Thrift.TException as tx:
            print(tx.message)
        finally:
            transport.close()

        return

try:
    # Create a web server and define the handler to manage the
    # incoming request
    server = HTTPServer(('', PORT_NUMBER), myHandler)
    print ('Started httpserver on port ' , PORT_NUMBER)

    # Wait forever for incoming http requests
    server.serve_forever()

except KeyboardInterrupt:
    print ('^C received, shutting down the web server')
    server.socket.close()