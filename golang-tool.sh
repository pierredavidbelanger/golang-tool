#!/bin/bash -e

if ( find /src -maxdepth 0 -empty | read v ); then
  echo "Error: Must mount Go source code into /src directory"
  exit 990
fi

pkgName="$(go list -e -f '{{.ImportComment}}' 2>/dev/null || true)"
if [ -z "$pkgName" ]; then
  echo "Error: Must add canonical import path to root package"
  exit 992
fi

goPath="${GOPATH%%:*}"
pkgPath="$goPath/src/$pkgName"
mkdir -p "$(dirname "$pkgPath")"
if [ ! -e "$pkgPath" ]; then
    ln -sf /src "$pkgPath"
fi
cd "$pkgPath"

action=$1

if [ "$action" == "build" ]; then

    if [ -e "./vendor/vendor.json" ]; then
        govendor sync
    fi

    name=${pkgName##*/}
    CGO_ENABLED=0 go build -a -o "$name" --installsuffix cgo --ldflags="-s" "$pkgName"

    if [ -e "/var/run/docker.sock" ]; then

        if [ ! -e "./Dockerfile" ]; then

            mkdir -p /tmp/build

            cp /etc/ssl/certs/ca-certificates.crt /tmp/build/
            cp "${name}" /tmp/build/

            echo "FROM scratch" > /tmp/build/Dockerfile
            echo "COPY ca-certificates.crt /etc/ssl/certs/ca-certificates.crt" >> /tmp/build/Dockerfile
            echo "COPY ${name} /" >> /tmp/build/Dockerfile
            echo "ENTRYPOINT [\"/${name}\"]" >> /tmp/build/Dockerfile

            cd /tmp/build
        fi

        tagName=${2:-"$name":latest}
        docker build -t "$tagName" .
    fi
else
    exec bash
fi
