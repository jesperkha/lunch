package main

import (
	"log"
	"os"
	"syscall"

	"github.com/jesperkha/lunch/bootstrap"
	"github.com/jesperkha/notifier"
)

func main() {
	notif := notifier.New()

	go bootstrap.RunApi(notif)
	go bootstrap.RunDashboard(notif)

	notif.NotifyOnSignal(os.Interrupt, syscall.SIGINT)
	log.Println("shutdown complete")
}
