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
	message, ok := os.LookupEnv("MESSAGE")
	if !ok {
		message = "hi"
	}

	log.Print("Listening on (env ADDR) ", addr)
	log.Print("Message of (env MESSAGE) ", message)

	random := rand.New(rand.NewSource(time.Now().UnixNano()))

	http.HandleFunc("/health", func(w http.ResponseWriter, _ *http.Request) {
		fmt.Fprintln(w, "ok")
		log.Print("Handled health check")
	})

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
		out := fmt.Sprintf("request: %04d, message: %s, sleep(s): %f", rNum, message, duration.Seconds())
		fmt.Fprintln(w, out)
		log.Print("Handled ", out)
	})

	err := http.ListenAndServe(addr, nil)
	if err != nil {
		panic(err)
	}
}
