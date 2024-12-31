package entity

import (
	"time"

	"github.com/google/uuid"
)

// PlanType はサブスクリプションプランの種類を表す型です
type PlanType string

const (
	PlanTypeBasic   PlanType = "basic"
	PlanTypePremium PlanType = "premium"
)

// SubscriptionStatus はサブスクリプションの状態を表す型です
type SubscriptionStatus string

const (
	SubscriptionStatusActive   SubscriptionStatus = "active"
	SubscriptionStatusInactive SubscriptionStatus = "inactive"
	SubscriptionStatusExpired  SubscriptionStatus = "expired"
)

// Subscription はサブスクリプションを表すエンティティです
type Subscription struct {
	ID        uuid.UUID          `json:"id"`
	UserID    uuid.UUID          `json:"user_id"`
	PlanType  PlanType           `json:"plan_type"`
	Status    SubscriptionStatus `json:"status"`
	StartDate time.Time          `json:"start_date"`
	EndDate   *time.Time         `json:"end_date,omitempty"`
	CreatedAt time.Time          `json:"created_at"`
	UpdatedAt time.Time          `json:"updated_at"`
}

// NewSubscription は新しいSubscriptionエンティティを作成します
func NewSubscription(
	userID uuid.UUID,
	planType PlanType,
	startDate time.Time,
	endDate *time.Time,
) (*Subscription, error) {
	if userID == uuid.Nil {
		return nil, ErrInvalidUserID
	}
	if !isValidPlanType(planType) {
		return nil, ErrInvalidPlanType
	}
	if startDate.IsZero() {
		return nil, ErrInvalidStartDate
	}
	if endDate != nil && endDate.Before(startDate) {
		return nil, ErrInvalidEndDate
	}

	now := time.Now()
	return &Subscription{
		ID:        uuid.New(),
		UserID:    userID,
		PlanType:  planType,
		Status:    SubscriptionStatusActive,
		StartDate: startDate,
		EndDate:   endDate,
		CreatedAt: now,
		UpdatedAt: now,
	}, nil
}

// isValidPlanType はPlanTypeが有効かどうかを確認します
func isValidPlanType(pt PlanType) bool {
	switch pt {
	case PlanTypeBasic, PlanTypePremium:
		return true
	default:
		return false
	}
}

// UpdateStatus はサブスクリプションのステータスを更新します
func (s *Subscription) UpdateStatus(status SubscriptionStatus) error {
	if !isValidStatus(status) {
		return ErrInvalidStatus
	}
	s.Status = status
	s.UpdatedAt = time.Now()
	return nil
}

// isValidStatus はSubscriptionStatusが有効かどうかを確認します
func isValidStatus(status SubscriptionStatus) bool {
	switch status {
	case SubscriptionStatusActive, SubscriptionStatusInactive, SubscriptionStatusExpired:
		return true
	default:
		return false
	}
}

// IsActive はサブスクリプションがアクティブかどうかを確認します
func (s *Subscription) IsActive() bool {
	if s.Status != SubscriptionStatusActive {
		return false
	}
	now := time.Now()
	if s.EndDate != nil && now.After(*s.EndDate) {
		return false
	}
	return true
}

// Validate はサブスクリプションの妥当性を検証します
func (s *Subscription) Validate() error {
	if s.ID == uuid.Nil {
		return ErrInvalidID
	}
	if s.UserID == uuid.Nil {
		return ErrInvalidUserID
	}
	if !isValidPlanType(s.PlanType) {
		return ErrInvalidPlanType
	}
	if !isValidStatus(s.Status) {
		return ErrInvalidStatus
	}
	if s.StartDate.IsZero() {
		return ErrInvalidStartDate
	}
	if s.EndDate != nil && s.EndDate.Before(s.StartDate) {
		return ErrInvalidEndDate
	}
	return nil
}
