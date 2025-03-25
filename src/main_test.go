package main

import (
        "testing"
)

func TestGetBlockNumber(t *testing.T) {
        client := NewClient(polygonRPCURL)

        blockNumber, err := client.GetBlockNumber()
        if err != nil {
                t.Fatalf("Failed to get block number: %v", err)
        }

        if blockNumber == "" {
                t.Error("Block number should not be empty")
        }

        t.Logf("Current block number: %s", blockNumber)
}

func TestGetBlockByNumber(t *testing.T) {
        client := NewClient(polygonRPCURL)

        // Test with a specific block number
        block, err := client.GetBlockByNumber("0x134e82a")
        if err != nil {
                t.Fatalf("Failed to get block: %v", err)
        }

        if block["hash"] == nil {
                t.Error("Block should have a hash")
        }

        if block["number"] == nil {
                t.Error("Block should have a number")
        }

        t.Logf("Block hash: %v", block["hash"])
        t.Logf("Block number: %v", block["number"])
}

blockchain-client $ cat src/main_test.go 
package main

import (
        "testing"
)

func TestGetBlockNumber(t *testing.T) {
        client := NewClient(polygonRPCURL)

        blockNumber, err := client.GetBlockNumber()
        if err != nil {
                t.Fatalf("Failed to get block number: %v", err)
        }

        if blockNumber == "" {
                t.Error("Block number should not be empty")
        }

        t.Logf("Current block number: %s", blockNumber)
}

func TestGetBlockByNumber(t *testing.T) {
        client := NewClient(polygonRPCURL)

        // Test with a specific block number
        block, err := client.GetBlockByNumber("0x134e82a")
        if err != nil {
                t.Fatalf("Failed to get block: %v", err)
        }

        if block["hash"] == nil {
                t.Error("Block should have a hash")
        }

        if block["number"] == nil {
                t.Error("Block should have a number")
        }

        t.Logf("Block hash: %v", block["hash"])
        t.Logf("Block number: %v", block["number"])
}
