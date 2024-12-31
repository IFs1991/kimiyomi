package auth

import (
	"context"
	"errors"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/auth"
	"google.golang.org/api/option"

	domainAuth "kimiyomi/backend/src/domain/auth"
)

type firebaseAuthService struct {
	client *auth.Client
}

// NewFirebaseAuthService はFirebase認証サービスのインスタンスを生成します
func NewFirebaseAuthService(credentialsFile string) (domainAuth.AuthService, error) {
	opt := option.WithCredentialsFile(credentialsFile)
	app, err := firebase.NewApp(context.Background(), nil, opt)
	if err != nil {
		return nil, err
	}

	client, err := app.Auth(context.Background())
	if err != nil {
		return nil, err
	}

	return &firebaseAuthService{
		client: client,
	}, nil
}

// VerifyFirebaseToken はFirebase認証トークンを検証します
func (s *firebaseAuthService) VerifyFirebaseToken(ctx context.Context, idToken string) (string, error) {
	token, err := s.client.VerifyIDToken(ctx, idToken)
	if err != nil {
		return "", &domainAuth.AuthError{Message: "invalid firebase token"}
	}

	return token.UID, nil
}

// ValidateToken は未実装（Firebase認証サービスでは不要）
func (s *firebaseAuthService) ValidateToken(ctx context.Context, token string) (string, error) {
	return "", errors.New("not implemented in Firebase service")
}

// GenerateToken は未実装（Firebase認証サービスでは不要）
func (s *firebaseAuthService) GenerateToken(ctx context.Context, userID string) (string, error) {
	return "", errors.New("not implemented in Firebase service")
}
