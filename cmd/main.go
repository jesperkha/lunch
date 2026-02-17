package main

import (
	"os"
	"syscall"

	"lunch/config"
	"lunch/infra/logger"
	"lunch/routes"

	"github.com/jesperkha/notifier"
)

func main() {
	notif := notifier.New()
	config := config.Load()

	logger := logger.NewLogger()

	go routes.RunServer(
		notif,
		logger,
		config,
	)

	notif.NotifyOnSignal(os.Interrupt, syscall.SIGINT)
	logger.Info("shutdown complete")
}
