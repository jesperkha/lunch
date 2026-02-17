package http

import (
	"lunch/adapter/http/router"
	"lunch/config"
	"lunch/domain/port"

	"github.com/jesperkha/notifier"
)

func RunApi(
	notif *notifier.Notifier,
	logger port.Logger,
	config *config.Config,
) {
	r := router.New(logger)

	r.Serve(notif, config.ApiPort)
}
