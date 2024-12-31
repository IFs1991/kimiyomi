package router

import (
	"kimiyomi/backend/src/api/handler"
	"kimiyomi/backend/src/api/middleware"

	"github.com/gin-gonic/gin"
)

// SetupAuthRoutes は認証関連のルーティングを設定します
func SetupAuthRoutes(router *gin.Engine, authHandler *handler.AuthHandler, authMiddleware *middleware.AuthMiddleware) {
	auth := router.Group("/auth")
	{
		auth.POST("/login", authHandler.Login)
		auth.POST("/register", authHandler.Register)
		auth.POST("/refresh", authHandler.RefreshToken)
	}
}
