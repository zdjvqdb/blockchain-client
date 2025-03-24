package main

import (
	"bytes"
	"encoding/json"
	"log"
	"net/http"
	"os"
)

const polygonRPCURL = "https://polygon-rpc.com/"

type RPCRequest struct {
	JSONRPC string        `json:"jsonrpc"`
	Method  string        `json:"method"`
	Params  []interface{} `json:"params,omitempty"`
	ID      int           `json:"id"`
}

func blockNumberHandler(w http.ResponseWriter, r *http.Request) {
	request := RPCRequest{
		JSONRPC: "2.0",
		Method:  "eth_blockNumber",
		ID:      1,
	}

	jsonRequest, _ := json.Marshal(request)
	resp, err := http.Post(polygonRPCURL, "application/json", bytes.NewBuffer(jsonRequest))
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp.Body)
}

func blockByNumberHandler(w http.ResponseWriter, r *http.Request) {
	blockNumber := r.URL.Query().Get("number")
	request := RPCRequest{
		JSONRPC: "2.0",
		Method:  "eth_getBlockByNumber",
		Params:  []interface{}{blockNumber, true},
		ID:      1,
	}

	jsonRequest, _ := json.Marshal(request)
	resp, err := http.Post(polygonRPCURL, "application/json", bytes.NewBuffer(jsonRequest))
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp.Body)
}

func main() {
	http.HandleFunc("/block-number", blockNumberHandler)
	http.HandleFunc("/block", blockByNumberHandler)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Server starting on port %s", port)
	log.Fatal(http.ListenAndServe(":" + port, nil))
}