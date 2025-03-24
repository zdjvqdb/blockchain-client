package main

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestBlockNumberHandler(t *testing.T) {
	req, err := http.NewRequest("GET", "/block-number", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(blockNumberHandler)
	handler.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v", status, http.StatusOK)
	}
}

func TestBlockByNumberHandler(t *testing.T) {
	req, err := http.NewRequest("GET", "/block?number=0x134e82a", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(blockByNumberHandler)
	handler.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v", status, http.StatusOK)
	}
}