# build stage
FROM golang:1.10-alpine AS build

RUN apk add --no-cache git build-base curl
RUN curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh

WORKDIR /go/src/github.com/smyrgl/echo

ADD ./Gopkg.lock ./Gopkg.lock
ADD ./Gopkg.toml ./Gopkg.toml
RUN dep ensure -vendor-only

ADD . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -o build .

# final stage
FROM scratch

COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /go/src/github.com/smyrgl/echo/build /usr/bin/echo
CMD ["/usr/bin/echo"]
