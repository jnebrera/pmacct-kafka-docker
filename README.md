# Prozzie pmacct sfacctd docker with kafka

## Introduction
This repository provides an easy way to build a sfacctd
([pmacct](http://www.pmacct.net/) [sflow](http://www.sflow.org/) accounting
daemon) docker container with kafka support.

## Docker environment variables
You can check container environment variables in [ENVS.md](ENVS.md). Also, you
can send variables to
[librdkafka](https://github.com/edenhill/librdkafka/blob/master/CONFIGURATION.md)
producer with environments this format, for global and topic properties:

```
RDKAFKA_[GLOBAL|TOPIC]_[CONFIG_KEY]=[CONFIG_VALUE]
```

For example:
```
RDKAFKA_GLOBAL_SOCKET_KEEPALIVE_ENABLE=true
RDKAFKA_GLOBAL_MESSAGE_SEND_MAX_RETRIES=0
```

## Components
### Pmacct development docker
To be able to compile pmacct, this repository creates a docker container with
all dependencies needed for that task. You can use your own environment if you
want.

Docker container is generated using devel version of
[Dockerfile.m4](docker/Dockerfile.m4). If you want to disable it, set
`ENABLE_DOCKER=n` environment variable. If you want to use your development
docker, please provide its docker id to variable `dev_docker_id`.
