FROM golang as build
RUN go get -u github.com/yandex-cloud/docker-machine-driver-yandex
RUN go get github.com/mitchellh/gox
WORKDIR /go/src/github.com/yandex-cloud/docker-machine-driver-yandex

RUN mkdir -p releases
RUN mkdir -p data

RUN gox -os="linux windows freebsd openbsd netbsd" -output="releases/{{.Dir}}_`git describe --tags --abbrev=0`_{{.OS}}_{{.Arch}}/{{.Dir}}" -ldflags "-X main.Version=`git describe --tags --abbrev=0`"
RUN find releases -maxdepth 2 -mindepth 2 -type f -exec bash -c 'tar -cvzf "$(dirname {}).tar.gz" -C "$(dirname {})" $(basename {})' \;
RUN mv releases/*.tar.gz data/

FROM nginx:stable-alpine
RUN echo 'server { listen   80; root   /data; location / { autoindex on; autoindex_format json; } }' > /etc/nginx/conf.d/default.conf
COPY --from=build /go/src/github.com/yandex-cloud/docker-machine-driver-yandex/data/ /data
