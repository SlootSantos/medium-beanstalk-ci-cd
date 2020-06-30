FROM golang:1.13.5 AS builder
WORKDIR /go/src/github.com/SlootSantos/medium-beanstalk-ci-cd
COPY ./pkg .
RUN go get -d ./...
RUN CGO_ENABLED=0 go build ./main.go

FROM alpine:latest  
WORKDIR /root/
COPY --from=builder /go/src/github.com/SlootSantos/medium-beanstalk-ci-cd .

EXPOSE 3003
CMD ["./main"] 