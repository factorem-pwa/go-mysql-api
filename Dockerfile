# Build stage
FROM golang:1.21 as builder
WORKDIR /app
COPY go.mod .
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o api

# Run stage
FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/api .
EXPOSE 3000
CMD ["./api"]