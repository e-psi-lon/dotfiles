package main

import (
    "log"
    "net/http"
    "net/http/httputil"
    "net/url"
    "strings"
)

func main() {
    proxy := &httputil.ReverseProxy{
        Director: func(req *http.Request) {
            targetURL := strings.TrimPrefix(req.RequestURI, "/")
            if target, err := url.Parse(targetURL); err == nil {
                req.URL = target
                req.Host = target.Host
            }
        },
        ModifyResponse: func(resp *http.Response) error {
            resp.Header.Set("Access-Control-Allow-Origin", "*")
            resp.Header.Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS, PATCH, HEAD")
            resp.Header.Set("Access-Control-Allow-Headers", "*")
            return nil
        },
    }

    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        if r.Method == http.MethodOptions {
            w.Header().Set("Access-Control-Allow-Origin", "*")
            w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS, PATCH, HEAD")
            w.Header().Set("Access-Control-Allow-Headers", "*")
            w.WriteHeader(http.StatusNoContent)
            return
        }
        proxy.ServeHTTP(w, r)
    })

    log.Println("🚀 Proxy running on :8080")
    log.Fatal(http.ListenAndServe(":8080", nil))
}