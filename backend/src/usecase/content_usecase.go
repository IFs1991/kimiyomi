package usecase

import (
	"context"
	"fmt"
	"mime/multipart"
	"path/filepath"

	"kimiyomi/backend/src/domain/entity"
	"kimiyomi/backend/src/domain/repository"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
)

// ContentUseCase はコンテンツ関連のユースケースを実装します
type ContentUseCase struct {
	contentRepo      repository.ContentRepository
	subscriptionRepo repository.SubscriptionRepository
	fileStorage      FileStorage
}

// FileStorage はファイルストレージの操作を定義するインターフェースです
type FileStorage interface {
	// Upload はファイルをストレージにアップロードします
	Upload(ctx context.Context, file *multipart.FileHeader) (string, error)
	// Delete はファイルをストレージから削除します
	Delete(ctx context.Context, filePath string) error
}

// NewContentUseCase は新しいContentUseCaseを作成します
func NewContentUseCase(
	contentRepo repository.ContentRepository,
	subscriptionRepo repository.SubscriptionRepository,
	fileStorage FileStorage,
) *ContentUseCase {
	return &ContentUseCase{
		contentRepo:      contentRepo,
		subscriptionRepo: subscriptionRepo,
		fileStorage:      fileStorage,
	}
}

// CreateContentInput はコンテンツ作成の入力データです
type CreateContentInput struct {
	UserID      uuid.UUID
	Title       string
	Description string
	ContentType entity.ContentType
	File        *multipart.FileHeader
	Price       decimal.Decimal
}

// CreateContent は新しいコンテンツを作成します
func (uc *ContentUseCase) CreateContent(ctx context.Context, input CreateContentInput) (*entity.Content, error) {
	// ファイルの拡張子を確認
	ext := filepath.Ext(input.File.Filename)
	if !isValidFileExtension(ext, input.ContentType) {
		return nil, fmt.Errorf("invalid file extension for content type: %s", ext)
	}

	// ファイルをストレージにアップロード
	filePath, err := uc.fileStorage.Upload(ctx, input.File)
	if err != nil {
		return nil, fmt.Errorf("failed to upload file: %w", err)
	}

	// コンテンツエンティティを作成
	content, err := entity.NewContent(
		input.UserID,
		input.Title,
		input.Description,
		input.ContentType,
		filePath,
		input.Price,
	)
	if err != nil {
		// アップロードしたファイルを削除
		_ = uc.fileStorage.Delete(ctx, filePath)
		return nil, err
	}

	// コンテンツを保存
	if err := uc.contentRepo.Create(ctx, content); err != nil {
		// アップロードしたファイルを削除
		_ = uc.fileStorage.Delete(ctx, filePath)
		return nil, fmt.Errorf("failed to create content: %w", err)
	}

	return content, nil
}

// AttachContentToDiagnosisInput は診断へのコンテンツ紐付けの入力データです
type AttachContentToDiagnosisInput struct {
	ContentID   uuid.UUID
	DiagnosisID uuid.UUID
	UserID      uuid.UUID
}

// AttachContentToDiagnosis はコンテンツを診断に紐付けます
func (uc *ContentUseCase) AttachContentToDiagnosis(ctx context.Context, input AttachContentToDiagnosisInput) error {
	// コンテンツの所有者確認
	content, err := uc.contentRepo.FindByID(ctx, input.ContentID)
	if err != nil {
		return fmt.Errorf("failed to find content: %w", err)
	}
	if content.UserID != input.UserID {
		return fmt.Errorf("user is not the owner of the content")
	}

	// コンテンツを診断に紐付け
	if err := uc.contentRepo.AttachToDiagnosis(ctx, input.ContentID, input.DiagnosisID); err != nil {
		return fmt.Errorf("failed to attach content to diagnosis: %w", err)
	}

	return nil
}

// GetContentInput はコンテンツ取得の入力データです
type GetContentInput struct {
	ContentID uuid.UUID
	UserID    uuid.UUID
}

// GetContent は指定されたコンテンツを取得します
func (uc *ContentUseCase) GetContent(ctx context.Context, input GetContentInput) (*entity.Content, error) {
	// コンテンツを取得
	content, err := uc.contentRepo.FindByID(ctx, input.ContentID)
	if err != nil {
		return nil, fmt.Errorf("failed to find content: %w", err)
	}

	// コンテンツの所有者またはアクティブなサブスクリプションを持つユーザーのみアクセス可能
	if content.UserID != input.UserID {
		subscription, err := uc.subscriptionRepo.FindActiveByUserID(ctx, input.UserID)
		if err != nil || !subscription.IsActive() {
			return nil, fmt.Errorf("user does not have access to this content")
		}
	}

	return content, nil
}

// isValidFileExtension はファイルの拡張子が有効かどうかを確認します
func isValidFileExtension(ext string, contentType entity.ContentType) bool {
	switch contentType {
	case entity.ContentTypeImage:
		return ext == ".jpg" || ext == ".jpeg" || ext == ".png" || ext == ".gif"
	case entity.ContentTypeVideo:
		return ext == ".mp4" || ext == ".mov" || ext == ".avi"
	default:
		return false
	}
}
