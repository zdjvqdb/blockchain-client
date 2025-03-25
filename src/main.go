package main

import (
        "bytes"
        "encoding/json"
        "fmt"
        "log"
        "net/http"
        "os"
)

const polygonRPCURL = "https://polygon-rpc.com/"

type RPCRequest struct {
        JSONRPC string        `json:"jsonrpc"`
        Method  string        `json:"method"`
        Params  []interface{} `json:"params,omitempty"`
        ID      int          `json:"id"`
}

type RPCResponse struct {
        JSONRPC string      `json:"jsonrpc"`
        Result  interface{} `json:"result"`
        Error   *RPCError   `json:"error,omitempty"`
        ID      int         `json:"id"`
}

type RPCError struct {
        Code    int    `json:"code"`
        Message string `json:"message"`
}

type Client struct {
        url string
}

func NewClient(url string) *Client {
        return &Client{url: url}
}

func (c *Client) GetBlockNumber() (string, error) {
        request := RPCRequest{
                JSONRPC: "2.0",
                Method:  "eth_blockNumber",
                ID:      2,
        }

        response, err := c.makeRequest(request)
        if err != nil {
                return "", err
        }

        blockNumber, ok := response.Result.(string)
        if !ok {
                return "", fmt.Errorf("unexpected response format")
        }

        return blockNumber, nil
}

func (c *Client) GetBlockByNumber(blockNumber string) (map[string]interface{}, error) {
        request := RPCRequest{
                JSONRPC: "2.0",
                Method:  "eth_getBlockByNumber",
                Params:  []interface{}{blockNumber, true},
                ID:      2,
        }

        response, err := c.makeRequest(request)
        if err != nil {
                return nil, err
        }

        block, ok := response.Result.(map[string]interface{})
        if !ok {
                return nil, fmt.Errorf("unexpected response format")
        }

        return block, nil
}

func (c *Client) makeRequest(request RPCRequest) (*RPCResponse, error) {
        jsonRequest, err := json.Marshal(request)
        if err != nil {
                return nil, err
        }

        resp, err := http.Post(c.url, "application/json", bytes.NewBuffer(jsonRequest))
        if err != nil {
                return nil, err
        }
        defer resp.Body.Close()

        var response RPCResponse
        if err := json.NewDecoder(resp.Body).Decode(&response); err != nil {
                return nil, err
        }

        if response.Error != nil {
                return nil, fmt.Errorf("RPC error: %s", response.Error.Message)
        }

        return &response, nil
}

func blockNumberHandler(w http.ResponseWriter, r *http.Request) {
        client := NewClient(polygonRPCURL)
        blockNumber, err := client.GetBlockNumber()
        if err != nil {
                http.Error(w, err.Error(), http.StatusInternalServerError)
                return
        }

        w.Header().Set("Content-Type", "application/json")
        json.NewEncoder(w).Encode(map[string]string{"blockNumber": blockNumber})
}

func blockByNumberHandler(w http.ResponseWriter, r *http.Request) {
        blockNumber := r.URL.Query().Get("number")
        if blockNumber == "" {
                http.Error(w, "Missing 'number' parameter", http.StatusBadRequest)
                return
        }

        client := NewClient(polygonRPCURL)
        block, err := client.GetBlockByNumber(blockNumber)
        if err != nil {
                http.Error(w, err.Error(), http.StatusInternalServerError)
                return
        }

        w.Header().Set("Content-Type", "application/json")
        json.NewEncoder(w).Encode(block)
}

func main() {
        http.HandleFunc("/block-number", blockNumberHandler)
        http.HandleFunc("/block", blockByNumberHandler)

        port := os.Getenv("PORT")
        if port == "" {
                port = "8080"
        }

        log.Printf("Server starting on port %s", port)
        log.Fatal(http.ListenAndServe(":"+port, nil))
}

