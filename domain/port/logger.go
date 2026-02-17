package port

import "context"

type Logger interface {
	// Info prints info-level logs.
	Info(ctx context.Context, msg string, args ...any)

	// Warn prints warning-level logs.
	Warn(ctx context.Context, msg string, args ...any)

	// Debug prints debug-level logs.
	Debug(ctx context.Context, msg string, args ...any)

	// Error prints error-level logs.
	Error(ctx context.Context, msg string, args ...any)

	// Fatal prints error-level logs followed by os.Exit
	Fatal(ctx context.Context, msg string, args ...any)
}
