FROM golang:1.17.6-alpine3.15 as builder
WORKDIR /app
COPY go.mod .
COPY go.sum .
RUN go mod download
COPY . .
RUN GOGC=off CGO_ENABLED=0 go build -v -o prometheus_bot

FROM alpine:3.15.0 as alpine
RUN apk add --no-cache ca-certificates tzdata tini
COPY --from=builder /app/prometheus_bot /prometheus_bot
USER nobody
EXPOSE 9087
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/prometheus_bot", "-c", "/etc/telegrambot/config.yaml", "-t", "/etc/telegrambot/template_scada.tmpl"]
