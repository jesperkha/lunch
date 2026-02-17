package main

import (
	"os"
	"syscall"

	"lunch/config"
	"lunch/http"
	"lunch/infra/logger"

	"github.com/jesperkha/notifier"
)

func main() {
	notif := notifier.New()
	config := config.Load()

	logger := logger.NewLogger()

	go http.RunApi(notif, logger, config)

	notif.NotifyOnSignal(os.Interrupt, syscall.SIGINT)
	logger.Info("shutdown complete")
}
