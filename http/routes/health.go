package routes

import "lunch/http/handler"

func NewHealthRouter(ctx *handler.Context) error {
	return ctx.JSON(map[string]string{"status": "ok"})
}
