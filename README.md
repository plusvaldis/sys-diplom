#  Дипломная работа по профессии «Системный администратор»

Содержание
==========
* [Задача](#Задача)
* [Адреса для подключения](#Адреса-для-подключения)
* [Инфраструктура](#Инфраструктура)
    * [Сайт](#Сайт)
    * [Мониторинг](#Мониторинг)
    * [Логи](#Логи)
    * [Сеть](#Сеть)
    * [Резервное копирование](#Резервное-копирование)

---------
## Задача
Ключевая задача — разработать отказоустойчивую инфраструктуру для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных. Инфраструктура должна размещаться в [Yandex Cloud](https://cloud.yandex.com/).

## Адреса для подключения  
Grafana: [51.250.27.103:3000](http://51.250.27.103:3000/) user/useruser  
Kibana: [158.160.12.150:5601](http://158.160.12.150:5601/) admin/administrator  
Для удобства подключил [Elasticsearch в Grafana](http://158.160.22.130:3000/explore?orgId=1&left=%7B%22datasource%22:%22wH7fuHUVk%22,%22queries%22:%5B%7B%22refId%22:%22A%22,%22datasource%22:%7B%22type%22:%22elasticsearch%22,%22uid%22:%22wH7fuHUVk%22%7D,%22query%22:%22%22,%22alias%22:%22%22,%22metrics%22:%5B%7B%22type%22:%22count%22,%22id%22:%221%22%7D%5D,%22bucketAggs%22:%5B%7B%22type%22:%22date_histogram%22,%22id%22:%222%22,%22settings%22:%7B%22interval%22:%22auto%22%7D,%22field%22:%22@timestamp%22%7D%5D,%22timeField%22:%22@timestamp%22%7D%5D,%22range%22:%7B%22from%22:%22now-1h%22,%22to%22:%22now%22%7D%7D)

## Инфраструктура
Для развёртки всей инфраструктуры используем Terraform и Ansible. 

<details><summary>Ansible</summary>

 
>Roles  
>>elasticsearch
>>>files
>>>>elasticrepo.list  
>>>>elasticsearch.yml  

>>>tasks  
>>>>main.yml

>>grafana  
>>>tasks  
>>>>main.yml  

>>kibana  
>>>files  
>>>>elasticrepo.list  

>>>tasks  
>>>>main.yml  

>>nginx  
>>>files  
>>>>elasticrepo.list  
>>>>nginx  
>>>>nginx.conf  
>>>>nginx.yml  
>>>>node-exporter.service  
>>>>prometheus-nginxlog-exporter.hcl  

>>>tasks  
>>>>main.yml  
>>>>nginxlog-exporter.yml  
>>>>node-exporter.yml  

>>>vars  
>>>>main.yml  

>>prometheus  
>>>files  
>>>>prometheus.service  

>>>tasks  
>>>>main.yml  

>>>vars  
>>>>main.yml

>kibana-code.yml  
>project-all.yml  
>update.yml  
>elasticsearch.yaml  
>grafana.yaml  
>kibana.yaml  
>nginx.yaml  
>prometheus.yaml  

</details>  
<details><summary>Terraform</summary>  

>bastion.tf  
>cloud-init.yaml  
>elasticsearch.tf  
>grafana.tf  
>kibana.tf  
>key.json  
>main.tf  
>network.tf  
>nginx1.tf  
>nginx2.tf  
>outputs.tf  
>prometheus.tf  
>providers.tf  
>security.tf  

</details> 

Параметры виртуальной машины (ВМ) подбирайте по потребностям сервисов, которые будут на ней работать.  

<details><summary>Параметры виртуальных машин</summary>  

- Bastion-host  
    - Core: 2; Memory: 2Gb; Core_fraction: 5%;  
- Elasticsearch  
    - Core: 2; Memory: 6Gb; Core_fraction: 20%;  
- Grafana  
    - Core: 2; Memory: 2Gb; Core_fraction: 5%;  
- Kibana  
    - Core: 2; Memory: 4Gb; Core_fraction: 5%;  
- Nginx-web2  
    - Core: 2; Memory: 4Gb; Core_fraction: 5%;  
- Prometheus  
    - Core: 2; Memory: 4Gb; Core_fraction: 20%;  

</details>  


### Сайт
Создайте две ВМ в разных зонах, установите на них сервер nginx, если его там нет. ОС и содержимое ВМ должно быть идентичным, это будут наши веб-сервера.  

![Скриншот-1](https://github.com/plusvaldis/sys-diplom/blob/main/img/img7.png)  
![Скриншот-2](https://github.com/plusvaldis/sys-diplom/blob/main/img/img8.png)  

[Развертывание Ansible Nginx](https://github.com/plusvaldis/sys-diplom/tree/main/ansible/roles/nginx)  

Используйте набор статичных файлов для сайта. Можно переиспользовать сайт из домашнего задания.

Создайте [Target Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/target-group), включите в неё две созданных ВМ.  

![Скриншот-13](https://github.com/plusvaldis/sys-diplom/blob/main/img/img1.png)  
  
Создайте [Backend Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/backend-group), настройте backends на target group, ранее созданную. Настройте healthcheck на корень (/) и порт 80, протокол HTTP.  

![Скриншот-4](https://github.com/plusvaldis/sys-diplom/blob/main/img/img2.png)  

Создайте [HTTP router](https://cloud.yandex.com/docs/application-load-balancer/concepts/http-router). Путь укажите — /, backend group — созданную ранее.  

![Скриншот-5](https://github.com/plusvaldis/sys-diplom/blob/main/img/img3.png)  

Создайте [Application load balancer](https://cloud.yandex.com/en/docs/application-load-balancer/) для распределения трафика на веб-сервера, созданные ранее. Укажите HTTP router, созданный ранее, задайте listener тип auto, порт 80.  

![Скриншот-6](https://github.com/plusvaldis/sys-diplom/blob/main/img/img22.png)  
![Скриншот-6](https://github.com/plusvaldis/sys-diplom/blob/main/img/img4.png)  
![Скриншот-7](https://github.com/plusvaldis/sys-diplom/blob/main/img/img5.png)  

Протестируйте сайт
`curl -v <публичный IP балансера>:80`  

![Скриншот-8](https://github.com/plusvaldis/sys-diplom/blob/main/img/img6.png)  

### Мониторинг
Создайте ВМ, разверните на ней Prometheus. На каждую ВМ из веб-серверов установите Node Exporter и [Nginx Log Exporter](https://github.com/martin-helmich/prometheus-nginxlog-exporter). Настройте Prometheus на сбор метрик с этих exporter.  

[Развертывание Prometheus](https://github.com/plusvaldis/sys-diplom/tree/main/ansible/roles/prometheus) 


![Скриншот-9](https://github.com/plusvaldis/sys-diplom/blob/main/img/img9.png)  
![Скриншот-10](https://github.com/plusvaldis/sys-diplom/blob/main/img/img12.png)  

Создайте ВМ, установите туда Grafana. Настройте её на взаимодействие с ранее развернутым Prometheus. Настройте дешборды с отображением метрик, минимальный набор — Utilization, Saturation, Errors для CPU, RAM, диски, сеть, http_response_count_total, http_response_size_bytes. Добавьте необходимые [tresholds](https://grafana.com/docs/grafana/latest/panels/thresholds/) на соответствующие графики.  

[Развертывание Grafana](https://github.com/plusvaldis/sys-diplom/tree/main/ansible/roles/grafana)  

![Скриншот-12](https://github.com/plusvaldis/sys-diplom/blob/main/img/img11.png)  
![Скриншот-13](https://github.com/plusvaldis/sys-diplom/blob/main/img/img14.png)  

Под наши требования подходит график [Node Exporter for Prometheus EN 20201010](https://grafana.com/grafana/dashboards/11074-node-exporter-for-prometheus-dashboard-en-v20201010/)  
Так же в него добавил необходимые параметры http_response_count_total, http_response_size_bytes.  
http://158.160.22.130:3000/d/xfpJB9FGz/node-exporter-for-prometheus?orgId=1

### Логи
Cоздайте ВМ, разверните на ней Elasticsearch. Установите filebeat в ВМ к веб-серверам, настройте на отправку access.log, error.log nginx в Elasticsearch.  

[Развертывание Elasticsearch](https://github.com/plusvaldis/sys-diplom/tree/main/ansible/roles/elasticsearch)  

Elasticsearch недоступен, поэтому было использовано [зеркало](http://elasticrepo.serveradmin.ru) репозитория

![Скриншот-14](https://github.com/plusvaldis/sys-diplom/blob/main/img/img12.png)  
![Скриншот-15](https://github.com/plusvaldis/sys-diplom/blob/main/img/img15.png)  
![Скриншот-16](https://github.com/plusvaldis/sys-diplom/blob/main/img/img16.png)  
![Скриншот-17](https://github.com/plusvaldis/sys-diplom/blob/main/img/img17.png)  

Создайте ВМ, разверните на ней Kibana, сконфигурируйте соединение с Elasticsearch.  

[Развертывание Kiabana](https://github.com/plusvaldis/sys-diplom/tree/main/ansible/roles/kibana) 

![Скриншот-18](https://github.com/plusvaldis/sys-diplom/blob/main/img/img10.png)  
![Скриншот-19](https://github.com/plusvaldis/sys-diplom/blob/main/img/img18.png)  
 
### Сеть
Разверните один VPC. Сервера web, Prometheus, Elasticsearch поместите в приватные подсети. Сервера Grafana, Kibana, application load balancer определите в публичную подсеть.  

[Развертывание VPC](https://github.com/plusvaldis/sys-diplom/blob/main/terraform/network.tf)  
[Развертывание WEB1](https://github.com/plusvaldis/sys-diplom/blob/main/terraform/nginx1.tf)  
[Развертывание Prometheus](https://github.com/plusvaldis/sys-diplom/blob/main/terraform/prometheus.tf)  
[Развертывание Elasticsearch](https://github.com/plusvaldis/sys-diplom/blob/main/terraform/elasticsearch.tf)  
[Развертывание Grafana](https://github.com/plusvaldis/sys-diplom/blob/main/terraform/grafana.tf)  
[Развертывание Application Load Balancer](https://github.com/plusvaldis/sys-diplom/blob/main/terraform/main.tf)  

Настройте [Security Groups](https://cloud.yandex.com/docs/vpc/concepts/security-groups) соответствующих сервисов на входящий трафик только к нужным портам.  

[Развертывание Security Groups](https://github.com/plusvaldis/sys-diplom/blob/main/terraform/security.tf) 

![Скриншот-20](https://github.com/plusvaldis/sys-diplom/blob/main/img/img19.png)  

Настройте ВМ с публичным адресом, в которой будет открыт только один порт — ssh. Настройте все security groups на разрешение входящего ssh из этой security group. Эта вм будет реализовывать концепцию bastion host. Потом можно будет подключаться по ssh ко всем хостам через этот хост.  

[Развертывание Bastion](https://github.com/plusvaldis/sys-diplom/blob/main/terraform/bastion.tf)

![Скриншот-21](https://github.com/plusvaldis/sys-diplom/blob/main/img/img21.png)  

Создал VM Bastion-host разрешил ей трафик 22 порта, как входящий так и исходящий для подклчюения к остальным VM. 

### Резервное копирование
Создайте snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование.  

[Развертывание Snapshot shedule](https://github.com/plusvaldis/sys-diplom/blob/main/terraform/main.tf)  

![Скриншот-22](https://github.com/plusvaldis/sys-diplom/blob/main/img/img20.png)  


