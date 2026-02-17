package http

import (
	"lunch/config"
	"lunch/domain/port"
	"lunch/http/router"

	"github.com/jesperkha/notifier"
)

func RunDashboard(
	notif *notifier.Notifier,
	logger port.Logger,
	config *config.Config,
) {
	r := router.New(logger)

	r.Serve(notif, config.DashboardPort)
}
