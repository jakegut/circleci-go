FROM golang:1.20-alpine3.18 AS builder

WORKDIR /app

# COPY go.mod go.sum ./

RUN --mount=type=ssh \
    --mount=type=cache,target=/go/pkg/mod/ \
    --mount=type=bind,source=go.sum,target=go.sum \
    --mount=type=bind,source=go.mod,target=go.mod \
    go mod download -x

# COPY . .

RUN --mount=type=cache,target=/go/pkg/mod/ \
    --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=bind,target=. \
    go build -o /build/server

FROM gcr.io/distroless/static

COPY --from=builder /build/server /server
ENTRYPOINT ["/server"]