{\rtf1\ansi\ansicpg1252\cocoartf2821
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 package main\
\
import (\
        "testing"\
)\
\
func TestGetBlockNumber(t *testing.T) \{\
        client := NewClient(polygonRPCURL)\
\
        blockNumber, err := client.GetBlockNumber()\
        if err != nil \{\
                t.Fatalf("Failed to get block number: %v", err)\
        \}\
\
        if blockNumber == "" \{\
                t.Error("Block number should not be empty")\
        \}\
\
        t.Logf("Current block number: %s", blockNumber)\
\}\
\
func TestGetBlockByNumber(t *testing.T) \{\
        client := NewClient(polygonRPCURL)\
\
        // Test with a specific block number\
        block, err := client.GetBlockByNumber("0x134e82a")\
        if err != nil \{\
                t.Fatalf("Failed to get block: %v", err)\
        \}\
\
        if block["hash"] == nil \{\
                t.Error("Block should have a hash")\
        \}\
\
        if block["number"] == nil \{\
                t.Error("Block should have a number")\
        \}\
\
        t.Logf("Block hash: %v", block["hash"])\
        t.Logf("Block number: %v", block["number"])\
\}\
}