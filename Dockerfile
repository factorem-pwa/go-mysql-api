# Build stage
FROM golang:1.22.2-alpine AS builder
WORKDIR /app

# Copy and download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy source and build
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build \
    -ldflags="-s -w" \  # Strip debug symbols
    -o api .  # ← Critical fix: The "-o" must be on same line as "go build"

# Final stage
FROM alpine:3.19
WORKDIR /
COPY --from=builder /app/api .
CMD ["./api"]