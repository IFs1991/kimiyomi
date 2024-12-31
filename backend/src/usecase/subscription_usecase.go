package usecase

import (
	"context"
	"fmt"
	"time"

	"kimiyomi/backend/src/domain/entity"
	"kimiyomi/backend/src/domain/repository"

	"github.com/google/uuid"
)

// SubscriptionUseCase はサブスクリプション関連のユースケースを実装します
type SubscriptionUseCase struct {
	subscriptionRepo repository.SubscriptionRepository
	paymentService   PaymentService
}

// PaymentService は決済処理を定義するインターフェースです
type PaymentService interface {
	// CreateSubscription は新しいサブスクリプションの決済を作成します
	CreateSubscription(ctx context.Context, userID uuid.UUID, planType entity.PlanType) error
	// CancelSubscription はサブスクリプションの決済をキャンセルします
	CancelSubscription(ctx context.Context, subscriptionID uuid.UUID) error
}

// NewSubscriptionUseCase は新しいSubscriptionUseCaseを作成します
func NewSubscriptionUseCase(
	subscriptionRepo repository.SubscriptionRepository,
	paymentService PaymentService,
) *SubscriptionUseCase {
	return &SubscriptionUseCase{
		subscriptionRepo: subscriptionRepo,
		paymentService:   paymentService,
	}
}

// CreateSubscriptionInput はサブスクリプション作成の入力データです
type CreateSubscriptionInput struct {
	UserID    uuid.UUID
	PlanType  entity.PlanType
	StartDate time.Time
	EndDate   *time.Time
}

// CreateSubscription は新しいサブスクリプションを作成します
func (uc *SubscriptionUseCase) CreateSubscription(ctx context.Context, input CreateSubscriptionInput) (*entity.Subscription, error) {
	// 既存のアクティブなサブスクリプションをチェック
	existing, err := uc.subscriptionRepo.FindActiveByUserID(ctx, input.UserID)
	if err == nil && existing != nil && existing.IsActive() {
		return nil, fmt.Errorf("user already has an active subscription")
	}

	// 決済処理
	if err := uc.paymentService.CreateSubscription(ctx, input.UserID, input.PlanType); err != nil {
		return nil, fmt.Errorf("failed to process payment: %w", err)
	}

	// サブスクリプションエンティティを作成
	subscription, err := entity.NewSubscription(
		input.UserID,
		input.PlanType,
		input.StartDate,
		input.EndDate,
	)
	if err != nil {
		return nil, err
	}

	// サブスクリプションを保存
	if err := uc.subscriptionRepo.Create(ctx, subscription); err != nil {
		return nil, fmt.Errorf("failed to create subscription: %w", err)
	}

	return subscription, nil
}

// CancelSubscriptionInput はサブスクリプションキャンセルの入力データです
type CancelSubscriptionInput struct {
	SubscriptionID uuid.UUID
	UserID         uuid.UUID
}

// CancelSubscription はサブスクリプションをキャンセルします
func (uc *SubscriptionUseCase) CancelSubscription(ctx context.Context, input CancelSubscriptionInput) error {
	// サブスクリプションを取得
	subscription, err := uc.subscriptionRepo.FindByID(ctx, input.SubscriptionID)
	if err != nil {
		return fmt.Errorf("failed to find subscription: %w", err)
	}

	// ユーザーの所有権を確認
	if subscription.UserID != input.UserID {
		return fmt.Errorf("user is not the owner of the subscription")
	}

	// 決済のキャンセル
	if err := uc.paymentService.CancelSubscription(ctx, input.SubscriptionID); err != nil {
		return fmt.Errorf("failed to cancel payment: %w", err)
	}

	// サブスクリプションのステータスを更新
	if err := uc.subscriptionRepo.UpdateStatus(ctx, input.SubscriptionID, entity.SubscriptionStatusInactive); err != nil {
		return fmt.Errorf("failed to update subscription status: %w", err)
	}

	return nil
}

// GetSubscriptionInput はサブスクリプション取得の入力データです
type GetSubscriptionInput struct {
	UserID uuid.UUID
}

// GetSubscription はユーザーのアクティブなサブスクリプションを取得します
func (uc *SubscriptionUseCase) GetSubscription(ctx context.Context, input GetSubscriptionInput) (*entity.Subscription, error) {
	subscription, err := uc.subscriptionRepo.FindActiveByUserID(ctx, input.UserID)
	if err != nil {
		return nil, fmt.Errorf("failed to find subscription: %w", err)
	}

	return subscription, nil
}

// ProcessExpiredSubscriptions は期限切れのサブスクリプションを処理します
func (uc *SubscriptionUseCase) ProcessExpiredSubscriptions(ctx context.Context) error {
	// 期限切れのサブスクリプションを取得
	expired, err := uc.subscriptionRepo.ListExpired(ctx)
	if err != nil {
		return fmt.Errorf("failed to list expired subscriptions: %w", err)
	}

	for _, subscription := range expired {
		// サブスクリプションのステータスを更新
		if err := uc.subscriptionRepo.UpdateStatus(ctx, subscription.ID, entity.SubscriptionStatusExpired); err != nil {
			// エラーをログに記録して続行
			fmt.Printf("failed to update subscription status: %v\n", err)
			continue
		}

		// 決済のキャンセル
		if err := uc.paymentService.CancelSubscription(ctx, subscription.ID); err != nil {
			// エラーをログに記録して続行
			fmt.Printf("failed to cancel payment: %v\n", err)
			continue
		}
	}

	return nil
}
