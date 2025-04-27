# Build stage (Go 1.22.2)
FROM golang:1.22.2-alpine AS builder
RUN apk add --no-cache git ca-certificates
WORKDIR /app

# Cache dependencies
COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download -x

# Copy and build
COPY . .
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=linux go build \
    -ldflags="-s -w" \  # Strip debug symbols
    -o /api .

# Final stage (Alpine for minimal size)
FROM alpine:3.19
RUN apk add --no-cache tzdata
WORKDIR /
COPY --from=builder /api /api
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
CMD ["/api"]