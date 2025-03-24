FROM golang:1.21-alpine

WORKDIR /app

COPY . .

RUN go build -o blockchain-client

EXPOSE 8080

CMD ["./blockchain-client"]