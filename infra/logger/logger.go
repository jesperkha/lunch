package logger

import (
	"log/slog"
	"lunch/domain/port"
)

func NewLogger() port.Logger {
	return slog.Default()
}
