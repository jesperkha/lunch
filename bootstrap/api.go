package bootstrap

import (
	"lunch/adapter/http"
	"lunch/config"

	"github.com/jesperkha/notifier"
)

func RunApi(notif *notifier.Notifier, config *config.Config) {
	http.RunApi(notif, nil, config)
}
