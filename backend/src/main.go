package main

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"kimiyomi/backend/src/api/handler"
	"kimiyomi/backend/src/api/middleware"
	"kimiyomi/backend/src/api/router"
	"kimiyomi/backend/src/infrastructure/auth"
	"kimiyomi/backend/src/infrastructure/persistence"
	"kimiyomi/backend/src/usecase"

	"github.com/gin-gonic/gin"
	_ "github.com/lib/pq"
)

func main() {
	// デガーの初期化
	logger := log.New(os.Stdout, "[KIMIYOMI] ", log.LstdFlags)

	// 環境変数の検証
	if err := validateEnv(); err != nil {
		logger.Fatalf("環境変数の検証に失敗しました: %v", err)
	}

	// データベース接続
	db, err := sql.Open("postgres", os.Getenv("DATABASE_URL"))
	if err != nil {
		logger.Fatalf("データベース接続に失敗しました: %v", err)
	}
	defer db.Close()

	// データベース接続の確認
	if err := db.Ping(); err != nil {
		logger.Fatalf("データベース接続の確認に失敗しました: %v", err)
	}

	// リポジトリの初期化
	userRepo := persistence.NewUserRepository(db)

	// トークンサービスの初期化
	tokenService := auth.NewTokenService(
		os.Getenv("JWT_SECRET_KEY"),
		24,  // トークンの有効期限（時間）
		168, // リフレッシュトークンの有効期限（時間）
	)

	// ユースケースの初期化
	authUseCase := usecase.NewAuthUseCase(userRepo)

	// ミドルウェアの初期化
	authMiddleware := middleware.NewAuthMiddleware(tokenService)

	// ハンドラーの初期化
	authHandler := handler.NewAuthHandler(authUseCase, tokenService)

	// Ginエンジンの初期化
	if os.Getenv("APP_ENV") == "production" {
		gin.SetMode(gin.ReleaseMode)
	}
	engine := gin.New()
	engine.Use(gin.Recovery())
	engine.Use(gin.Logger())

	// ルーターの初期化と設定
	r := router.NewRouter(engine, authHandler, authMiddleware)
	r.Setup()

	// HTTPサーバーの設定
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	srv := &http.Server{
		Addr:         ":" + port,
		Handler:      engine,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
	}

	// サーバーを非同期で起動
	go func() {
		logger.Printf("サーバーを起動しました。ポート: %s\n", port)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			logger.Fatalf("サーバーの起動に失敗しました: %v", err)
		}
	}()

	// Graceful shutdown の設定
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	logger.Println("シャットダウンを開始します...")

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if err := srv.Shutdown(ctx); err != nil {
		logger.Fatalf("サーバーのシャットダウンに失敗しました: %v", err)
	}

	logger.Println("サーバーを正常にシャットダウンしました")
}

func validateEnv() error {
	required := []string{
		"DATABASE_URL",
		"JWT_SECRET_KEY",
		"PORT",
	}

	for _, env := range required {
		if os.Getenv(env) == "" {
			return fmt.Errorf("環境変数 %s が設定されていません", env)
		}
	}

	return nil
}
