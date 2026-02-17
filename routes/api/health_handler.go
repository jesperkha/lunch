package api

import "lunch/pkg/http/handler"

func HealthHandler(ctx *handler.Context) error {
	return ctx.JSON(map[string]string{"status": "ok"})
}
