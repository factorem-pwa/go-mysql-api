# Build stage
FROM golang:1.22.2-alpine AS builder
WORKDIR /app

# 1. Copy dependency files
COPY go.mod go.sum ./

# 2. Download dependencies
RUN go mod download

# 3. Copy source code
COPY . .

# 4. Fixed build command (all flags on one line)
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o api .

# Final image
FROM alpine:3.19
WORKDIR /
COPY --from=builder /app/api .
CMD ["./api"]