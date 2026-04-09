package main

import (
	"io"
	"log"
	"net/http"
	"strings"
	"time"
)

func handleProxy(w http.ResponseWriter, r *http.Request) {
	// 1. Extract target URL (e.g., /https://google.com -> https://google.com)
	targetURL := strings.TrimPrefix(r.RequestURI, "/")

	if !strings.HasPrefix(targetURL, "http") {
		http.Error(w, "Usage: /https://api.example.com", http.StatusBadRequest)
		return
	}

	if r.Method == http.MethodOptions {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "*")
		w.Header().Set("Access-Control-Allow-Headers", "*")
		w.WriteHeader(http.StatusNoContent)
		return
	}

	// 2. Create the outbound request
	proxyReq, err := http.NewRequest(r.Method, targetURL, r.Body)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	for name, values := range r.Header {
		if strings.ToLower(name) != "host" {
			for _, v := range values {
				proxyReq.Header.Add(name, v)
			}
		}
	}

	// 3. Execute and mirror response
	client := &http.Client{Timeout: 30 * time.Second}
	resp, err := client.Do(proxyReq)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadGateway)
		return
	}
	defer resp.Body.Close()

	// 4. Inject CORS Headers
	for name, values := range resp.Header {
		for _, value := range values {
			w.Header().Add(name, value)
		}
	}
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS, PATCH, HEAD")
	w.Header().Set("Access-Control-Allow-Headers", "*")

	w.WriteHeader(resp.StatusCode)
	io.Copy(w, resp.Body)
}

func main() {
	http.HandleFunc("/", handleProxy)
	log.Println("🚀 Proxy running on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}