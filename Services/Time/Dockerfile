FROM ubuntu:18.04
RUN apt-get update -qq
RUN apt-get install -qqy python-pip
RUN pip install thrift

COPY ./gen-py ./gen-py
COPY ./time_service.py ./time_service.py

EXPOSE 9080

CMD ["python", "./time_service.py"]
