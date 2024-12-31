package auth

import (
	"time"

	domainAuth "kimiyomi/backend/src/domain/auth"

	"github.com/golang-jwt/jwt/v5"
)

type TokenService struct {
	secretKey          string
	tokenExpiry        time.Duration
	refreshTokenExpiry time.Duration
}

// NewTokenService はJWTトークンサービスのインスタンスを生成します
func NewTokenService(secretKey string, tokenExpiryHours int, refreshTokenExpiryHours int) domainAuth.TokenService {
	return &TokenService{
		secretKey:          secretKey,
		tokenExpiry:        time.Duration(tokenExpiryHours) * time.Hour,
		refreshTokenExpiry: time.Duration(refreshTokenExpiryHours) * time.Hour,
	}
}

// GenerateToken はJWTトークンを生成します
func (s *TokenService) GenerateToken(userID string, role string) (string, error) {
	claims := &domainAuth.Claims{
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(s.tokenExpiry)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
		UserID: userID,
		Role:   role,
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(s.secretKey))
}

// ValidateToken はJWTトークンを検証します
func (s *TokenService) ValidateToken(tokenString string) (*domainAuth.Claims, error) {
	token, err := jwt.ParseWithClaims(tokenString, &domainAuth.Claims{}, func(token *jwt.Token) (interface{}, error) {
		return []byte(s.secretKey), nil
	})

	if err != nil {
		return nil, err
	}

	if claims, ok := token.Claims.(*domainAuth.Claims); ok && token.Valid {
		return claims, nil
	}

	return nil, jwt.ErrSignatureInvalid
}

// RefreshToken は新しいトークンを生成します
func (s *TokenService) RefreshToken(tokenString string) (string, error) {
	claims, err := s.ValidateToken(tokenString)
	if err != nil {
		return "", err
	}

	return s.GenerateToken(claims.UserID, claims.Role)
}
