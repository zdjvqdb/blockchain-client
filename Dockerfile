{\rtf1\ansi\ansicpg1252\cocoartf2821
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww37900\viewh19680\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 FROM golang:1.21-alpine\
\
WORKDIR /app\
\
# Copy go.mod and go.sum first (if you have them)\
COPY go.mod ./\
\
# Copy the source code\
COPY src/ ./src/\
\
# Build the application\
RUN go build -o blockchain-client ./src/\
\
EXPOSE 8080\
\
CMD ["./blockchain-client"]\
\
blockchain-client $ }