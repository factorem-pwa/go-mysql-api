# Build stage with timeout
FROM golang:1.22.2-alpine AS builder
WORKDIR /app

# 1. Cache dependencies
COPY go.mod go.sum ./
RUN timeout 120 go mod download || echo "Warning: Mod download timed out"

# 2. Copy source with build timeout
COPY . .
RUN timeout 300 CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o api . || \
    (echo "Build timed out after 300s" && exit 1)

# Final image
FROM alpine:3.19
WORKDIR /
COPY --from=builder /app/api .
CMD ["/api"]