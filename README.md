# golang-tool

A tool to compile a Golang application and package it in a minimal Docker container.

Heavily inspired by [CenturyLinkLabs/golang-builder](https://github.com/CenturyLinkLabs/golang-builder).

## usage

Create a project folder

```sh
$ mkdir /tmp/hello && cd /tmp/hello
```

Create an Hello world application

```sh
$ cat <<EOF > hello-world.go
package main // import "github.com/pierredavidbelanger/hello"
import "fmt"
func main() {
    fmt.Println("hello world")
}
EOF
```

Compile and package it

```sh
$ docker run --rm \
    -v $PWD:/src \
    -v /var/run/docker.sock:/var/run/docker.sock \
    pierredavidbelanger/golang-tool \
    build
```

Appreciate its size

```sh
$ docker images
REPOSITORY                           TAG                 IMAGE ID            CREATED              SIZE
hello                                latest              45cc1f1f326f        About a minute ago   1.3 MB
pierredavidbelanger/golang-tool      latest              98dbd68d4fe4        15 minutes ago       830 MB
```

Run it

```sh
$ docker run --rm hello
hello world
```
