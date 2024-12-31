package auth

import (
	"context"
	"errors"
	"time"

	"kimiyomi/backend/src/domain/auth"

	"github.com/golang-jwt/jwt/v5"
)

type jwtAuthService struct {
	secretKey []byte
	expiry    time.Duration
}

// NewJWTAuthService はJWT認証サービスのインスタンスを生成します
func NewJWTAuthService(secretKey string, expiry time.Duration) auth.AuthService {
	return &jwtAuthService{
		secretKey: []byte(secretKey),
		expiry:    expiry,
	}
}

// GenerateToken はJWTトークンを生成します
func (s *jwtAuthService) GenerateToken(ctx context.Context, userID string) (string, error) {
	claims := jwt.MapClaims{
		"user_id": userID,
		"exp":     time.Now().Add(s.expiry).Unix(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(s.secretKey)
}

// ValidateToken はJWTトークンを検証します
func (s *jwtAuthService) ValidateToken(ctx context.Context, tokenString string) (string, error) {
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, errors.New("unexpected signing method")
		}
		return s.secretKey, nil
	})

	if err != nil {
		return "", &auth.AuthError{Message: "invalid token"}
	}

	if claims, ok := token.Claims.(jwt.MapClaims); ok && token.Valid {
		if userID, ok := claims["user_id"].(string); ok {
			return userID, nil
		}
	}

	return "", &auth.AuthError{Message: "invalid token claims"}
}

// VerifyFirebaseToken は未実装（JWT認証サービスでは不要）
func (s *jwtAuthService) VerifyFirebaseToken(ctx context.Context, idToken string) (string, error) {
	return "", errors.New("not implemented in JWT service")
}
