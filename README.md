kafka_exporter
==============

Kafka exporter for Prometheus - patched by Mr Yum Eng.

Mr Yum forked and patched this exporter to temporarily overcome an issue with the consumergroupMembers metric which was intermittently causing the kafka_exporter
to fail metric exports.

This repository will only temporarily exist while we work on a more robust patch and submit that upstream to `danielqsj/kafka_exporter`.

Table of Contents
-----------------

-	[Compatibility](#compatibility)
-	[Dependency](#dependency)
-	[Download](#download)
-	[Compile](#compile)
	-	[Build Binary](#build-binary-for-testing-locally)
	-	[Build Docker Image](#build-docker-image-for-testing-locally)
	-   [Build & Push Multi-Arch Docker Image to ghcr.io](#build-docker-image-and-push-to-github-container-registry)
-   [Github Container Registry Image](#github-container-registry-image)
-	[Run](#run)
	-	[Run Binary](#run-binary)
	-	[Run Docker Image](#run-docker-image)
-	[Flags](#flags)
    -	[Notes](#notes)
-	[Metrics](#metrics)
	-	[Brokers](#brokers)
	-	[Topics](#topics)
	-	[Consumer Groups](#consumer-groups)
-	[Grafana Dashboard](#grafana-dashboard)
-   [Contribute](#contribute)
-   [Donation](#donation)
-   [License](#license)

Compatibility
-------------

Support [Apache Kafka](https://kafka.apache.org) version 0.10.1.0 (and later).

Dependency
----------

-	[Prometheus](https://prometheus.io)
-	[Sarama](https://shopify.github.io/sarama)
-	[Golang](https://golang.org)

Compile
-------

### Build Binary - for testing locally

```shell
make
```

### Build Docker Image - for testing locally

```shell
make docker
```
### Build Docker Image and push to Github Container Registry

**As this is a temporary patch, only Mr Yum SRE team has permissions to upload new packages to ghcr.io for this particular container path.**

>**NOTE:** If you haven't set up a personal access token with read/write permissions for
Github packages then please follow the instructions [here](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-to-the-container-registry)
before moving on.

1. Export your CR_PAT (Github Container Registry Personal Access Token) and login via docker.

```shell
export CR_PAT="replace-with-your-cr-pat"
export GH_USERNAME="replace-with-your-github-username"                                                                                                                                                             
echo ${CR_PAT?} | docker login ghcr.io -u ${GH_USERNAME?} --password-stdin 
 ```

2. Once you've received the 'Login Succeeded' message you can run the multi-arch build. This will
   build various target_arch containers and push them to ghcr.io.

```shell
make push
```

>**NOTE:**: This will push to `ghcr.io/mr-yum/kafka-exporter` and assign two tags.
The first tag will be the versioning tag which is a md5 hash of the build branch (`ghcr.io/mr-yum/kafka-exporter:$md5sum`).
The second tag with be the latest tag (`ghcr.io/mr-yum/kafka-exporter:latest`).

Github Container Registry Image
----------------

```shell
docker pull ghcr.io/mr-yum/kafka-exporter:latest
```

It can be used directly instead of having to build the image yourself. ([ghcr.io/mr-yum/kafka-exporter](https://github.com/orgs/mr-yum/packages/container/package/kafka-exporter))

Run
---

### Run Binary

```shell
kafka_exporter --kafka.server=kafka:9092 [--kafka.server=another-server ...]
```

### Run Docker Image

```
docker run -ti --rm -p 9308:9308 danielqsj/kafka-exporter --kafka.server=kafka:9092 [--kafka.server=another-server ...]
```

Flags
-----

This image is configurable using different flags

| Flag name                    | Default        | Description                                                                                                                            |
|------------------------------|----------------|----------------------------------------------------------------------------------------------------------------------------------------|
| kafka.server                 | kafka:9092     | Addresses (host:port) of Kafka server                                                                                                  |
| kafka.version                | 2.0.0          | Kafka broker version                                                                                                                   |
| sasl.enabled                 | false          | Connect using SASL/PLAIN                                                                                                               |
| sasl.handshake               | true           | Only set this to false if using a non-Kafka SASL proxy                                                                                 |
| sasl.username                |                | SASL user name                                                                                                                         |
| sasl.password                |                | SASL user password                                                                                                                     |
| sasl.mechanism               |                | SASL mechanism can be plain, scram-sha512, scram-sha256                                                                                |
| sasl.service-name            |                | Service name when using Kerberos Auth                                                                                                  |
| sasl.kerberos-config-path    |                | Kerberos config path                                                                                                                   |
| sasl.realm                   |                | Kerberos realm                                                                                                                         |
| sasl.keytab-path             |                | Kerberos keytab file path                                                                                                              |
| sasl.kerberos-auth-type      |                | Kerberos auth type. Either 'keytabAuth' or 'userAuth'                                                                                  |
| tls.enabled                  | false          | Connect to Kafka using TLS                                                                                                                      |
| tls.server-name                  |                | Used to verify the hostname on the returned certificates unless tls.insecure-skip-tls-verify is given. The kafka server's name should be given                                                                  |
| tls.ca-file                  |                | The optional certificate authority file for Kafka TLS client authentication                                                                  |
| tls.cert-file                |                | The optional certificate file for Kafka client authentication                                                                                |
| tls.key-file                 |                | The optional key file for Kafka client authentication                                                                                        |
| tls.insecure-skip-tls-verify | false          | If true, the server's certificate will not be checked for validity                                                                     |
| server.tls.enabled                  | false          | Enable TLS for web server                                                                                                                      |
| server.tls.mutual-auth-enabled                  | false          | Enable TLS client mutual authentication                                                                                                                      |
| server.tls.ca-file                |                | The certificate authority file for the web server                                                                                |
| server.tls.cert-file                |                | The certificate file for the web server                                                                                |
| server.tls.key-file                 |                | The key file for the web server                                                                                        |
| topic.filter                 | .*             | Regex that determines which topics to collect                                                                                          |
| group.filter                 | .*             | Regex that determines which consumer groups to collect                                                                                 |
| web.listen-address           | :9308          | Address to listen on for web interface and telemetry                                                                                   |
| web.telemetry-path           | /metrics       | Path under which to expose metrics                                                                                                     |
| log.enable-sarama            | false          | Turn on Sarama logging                                                                                                                 |
| use.consumelag.zookeeper     | false          | if you need to use a group from zookeeper                                                                                              |
| zookeeper.server             | localhost:2181 | Address (hosts) of zookeeper server                                                                                                    |
| kafka.labels                 |                | Kafka cluster name                                                                                                                     |
| refresh.metadata             | 30s            | Metadata refresh interval                                                                                                              |
| offset.show-all              | true           | Whether show the offset/lag for all consumer group, otherwise, only show connected consumer groups                                     |
| concurrent.enable            | false          | If true, all scrapes will trigger kafka operations otherwise, they will share results. WARN: This should be disabled on large clusters |
| topic.workers                | 100            | Number of topic workers                                                                                                                |
| verbosity                    | 0              | Verbosity log level                                                                                                                    |


### Notes

Boolean values are uniquely managed by [Kingpin](https://github.com/alecthomas/kingpin/blob/master/README.md#boolean-values). Each boolean flag will have a negative complement:
`--<name>` and `--no-<name>`.

For example:

If you need to disable `sasl.handshake`, you could add flag `--no-sasl.handshake`

Metrics
-------

Documents about exposed Prometheus metrics.

For details on the underlying metrics please see [Apache Kafka](https://kafka.apache.org/documentation).

### Brokers

**Metrics details**

| Name            | Exposed informations                   |
| --------------- | -------------------------------------- |
| `kafka_brokers` | Number of Brokers in the Kafka Cluster |

**Metrics output example**

```txt
# HELP kafka_brokers Number of Brokers in the Kafka Cluster.
# TYPE kafka_brokers gauge
kafka_brokers 3
```

### Topics

**Metrics details**

| Name                                               | Exposed informations                                |
| -------------------------------------------------- | --------------------------------------------------- |
| `kafka_topic_partitions`                           | Number of partitions for this Topic                 |
| `kafka_topic_partition_current_offset`             | Current Offset of a Broker at Topic/Partition       |
| `kafka_topic_partition_oldest_offset`              | Oldest Offset of a Broker at Topic/Partition        |
| `kafka_topic_partition_in_sync_replica`            | Number of In-Sync Replicas for this Topic/Partition |
| `kafka_topic_partition_leader`                     | Leader Broker ID of this Topic/Partition            |
| `kafka_topic_partition_leader_is_preferred`        | 1 if Topic/Partition is using the Preferred Broker  |
| `kafka_topic_partition_replicas`                   | Number of Replicas for this Topic/Partition         |
| `kafka_topic_partition_under_replicated_partition` | 1 if Topic/Partition is under Replicated            |

**Metrics output example**

```txt
# HELP kafka_topic_partitions Number of partitions for this Topic
# TYPE kafka_topic_partitions gauge
kafka_topic_partitions{topic="__consumer_offsets"} 50

# HELP kafka_topic_partition_current_offset Current Offset of a Broker at Topic/Partition
# TYPE kafka_topic_partition_current_offset gauge
kafka_topic_partition_current_offset{partition="0",topic="__consumer_offsets"} 0

# HELP kafka_topic_partition_oldest_offset Oldest Offset of a Broker at Topic/Partition
# TYPE kafka_topic_partition_oldest_offset gauge
kafka_topic_partition_oldest_offset{partition="0",topic="__consumer_offsets"} 0

# HELP kafka_topic_partition_in_sync_replica Number of In-Sync Replicas for this Topic/Partition
# TYPE kafka_topic_partition_in_sync_replica gauge
kafka_topic_partition_in_sync_replica{partition="0",topic="__consumer_offsets"} 3

# HELP kafka_topic_partition_leader Leader Broker ID of this Topic/Partition
# TYPE kafka_topic_partition_leader gauge
kafka_topic_partition_leader{partition="0",topic="__consumer_offsets"} 0

# HELP kafka_topic_partition_leader_is_preferred 1 if Topic/Partition is using the Preferred Broker
# TYPE kafka_topic_partition_leader_is_preferred gauge
kafka_topic_partition_leader_is_preferred{partition="0",topic="__consumer_offsets"} 1

# HELP kafka_topic_partition_replicas Number of Replicas for this Topic/Partition
# TYPE kafka_topic_partition_replicas gauge
kafka_topic_partition_replicas{partition="0",topic="__consumer_offsets"} 3

# HELP kafka_topic_partition_under_replicated_partition 1 if Topic/Partition is under Replicated
# TYPE kafka_topic_partition_under_replicated_partition gauge
kafka_topic_partition_under_replicated_partition{partition="0",topic="__consumer_offsets"} 0
```

### Consumer Groups

**Metrics details**

| Name                                 | Exposed informations                                          |
| ------------------------------------ | ------------------------------------------------------------- |
| `kafka_consumergroup_current_offset` | Current Offset of a ConsumerGroup at Topic/Partition          |
| `kafka_consumergroup_lag`            | Current Approximate Lag of a ConsumerGroup at Topic/Partition |

**Metrics output example**

```txt
# HELP kafka_consumergroup_current_offset Current Offset of a ConsumerGroup at Topic/Partition
# TYPE kafka_consumergroup_current_offset gauge
kafka_consumergroup_current_offset{consumergroup="KMOffsetCache-kafka-manager-3806276532-ml44w",partition="0",topic="__consumer_offsets"} -1

# HELP kafka_consumergroup_lag Current Approximate Lag of a ConsumerGroup at Topic/Partition
# TYPE kafka_consumergroup_lag gauge
kafka_consumergroup_lag{consumergroup="KMOffsetCache-kafka-manager-3806276532-ml44w",partition="0",topic="__consumer_offsets"} 1
```

Grafana Dashboard
-------

Grafana Dashboard ID: 7589, name: Kafka Exporter Overview.

For details of the dashboard please see [Kafka Exporter Overview](https://grafana.com/dashboards/7589).

Contribute
----------

If you like Kafka Exporter, please give me a star. This will help more people know Kafka Exporter.

Please feel free to send me [pull requests](https://github.com/danielqsj/kafka_exporter/pulls).

Contributors ✨
----------

Thanks goes to these wonderful people:

<a href="https://github.com/danielqsj/kafka_exporter/graphs/contributors">
<img src="https://contrib.rocks/image?repo=danielqsj/kafka_exporter" />
</a>

Donation
--------

Your donation will encourage me to continue to improve Kafka Exporter. Support Alipay donation.

![](https://github.com/danielqsj/kafka_exporter/raw/master/alipay.jpg)

License
-------

Code is licensed under the [Apache License 2.0](https://github.com/danielqsj/kafka_exporter/blob/master/LICENSE).
