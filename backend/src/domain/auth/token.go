package auth

import (
	"errors"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

// Claims はJWTのクレーム情報を表します
type Claims struct {
	jwt.RegisteredClaims
	UserID string `json:"user_id"`
	Role   string `json:"role"`
}

// TokenService はトークン生成と検証を行うインターフェースです
type TokenService interface {
	// GenerateToken はJWTトークンを生成します
	GenerateToken(userID string, role string) (string, error)

	// ValidateToken はトークンを検証し、クレーム情報を返します
	ValidateToken(tokenString string) (*Claims, error)

	// RefreshToken は新しいトークンを生成します
	RefreshToken(tokenString string) (string, error)
}

// JWTConfig はJWT設定を表します
type JWTConfig struct {
	SecretKey     string
	TokenDuration time.Duration
}

// JWTService はJWTトークンの生成と検証を行うサービスです
type JWTService struct {
	config JWTConfig
}

// NewJWTService は新しいJWTServiceを作成します
func NewJWTService(config JWTConfig) TokenService {
	return &JWTService{config: config}
}

// GenerateToken はJWTトークンを生成します
func (s *JWTService) GenerateToken(userID string, role string) (string, error) {
	claims := &Claims{
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

// ValidateToken はトークンを検証し、クレーム情報を返します
func (s *JWTService) ValidateToken(tokenString string) (*Claims, error) {
	token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		return []byte(s.config.SecretKey), nil
	})

	if err != nil {
		return nil, err
	}

	if claims, ok := token.Claims.(*Claims); ok && token.Valid {
		return claims, nil
	}

	return nil, errors.New("invalid token")
}

// RefreshToken は新しいトークンを生成します
func (s *JWTService) RefreshToken(tokenString string) (string, error) {
	claims, err := s.ValidateToken(tokenString)
	if err != nil {
		return "", err
	}

	return s.GenerateToken(claims.UserID, claims.Role)
}
