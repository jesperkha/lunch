package routes

import "lunch/adapter/http/handler"

func NewHealthRouter(ctx *handler.Context) error {
	return ctx.JSON(map[string]string{"status": "ok"})
}
