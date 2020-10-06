FROM ubuntu:18.04
RUN apt-get update -qq
RUN apt-get install -qqy python-pip
RUN pip install thrift

COPY ./gen-py ./gen-py
COPY ./country_server.py ./country_server.py

EXPOSE 9080

CMD ["python", "./country_server.py"]
