package auth

import (
	"errors"
	"time"

	"kimiyomi/backend/src/domain/auth"

	"github.com/golang-jwt/jwt/v5"
)

// JWTTokenService はJWTを使用したTokenServiceの実装です
type JWTTokenService struct {
	config *auth.JWTConfig
}

// NewJWTTokenService は新しいJWTTokenServiceを作成します
func NewJWTTokenService(config *auth.JWTConfig) auth.TokenService {
	return &JWTTokenService{
		config: config,
	}
}

// GenerateToken は新しいJWTトークンを生成します
func (s *JWTTokenService) GenerateToken(userID string, role string) (string, error) {
	claims := &auth.Claims{
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(s.config.TokenDuration)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			NotBefore: jwt.NewNumericDate(time.Now()),
		},
		UserID: userID,
		Role:   role,
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(s.config.SecretKey))
}

// ValidateToken はトークンを検証し、含まれる情報を返します
func (s *JWTTokenService) ValidateToken(tokenString string) (*auth.Claims, error) {
	token, err := jwt.ParseWithClaims(tokenString, &auth.Claims{}, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, errors.New("unexpected signing method")
		}
		return []byte(s.config.SecretKey), nil
	})

	if err != nil {
		return nil, err
	}

	if claims, ok := token.Claims.(*auth.Claims); ok && token.Valid {
		return claims, nil
	}

	return nil, errors.New("invalid token")
}

// RefreshToken は新しいトークンを生成します
func (s *JWTTokenService) RefreshToken(tokenString string) (string, error) {
	claims, err := s.ValidateToken(tokenString)
	if err != nil {
		return "", err
	}

	return s.GenerateToken(claims.UserID, claims.Role)
}
