# docker-vnc

This image will run on most platforms that support Docker including Docker for Mac, Docker for Windows, Docker for Linux and Raspberry Pi 3 boards.

## Usage

```shell
docker run \
  -d \
  -p 59001:5901 -p 22022:22 \
  -v </path/to/config>:/scratch/shared \
  --name docker-vnc docker-vnc
```

or

```shell
docker-compose \
    --file docker-compose.yml up \
    --detach
```

Port 22022 can be used to access the Docker container via `SSH`

```bash
ssh root@0.0.0.0 -p 22022
```

## Parameters

The parameters are split into two halves, separated by a colon, the left hand side representing the host and the right the container side.

* `-p 59001:5901` - Binds the `vnc` service to port `59001` on the Docker host, **required**
* `-p 22022:22` - Binds the `ssh` service to port `22022` on the Docker host, **required**
* `-v /scratch/shared` - Path to share files on the Docker host, **required**

## Default User

The default username is `root` with password `welcome1`.