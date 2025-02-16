FROM golang:1.21-alpine AS build_deps

RUN apk add --no-cache git

WORKDIR /workspace

COPY go.mod .
COPY go.sum .

RUN go mod download

FROM build_deps AS build

COPY . .

RUN CGO_ENABLED=0 go build -o webhook -ldflags '-w -extldflags "-static"' .

FROM alpine:3.18

RUN apk add --no-cache ca-certificates
RUN apk add --no-cache libcap

COPY --from=build /workspace/webhook /usr/local/bin/webhook
RUN setcap cap_net_bind_service=+ep /usr/local/bin/webhook

ENTRYPOINT ["webhook"]
