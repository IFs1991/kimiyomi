package auth

import (
	"context"
)

// AuthService は認証に関する操作を定義するインターフェース
type AuthService interface {
	// ValidateToken はJWTトークンを検証し、ユーザーIDを返す
	ValidateToken(ctx context.Context, token string) (string, error)

	// GenerateToken はユーザーIDからJWTトークンを生成する
	GenerateToken(ctx context.Context, userID string) (string, error)

	// VerifyFirebaseToken はFirebase認証トークンを検証する
	VerifyFirebaseToken(ctx context.Context, idToken string) (string, error)
}

// AuthError は認証エラーを表す
type AuthError struct {
	Message string
}

func (e *AuthError) Error() string {
	return e.Message
}
