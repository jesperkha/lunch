package main

import (
	"log"
	"os"
	"syscall"

	"lunch/bootstrap"
	"lunch/config"

	"github.com/jesperkha/notifier"
)

func main() {
	notif := notifier.New()
	config := config.Load()

	go bootstrap.RunApi(notif, config)
	go bootstrap.RunDashboard(notif, config)

	notif.NotifyOnSignal(os.Interrupt, syscall.SIGINT)
	log.Println("shutdown complete")
}
