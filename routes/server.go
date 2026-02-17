package routes

import (
	"lunch/config"
	"lunch/domain/port"
	"lunch/pkg/http/router"

	"github.com/jesperkha/notifier"
)

func RunServer(
	notif *notifier.Notifier,
	logger port.Logger,
	config *config.Config,
) {
	r := router.New()

	r.Mount("/", newDashboardMux())
	r.Mount("/api", newApiMux())

	r.Serve(notif, config.Port)
}
