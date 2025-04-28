# Build stage
FROM golang:1.22.2-alpine AS builder
WORKDIR /app

# Cache dependencies
COPY go.mod go.sum ./
RUN go mod download

# Build with explicit timeout shell command
COPY . .
RUN sh -c "timeout 300 go build -ldflags=\"-s -w\" -o api . || (echo 'Build timed out after 300s'; exit 1)"

# Final image
FROM alpine:3.19
WORKDIR /
COPY --from=builder /app/api .
CMD ["/api"]