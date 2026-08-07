package main

import (
    "log"
    "net/http"
    "net/http/httputil"
    "net/url"
    "strings"
)

func addCORS(h http.Header) {
	h.Set("Access-Control-Allow-Origin", "*")
	h.Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS, PATCH, HEAD")
	h.Set("Access-Control-Allow-Headers", "*, Authorization, Content-Type, X-Requested-With")
}

func main() {
    proxy := &httputil.ReverseProxy{
        Rewrite: func(pr *httputil.ProxyRequest) {
            targetURL := strings.TrimPrefix(pr.In.RequestURI, "/")
            if target, err := url.Parse(targetURL); err == nil {
                pr.SetURL(target)
                log.Printf("Proxying request to: %s", target.String())
            }
            pr.Out.Header.Del("Origin")
            pr.Out.Header.Del("Referer")
        },
        ModifyResponse: func(resp *http.Response) error {
            addCORS(resp.Header)
            return nil
        },
    }

    mainHandler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        
        if r.Method == http.MethodOptions {
            addCORS(w.Header())
            w.WriteHeader(http.StatusNoContent)
            return
        }
        
        proxy.ServeHTTP(w, r)
    })

    log.Println("🚀 Proxy running on :8080")
    log.Fatal(http.ListenAndServe(":8080", mainHandler))
}