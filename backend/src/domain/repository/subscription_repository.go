package repository

import (
	"context"

	"kimiyomi/backend/src/domain/entity"

	"github.com/google/uuid"
)

// SubscriptionRepository はサブスクリプションの永続化を担当するインターフェースです
type SubscriptionRepository interface {
	// Create は新しいサブスクリプションを作成します
	Create(ctx context.Context, subscription *entity.Subscription) error

	// FindByID は指定されたIDのサブスクリプションを取得します
	FindByID(ctx context.Context, id uuid.UUID) (*entity.Subscription, error)

	// FindByUserID は指定されたユーザーIDのアクティブなサブスクリプションを取得します
	FindByUserID(ctx context.Context, userID uuid.UUID) (*entity.Subscription, error)

	// Update は既存のサブスクリプションを更新します
	Update(ctx context.Context, subscription *entity.Subscription) error

	// Delete は指定されたIDのサブスクリプションを削除します
	Delete(ctx context.Context, id uuid.UUID) error

	// FindActiveByUserID は指定されたユーザーIDのアクティブなサブスクリプションを取得します
	FindActiveByUserID(ctx context.Context, userID uuid.UUID) (*entity.Subscription, error)

	// UpdateStatus はサブスクリプションのステータスを更新します
	UpdateStatus(ctx context.Context, id uuid.UUID, status entity.SubscriptionStatus) error

	// ListExpired は期限切れのサブスクリプション一覧を取得します
	ListExpired(ctx context.Context) ([]*entity.Subscription, error)
}
