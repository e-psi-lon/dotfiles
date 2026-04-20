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
            req.Header.Del("Origin")
            req.Header.Del("Referer")
        },
        ModifyResponse: func(resp *http.Response) error {
            resp.Header.Set("Access-Control-Allow-Origin", "*")
            resp.Header.Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS, PATCH, HEAD")
            resp.Header.Set("Access-Control-Allow-Headers", "*, Authorization, Content-Type, X-Requested-With")
            return nil
        },
    }

    mainHandler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        log.Printf("Proxying request to: %s", r.RequestURI)
        
        if r.Method == http.MethodOptions {
            w.Header().Set("Access-Control-Allow-Origin", "*")
            w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS, PATCH, HEAD")
            w.Header().Set("Access-Control-Allow-Headers", "*, Authorization, Content-Type, X-Requested-With")
            w.WriteHeader(http.StatusNoContent)
            return
        }
        
        proxy.ServeHTTP(w, r)
    })

    log.Println("🚀 Proxy running on :8080")
    log.Fatal(http.ListenAndServe(":8080", mainHandler))
}