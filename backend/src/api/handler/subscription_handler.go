package handler

import (
	"net/http"
	"time"

	"kimiyomi/backend/src/domain/entity"
	"kimiyomi/backend/src/usecase"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// SubscriptionHandler はサブスクリプション関連のAPIハンドラーです
type SubscriptionHandler struct {
	subscriptionUseCase *usecase.SubscriptionUseCase
}

// NewSubscriptionHandler は新しいSubscriptionHandlerを作成します
func NewSubscriptionHandler(subscriptionUseCase *usecase.SubscriptionUseCase) *SubscriptionHandler {
	return &SubscriptionHandler{
		subscriptionUseCase: subscriptionUseCase,
	}
}

// CreateSubscriptionRequest はサブスクリプション作成のリクエストです
type CreateSubscriptionRequest struct {
	PlanType  string     `json:"plan_type" binding:"required,oneof=basic premium"`
	StartDate time.Time  `json:"start_date" binding:"required"`
	EndDate   *time.Time `json:"end_date"`
}

// CreateSubscription はサブスクリプションを作成します
func (h *SubscriptionHandler) CreateSubscription(c *gin.Context) {
	var req CreateSubscriptionRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	input := usecase.CreateSubscriptionInput{
		UserID:    userID.(uuid.UUID),
		PlanType:  entity.PlanType(req.PlanType),
		StartDate: req.StartDate,
		EndDate:   req.EndDate,
	}

	subscription, err := h.subscriptionUseCase.CreateSubscription(c.Request.Context(), input)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, subscription)
}

// CancelSubscription はサブスクリプションをキャンセルします
func (h *SubscriptionHandler) CancelSubscription(c *gin.Context) {
	subscriptionID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid subscription id"})
		return
	}

	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	input := usecase.CancelSubscriptionInput{
		SubscriptionID: subscriptionID,
		UserID:         userID.(uuid.UUID),
	}

	if err := h.subscriptionUseCase.CancelSubscription(c.Request.Context(), input); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.Status(http.StatusNoContent)
}

// GetSubscription はサブスクリプションを取得します
func (h *SubscriptionHandler) GetSubscription(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	input := usecase.GetSubscriptionInput{
		UserID: userID.(uuid.UUID),
	}

	subscription, err := h.subscriptionUseCase.GetSubscription(c.Request.Context(), input)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, subscription)
}

// HandleWebhook はStripeのWebhookを処理します
func (h *SubscriptionHandler) HandleWebhook(c *gin.Context) {
	payload, err := c.GetRawData()
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "failed to read payload"})
		return
	}

	signature := c.GetHeader("Stripe-Signature")
	if signature == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "missing signature header"})
		return
	}

	// Note: この実装は簡略化されています
	// 実際の実装では、Stripeのイベントを適切に処理する必要があります
	c.Status(http.StatusOK)
}

// RegisterRoutes はルートを登録します
func (h *SubscriptionHandler) RegisterRoutes(r *gin.RouterGroup) {
	subscriptions := r.Group("/subscriptions")
	{
		subscriptions.POST("", h.CreateSubscription)
		subscriptions.DELETE("/:id", h.CancelSubscription)
		subscriptions.GET("/current", h.GetSubscription)
	}

	// Webhookのルート
	r.POST("/webhook/stripe", h.HandleWebhook)
}
