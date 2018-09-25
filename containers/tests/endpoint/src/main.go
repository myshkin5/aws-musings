package main

import (
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"os"
	"time"
)

func main() {
	addr, ok := os.LookupEnv("ADDR")
	if !ok {
		addr = "0.0.0.0:8080"
	}
	serviceName, ok := os.LookupEnv("SERVICE_NAME")
	if !ok {
		serviceName = "test-endpoint"
	}

	log.Printf("Service (env SERVICE_NAME) %s listening on (env ADDR) %s", serviceName, addr)

	http.HandleFunc("/health", func(w http.ResponseWriter, _ *http.Request) {
		fmt.Fprintln(w, "ok")
		log.Print("Handled health check")
	})

	random := rand.New(rand.NewSource(time.Now().UnixNano()))

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		sleep := r.URL.Query().Get("sleep")
		var duration time.Duration
		var err error
		if sleep != "" {
			duration, err = time.ParseDuration(sleep)
			if err == nil {
				time.Sleep(duration)
			}
		}
		rNum := random.Intn(10000)
		out := fmt.Sprintf("service: %s, request: %04d, sleep(s): %f, from: %s",
			serviceName, rNum, duration.Seconds(), r.RemoteAddr)
		fmt.Fprintln(w, out)
		log.Print("Handled ", out)
	})

	err := http.ListenAndServe(addr, nil)
	if err != nil {
		panic(err)
	}
}
