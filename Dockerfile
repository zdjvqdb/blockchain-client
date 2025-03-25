FROM golang:1.21-alpine

WORKDIR /app

# Copy go.mod and go.sum first (if you have them)
COPY go.mod ./

# Copy the source code
COPY src/ ./src/

# Build the application
RUN go build -o blockchain-client ./src/

EXPOSE 8080

CMD ["./blockchain-client"]

