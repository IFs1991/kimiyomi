package handler

import (
	"net/http"

	"kimiyomi/backend/src/domain/entity"
	"kimiyomi/backend/src/usecase"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/shopspring/decimal"
)

// ContentHandler はコンテンツ関連のAPIハンドラーです
type ContentHandler struct {
	contentUseCase *usecase.ContentUseCase
}

// NewContentHandler は新しいContentHandlerを作成します
func NewContentHandler(contentUseCase *usecase.ContentUseCase) *ContentHandler {
	return &ContentHandler{
		contentUseCase: contentUseCase,
	}
}

// CreateContentRequest はコンテンツ作成のリクエストです
type CreateContentRequest struct {
	Title       string          `json:"title" binding:"required"`
	Description string          `json:"description"`
	ContentType string          `json:"content_type" binding:"required,oneof=image video"`
	Price       decimal.Decimal `json:"price" binding:"required,min=0"`
}

// CreateContent はコンテンツを作成します
func (h *ContentHandler) CreateContent(c *gin.Context) {
	var req CreateContentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// ファイルを取得
	file, err := c.FormFile("file")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "file is required"})
		return
	}

	// ユーザーIDを取得（認証ミドルウェアから）
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	input := usecase.CreateContentInput{
		UserID:      userID.(uuid.UUID),
		Title:       req.Title,
		Description: req.Description,
		ContentType: entity.ContentType(req.ContentType),
		File:        file,
		Price:       req.Price,
	}

	content, err := h.contentUseCase.CreateContent(c.Request.Context(), input)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, content)
}

// GetContent はコンテンツを取得します
func (h *ContentHandler) GetContent(c *gin.Context) {
	contentID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid content id"})
		return
	}

	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	input := usecase.GetContentInput{
		ContentID: contentID,
		UserID:    userID.(uuid.UUID),
	}

	content, err := h.contentUseCase.GetContent(c.Request.Context(), input)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, content)
}

// AttachContentToDiagnosisRequest は診断へのコンテンツ紐付けリクエストです
type AttachContentToDiagnosisRequest struct {
	DiagnosisID string `json:"diagnosis_id" binding:"required"`
}

// AttachContentToDiagnosis はコンテンツを診断に紐付けます
func (h *ContentHandler) AttachContentToDiagnosis(c *gin.Context) {
	contentID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid content id"})
		return
	}

	var req AttachContentToDiagnosisRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	diagnosisID, err := uuid.Parse(req.DiagnosisID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid diagnosis id"})
		return
	}

	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	input := usecase.AttachContentToDiagnosisInput{
		ContentID:   contentID,
		DiagnosisID: diagnosisID,
		UserID:      userID.(uuid.UUID),
	}

	if err := h.contentUseCase.AttachContentToDiagnosis(c.Request.Context(), input); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.Status(http.StatusNoContent)
}

// RegisterRoutes はルートを登録します
func (h *ContentHandler) RegisterRoutes(r *gin.RouterGroup) {
	contents := r.Group("/contents")
	{
		contents.POST("", h.CreateContent)
		contents.GET("/:id", h.GetContent)
		contents.POST("/:id/diagnoses", h.AttachContentToDiagnosis)
	}
}
