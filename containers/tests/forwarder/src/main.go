package main

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"log"
	"net"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
	"strconv"
	"strings"
)

func main() {
	addr, ok := os.LookupEnv("ADDR")
	if !ok {
		addr = "0.0.0.0:8080"
	}
	forwardToUrl, ok := os.LookupEnv("FORWARD_TO_URL")
	if !ok {
		forwardToUrl = "http://localhost:8080/health"
	}
	message, ok := os.LookupEnv("MESSAGE")
	if !ok {
		message = "forwarder hi, "
	}

	target, err := url.Parse(forwardToUrl)
	if err != nil {
		panic(err)
	}

	log.Print("Listening on (env ADDR) ", addr)
	log.Printf("Forwarding to (env FORWARD_TO_URL) %s (%s)", forwardToUrl, resolveTarget(target))
	log.Print("Message of (env MESSAGE) ", message)

	handleHealth := func(w http.ResponseWriter, _ *http.Request) {
		fmt.Fprintln(w, "ok")
		log.Print("Handled health check")
	}

	proxy := &httputil.ReverseProxy{
		Director:       newDirector(target),
		ModifyResponse: newModifyResponse(message),
	}

	http.HandleFunc("/", func(w http.ResponseWriter, req *http.Request) {
		if strings.HasPrefix(req.URL.Path, "/health") {
			handleHealth(w, req)
			return
		}

		proxy.ServeHTTP(w, req)
	})

	err = http.ListenAndServe(addr, nil)
	if err != nil {
		panic(err)
	}
}

func resolveTarget(target *url.URL) string {
	targetHost, _, err := net.SplitHostPort(target.Host)
	if err != nil {
		targetHost = target.Host
	}

	ipAddr, err := net.ResolveIPAddr("ip", targetHost)
	var targetIP string
	if err == nil {
		targetIP = ipAddr.String()
	} else {
		log.Print("Ignoring error ", err)
		targetIP = ""
	}

	return targetIP
}

func newDirector(target *url.URL) func(*http.Request) {
	return func(req *http.Request) {
		req.URL.Scheme = target.Scheme
		req.URL.Host = target.Host
		req.URL.Path = target.Path + req.URL.Path
		req.Host = ""
	}
}

func newModifyResponse(message string) func(*http.Response) error {
	return func(resp *http.Response) (err error) {
		b, err := ioutil.ReadAll(resp.Body)
		if err != nil {
			return err
		}
		err = resp.Body.Close()
		if err != nil {
			return err
		}

		b = append([]byte(message), b...)

		log.Print("Handled ", string(b))

		body := ioutil.NopCloser(bytes.NewReader(b))
		resp.Body = body
		resp.ContentLength = int64(len(b))
		resp.Header.Set("Content-Length", strconv.Itoa(len(b)))
		return nil
	}
}
