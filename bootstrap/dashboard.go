package bootstrap

import (
	"lunch/adapter/http"
	"lunch/config"

	"github.com/jesperkha/notifier"
)

func RunDashboard(notif *notifier.Notifier, config *config.Config) {
	http.RunDashboard(notif, nil, config)
}
