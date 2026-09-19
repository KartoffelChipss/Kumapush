package service

import (
	"encoding/json"
	"testing"

	"kumapush-relay/models"
)

func generate(t *testing.T, body string) map[string]any {
	t.Helper()
	var wh models.KumaWebhookPayload
	if err := json.Unmarshal([]byte(body), &wh); err != nil {
		t.Fatal(err)
	}
	raw, err := json.Marshal(GeneratePayload(wh, models.NotificationLevelTimeSensitive))
	if err != nil {
		t.Fatal(err)
	}
	var out map[string]any
	if err := json.Unmarshal(raw, &out); err != nil {
		t.Fatal(err)
	}
	return out["aps"].(map[string]any)
}

func TestTestWebhookPayload(t *testing.T) {
	aps := generate(t, `{"heartbeat": null, "monitor": null, "msg": "Test-Webhook Testing"}`)
	alert := aps["alert"].(map[string]any)
	if alert["title"] != "KumaPush" || alert["body"] != "Test-Webhook Testing" {
		t.Fatalf("unexpected alert: %v", alert)
	}
	if _, ok := aps["interruption-level"]; ok {
		t.Fatal("test notification must not be time-sensitive")
	}
}

func TestDownWebhookPayload(t *testing.T) {
	aps := generate(t, `{"heartbeat": {"status": 0, "msg": "timeout"}, "monitor": {"name": "API"}, "msg": "ignored"}`)
	alert := aps["alert"].(map[string]any)
	if alert["title"] != "API is down" || alert["body"] != "timeout" {
		t.Fatalf("unexpected alert: %v", alert)
	}
	if aps["interruption-level"] != "time-sensitive" {
		t.Fatalf("down should be time-sensitive, got %v", aps["interruption-level"])
	}
}

func TestUpWebhookPayload(t *testing.T) {
	aps := generate(t, `{"heartbeat": {"status": 1, "msg": "200 OK"}, "monitor": {"name": "API"}}`)
	if aps["alert"].(map[string]any)["title"] != "API is up" {
		t.Fatalf("unexpected alert: %v", aps["alert"])
	}
}
