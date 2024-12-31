package repository

import (
	"context"

	"kimiyomi/backend/src/domain/entity"

	"github.com/google/uuid"
)

// ContentRepository はコンテンツの永続化を担当するインターフェースです
type ContentRepository interface {
	// Create は新しいコンテンツを作成します
	Create(ctx context.Context, content *entity.Content) error

	// FindByID は指定されたIDのコンテンツを取得します
	FindByID(ctx context.Context, id uuid.UUID) (*entity.Content, error)

	// FindByUserID は指定されたユーザーIDのコンテンツ一覧を取得します
	FindByUserID(ctx context.Context, userID uuid.UUID) ([]*entity.Content, error)

	// Update は既存のコンテンツを更新します
	Update(ctx context.Context, content *entity.Content) error

	// Delete は指定されたIDのコンテンツを削除します
	Delete(ctx context.Context, id uuid.UUID) error

	// FindByDiagnosisID は指定された診断IDに紐付けられたコンテンツ一覧を取得します
	FindByDiagnosisID(ctx context.Context, diagnosisID uuid.UUID) ([]*entity.Content, error)

	// AttachToDiagnosis はコンテンツを診断に紐付けます
	AttachToDiagnosis(ctx context.Context, contentID, diagnosisID uuid.UUID) error

	// DetachFromDiagnosis はコンテンツと診断の紐付けを解除します
	DetachFromDiagnosis(ctx context.Context, contentID, diagnosisID uuid.UUID) error
}
