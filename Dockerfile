FROM golang:1.8

RUN curl https://get.docker.com/ | sh

RUN go get -u github.com/kardianos/govendor

VOLUME /src
WORKDIR /src

COPY golang-tool.sh /

ENTRYPOINT ["/golang-tool.sh"]