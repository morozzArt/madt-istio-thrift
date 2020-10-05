# madt-istio-thrift

1. Скачайте и запустите MADT:

```
cd ~
git clone --recursive https://github.com/dltcspbu/madt/
mkdir ~/madt/labs && export MADT_LABS_DIR=$HOME/madt/labs
mkdir ~/madt/sockets && export MADT_LABS_SOCKETS_DIR=$HOME/madt/sockets

cd madt
sudo pip3 install -r ./requirements.txt
sudo make && sudo make install

sudo -HE env PYTHONPATH=$HOME/madt:$PYTHONPATH SSH_PWD=demo python3 madt_ui/main.py 80
```

2. Перейдите в директорию `./tutorials`, склонируйте данный проект, соберите образ и запустите lab.py:

```
#open new terminal window
cd ~/madt/tutorials
git clone https://github.com/morozzArt/madt-istio-thrift
docker build -t lab/mit .
python3 ./lab.py
```

3. Перейдите на 127.0.0.1:80, для login используйте: `demo:demo`
4. Выберите сеть и нажмите кнопку `restart`
5. Далее создайте 3 новых окна терминала и зайдите в них под root `sudo -s`
6.
```
#in new terminal №1
docker exec -it MADT_kind_Node0 /bin/bash
wrapdocker
bash scripts/pull_image.sh
kind create cluster --image kindest/node:v1.18.2 --config=/configs/config_cluster1.yaml --name kind-1
cd Client/super_client
docker build -t client/client .
cd Services/Country
docker build -t serv/country .
bash /scripts/cluster1.sh
```
```
#in new terminal №2
docker exec -it MADT_kind_Node1 /bin/bash
wrapdocker
bash scripts/pull_image.sh
kind create cluster --image kindest/node:v1.18.2 --config=/configs/config_cluster2.yaml --name kind-2
cd Services/Currency
docker build -t serv/currency .
bash /scripts/cluster2.sh
```
```
#in new terminal №3
docker exec -it MADT_kind_Node2 /bin/bash
wrapdocker
bash scripts/pull_image.sh
kind create cluster --image kindest/node:v1.18.2 --config=/configs/config_cluster2.yaml --name kind-3
cd Services/Time
docker build -t serv/time .
bash /scripts/cluster3.sh
```

7. Скопируем конфиги из наших контейнеров в хост, для этого откроем еще одно окно терминала и перейдем в директорию с данным проектом:
```
bash copy_configs
```
8. Проверяем работоспособность:
```
# in terminal with MADT_kind_Node0
bash /scripts/finalize.sh
```