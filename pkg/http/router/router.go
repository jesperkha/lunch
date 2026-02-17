package router

import (
	"context"
	"log"
	"lunch/pkg/http/handler"
	"net/http"

	"github.com/jesperkha/notifier"
)

// Router wraps chi.Mux and provides a simplified API. Routes use the internal
// Handler type. It also implements http.Handler.
type Router struct {
	mux     *Mux
	cleanup func()
}

func New(middleware ...func(http.Handler) http.Handler) *Router {
	mux := NewMux(middleware...)
	return &Router{mux, func() {}}
}

func (rt *Router) Handle(method string, pattern string, h handler.Handler, middleware ...handler.Middleware) {
	rt.mux.Handle(method, pattern, h, middleware...)
}

func (r *Router) Mount(pattern string, handler http.Handler, middleware ...handler.Middleware) {
	r.mux.Mount(pattern, handler, middleware...)
}

func (r *Router) OnCleanup(f func()) {
	r.cleanup = f
}

func (r *Router) Serve(notif *notifier.Notifier, port string) {
	ctx := context.Background()
	done, finish := notif.Register()

	server := &http.Server{
		Addr:    port,
		Handler: r.mux,
	}

	go func() {
		<-done
		if err := server.Shutdown(ctx); err != nil {
			log.Printf("shutdown failed: %v", err)
		}

		log.Println("server stopped")
		r.cleanup()
		finish()
	}()

	log.Println("server running at http://localhost" + port)
	if err := server.ListenAndServe(); err != http.ErrServerClosed {
		log.Printf("error starting http server: %v", err)
	}
}

func (rt Router) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	rt.mux.ServeHTTP(w, r)
}
