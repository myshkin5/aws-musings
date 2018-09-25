package main

import (
	"bufio"
	"bytes"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"math/rand"
	"net"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
	"strconv"
	"strings"
	"time"
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
	serviceName, ok := os.LookupEnv("SERVICE_NAME")
	if !ok {
		serviceName = "test-forwarder"
	}

	target, err := url.Parse(forwardToUrl)
	if err != nil {
		panic(err)
	}

	log.Printf("Service (env SERVICE_NAME) %s listening on (env ADDR) %s, forwarding to (env FORWARD_TO_URL %s (%s)",
		serviceName, addr, forwardToUrl, resolveTarget(target))

	handleHealth := func(w http.ResponseWriter, _ *http.Request) {
		fmt.Fprintln(w, "ok")
		log.Print("Handled health check")
	}

	random := rand.New(rand.NewSource(time.Now().UnixNano()))

	proxy := &httputil.ReverseProxy{
		Director:       newDirector(target),
		ModifyResponse: newModifyResponse(serviceName, random),
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

func newModifyResponse(serviceName string, random *rand.Rand) func(*http.Response) error {
	return func(resp *http.Response) (err error) {
		b, err := ioutil.ReadAll(resp.Body)
		if err != nil {
			return err
		}
		err = resp.Body.Close()
		if err != nil {
			return err
		}

		rNum := random.Intn(10000)
		out := fmt.Sprintf("service: %s, request: %04d, from: %s",
			serviceName, rNum, resp.Request.RemoteAddr)

		buf := bytes.NewBufferString(out + "\n")

		r := bufio.NewReader(bytes.NewReader(b))

		for {
			line, err := r.ReadString('\n')
			if err == io.EOF {
				break
			}
			if err != nil {
				return err
			}
			buf.WriteString("    " + line)
		}

		body := ioutil.NopCloser(bytes.NewReader(buf.Bytes()))
		resp.Body = body
		resp.ContentLength = int64(buf.Len())
		resp.Header.Set("Content-Length", strconv.Itoa(buf.Len()))

		log.Print("Handled ", out)

		return nil
	}
}
