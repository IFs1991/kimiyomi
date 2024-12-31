package handler

import (
	"net/http"

	"kimiyomi/backend/src/domain/auth"
	"kimiyomi/backend/src/usecase"

	"github.com/gin-gonic/gin"
)

// AuthHandler は認証関連のエンドポイントを提供します
type AuthHandler struct {
	authUseCase  usecase.AuthUseCase
	tokenService auth.TokenService
}

// NewAuthHandler は新しいAuthHandlerを作成します
func NewAuthHandler(authUseCase usecase.AuthUseCase, tokenService auth.TokenService) *AuthHandler {
	return &AuthHandler{
		authUseCase:  authUseCase,
		tokenService: tokenService,
	}
}

// LoginRequest はログインリクエストの構造を定義します
type LoginRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=8"`
}

// LoginResponse はログインレスポンスの構造を定義します
type LoginResponse struct {
	Token        string `json:"token"`
	RefreshToken string `json:"refresh_token"`
	UserID       string `json:"user_id"`
	Role         string `json:"role"`
}

// Login はユーザーログインを処理します
func (h *AuthHandler) Login(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request"})
		return
	}

	user, err := h.authUseCase.Authenticate(c.Request.Context(), req.Email, req.Password)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid credentials"})
		return
	}

	token, err := h.tokenService.GenerateToken(user.ID, user.Role)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to generate token"})
		return
	}

	refreshToken, err := h.tokenService.GenerateToken(user.ID, user.Role)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to generate refresh token"})
		return
	}

	c.JSON(http.StatusOK, LoginResponse{
		Token:        token,
		RefreshToken: refreshToken,
		UserID:       user.ID,
		Role:         user.Role,
	})
}

// RefreshTokenRequest はトークンリフレッシュリクエストの構造を定義します
type RefreshTokenRequest struct {
	RefreshToken string `json:"refresh_token" binding:"required"`
}

// RefreshToken はトークンのリフレッシュを処理します
func (h *AuthHandler) RefreshToken(c *gin.Context) {
	var req RefreshTokenRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request"})
		return
	}

	newToken, err := h.tokenService.RefreshToken(req.RefreshToken)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid refresh token"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"token": newToken,
	})
}

// RegisterRequest はユーザー登録リクエストの構造を定義します
type RegisterRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=8"`
	Name     string `json:"name" binding:"required"`
}

// Register は新規ユーザー登録を処理します
func (h *AuthHandler) Register(c *gin.Context) {
	var req RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request"})
		return
	}

	user, err := h.authUseCase.Register(c.Request.Context(), req.Email, req.Password, req.Name)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "registration failed"})
		return
	}

	token, err := h.tokenService.GenerateToken(user.ID, user.Role)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to generate token"})
		return
	}

	refreshToken, err := h.tokenService.GenerateToken(user.ID, user.Role)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to generate refresh token"})
		return
	}

	c.JSON(http.StatusCreated, LoginResponse{
		Token:        token,
		RefreshToken: refreshToken,
		UserID:       user.ID,
		Role:         user.Role,
	})
}
