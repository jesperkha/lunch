package routes

import "lunch/pkg/http/router"

func newApiMux() *router.Mux {
	m := router.NewMux()

	return m
}
