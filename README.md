Example nfdump testing environment
======================================

This project serves as an docker based testing environment for
[nfdump](https://github.com/phaag/nfdump).

Project consists of two docker images (more details below):
 1. [nfdump](nfdump/Dockerfile) - allows run nfdump tools in the scope of docker
    container
 2. [tcpreplay](tcpreplay/Dockerfile) - can be used to send traffic to another
    container (nfdump) in docker using
    [tcpreplay](https://tcpreplay.appneta.com).

--------------------------------------
## Example deployment

Project includes example Docker Compose app (examine `docker-compose.yml` file before):

```
$ docker-compose up -d
```

--------------------------------------

## nfdump

### Base Image

Base image is `debian:stretch`.

### Building the image

```
$ docker build -t nfdump_img ./nfdump
```

Built image will use master branch of nfdump from default. It can be changed by
build-time variable `NFDUMP_VERSION`.
Example: build image using `unicorn` branch:
```
$ docker build --build-arg NFDUMP_VERSION=unicorn -t nfdump_img ./nfdump
```
There is also possibility to change repository which should be used as source 
code of nfdump, ex:
```
$ docker build --build-arg NFDUMP_BASE_URL=https://github.com/piorek94/nfdump/archive -t nfdump_img ./nfdump
```

### Running the container

The Nfdump image exposes a shared volume under `/data` (which is also working
directory), so you can mount a host directory to that point to access persisted
container data. Image exposes also 10000 udp port. A typical invocation of the
container might be:
```
$ docker run -d -P -v $PWD:/data nfdump_img nfcapd -p 10000 -l .
```

Modify `$PWD` to the directory where you want to store data associated with the
Nfdump container, or you can use named volume instead.

You can also start container in `CLI` mode (initialization scripts won't be
invoked - more details below) and use nfdump tools from there:
```
$ docker run -P --rm -it -v $PWD:/data nfdump_img bash
```

### Configuration

Configuration is provided via environment variables.

Variable|Default|Description
---|---|---
`NF_VIRT_MEM_LIMIT` | n/a | set the size of virtual memory in kbytes for running command
`NFEXPIRE` | off | update/set expiration limits in data directory
`NFEXPIRE_TIME` | n/a | size limit for the data directory (nfexpire `s` flag)
`NFEXPIRE_SIZE` | n/a | max life time for files in the data directory (nfexpire `t` flag)

### Custom Initialization Scripts

Nfdump image supports running arbitrary initialization scripts just before
executing docker command(which must start with `nfcapd` or `sfcapd`). Scripts
must have extension `.sh` and be mounted inside of the `/entrypoint-init.d`
directory. When multiple scripts are present, they will be executed in lexical
sort order by name.

The image will export a number of variables into the environment before
executing any scripts:
- `NFDUMP_DATA_DIR`: data directory (as well as working directory)

--------------------------------------

## tcpreplay

### Base Image

Base image is `debian:stretch`.

### Building the image

```
$ docker build -t tcpreplay_img ./tcpreplay
```

### Running the container

The Tcpreplay image searches for pcap files under `/data` directory (which is
also working directory). Pcap files must be mounted inside of that directory.
A typical invocation of the container might be:
```
$ docker run -d -v $pcap_path:/data/output.pcap tcpreplay_img tcpreplay --loop=0 --intf1=eth0 output.pcap
```

Modify `$pcap_path` to the desire pcap file path which you would replay.

You can also start container in `CLI` mode (initialization scripts won't be
invoked - more details below) and use tcpreplay tools from there:
```
$ docker run --rm -it -v $PWD/pcaps/example.pcap:/data/output.pcap tcpreplay_img bash
```

##### Send traffic to another container

In order to send traffic to another container pcap file must be modified -
must consider(minimal) target mac and ip address. It can be done by
[tcprewrite](https://tcpreplay.appneta.com/wiki/tcprewrite) tool.

Discovery and setting appropriate values are user obligation (sometimes docker
broadcast ip and mac address is enough).

Example: update dst port, mac and ip address:
```
tcprewrite --infile=input.pcap --outfile=output.pcap --dstipmap=<previous dst ip>:<target dst ip> --enet-dmac=<target mac> --portmap=<previous dst port>:<target dst port> --fixcsum
```

Preceding operations can be done automatically by build-in initialization script
(more details below).

### Configuration

Image has provided initialization script which allows rewrite (simple) pcap file.
Configuration for this script is provided via environment variables.

Variable|Default|Description
---|---|---
`TCPREWRITE` | off | run tcprewrite on input pcap file
`TCPREWRITE_IN_FILE` | n/a | Input pcap file to be processed
`TCPREWRITE_OUT_FILE` | n/a | Output pcap file
`TCPREWRITE_DMAC` | n/a | Override destination ethernet mac addresses (target mac)
`TCPREWRITE_SMAC` | n/a | Override source ethernet mac addresses
`TCPREWRITE_OLD_DIP` | n/a | Rewrite destination ip address (previous dst ip)
`TCPREWRITE_NEW_DIP` | n/a | Rewrite destination ip address (target dst ip)
`TCPREWRITE_OLD_DPORT` | n/a | Rewrite TCP/UDP ports (previous dst port)
`TCPREWRITE_NEW_DPORT` | n/a | Rewrite TCP/UDP ports (target dst port)


### Custom Initialization Scripts

Tcpreplay image supports running arbitrary initialization scripts just before
executing docker command(which must start with `tcpreplay`). Scripts
must have extension `.sh` and be mounted inside of the `/entrypoint-init.d`
directory. When multiple scripts are present, they will be executed in lexical
sort order by name.

The image will export a number of variables into the environment before
executing any scripts:
- `TCPREPLAY_DATA_DIR`: data directory (as well as working directory)
