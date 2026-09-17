package models

type KumaHeartbeat struct {
	Status int    `json:"status"`
	Msg    string `json:"msg"`
}

type KumaMonitor struct {
	Name string `json:"name"`
}

type KumaWebhookPayload struct {
	Heartbeat KumaHeartbeat `json:"heartbeat"`
	Monitor   KumaMonitor   `json:"monitor"`
}

func (p KumaWebhookPayload) IsUp() bool {
	return p.Heartbeat.Status == 1
}
