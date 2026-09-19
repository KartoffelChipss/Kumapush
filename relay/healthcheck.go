package main

import (
	"fmt"
	"kumapush-relay/env"
	"net/http"
	"time"
)

// runHealthcheck backs `relay healthcheck`, which the container's HEALTHCHECK calls
func runHealthcheck() int {
	client := http.Client{Timeout: 3 * time.Second}
	resp, err := client.Get("http://127.0.0.1" + env.Port() + "/health")
	if err != nil {
		fmt.Println("healthcheck failed:", err)
		return 1
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		fmt.Println("healthcheck failed: status", resp.StatusCode)
		return 1
	}
	return 0
}
