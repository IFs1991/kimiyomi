package router

import (
	"kimiyomi/backend/src/api/handler"
	"kimiyomi/backend/src/api/middleware"

	"github.com/gin-gonic/gin"
)

// Router はアプリケーションのルーティングを管理します
type Router struct {
	engine         *gin.Engine
	authHandler    *handler.AuthHandler
	authMiddleware *middleware.AuthMiddleware
}

// NewRouter は新しいRouterを作成します
func NewRouter(
	engine *gin.Engine,
	authHandler *handler.AuthHandler,
	authMiddleware *middleware.AuthMiddleware,
) *Router {
	return &Router{
		engine:         engine,
		authHandler:    authHandler,
		authMiddleware: authMiddleware,
	}
}

// Setup はルーティングを設定します
func (r *Router) Setup() {
	// ミドルウェアの設定
	r.engine.Use(gin.Logger())
	r.engine.Use(gin.Recovery())

	// CORSの設定
	r.engine.Use(middleware.CORS())

	// 認証関連のルーティング
	SetupAuthRoutes(r.engine, r.authHandler, r.authMiddleware)

	// ヘルスチェック
	r.engine.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status": "ok",
		})
	})
}
