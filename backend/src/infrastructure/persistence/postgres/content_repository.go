package postgres

import (
	"context"
	"database/sql"
	"fmt"

	"kimiyomi/backend/src/domain/entity"
	"kimiyomi/backend/src/domain/repository"

	"github.com/google/uuid"
)

// ContentRepository はPostgreSQLを使用したContentRepositoryの実装です
type ContentRepository struct {
	db *sql.DB
}

// NewContentRepository は新しいContentRepositoryを作成します
func NewContentRepository(db *sql.DB) repository.ContentRepository {
	return &ContentRepository{db: db}
}

// Create は新しいコンテンツを作成します
func (r *ContentRepository) Create(ctx context.Context, content *entity.Content) error {
	query := `
		INSERT INTO contents (
			id, user_id, title, description, content_type, file_path, price, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
	`

	_, err := r.db.ExecContext(ctx, query,
		content.ID,
		content.UserID,
		content.Title,
		content.Description,
		content.ContentType,
		content.FilePath,
		content.Price,
		content.CreatedAt,
		content.UpdatedAt,
	)
	if err != nil {
		return fmt.Errorf("failed to create content: %w", err)
	}

	return nil
}

// FindByID は指定されたIDのコンテンツを取得します
func (r *ContentRepository) FindByID(ctx context.Context, id uuid.UUID) (*entity.Content, error) {
	query := `
		SELECT id, user_id, title, description, content_type, file_path, price, created_at, updated_at
		FROM contents
		WHERE id = $1
	`

	content := &entity.Content{}
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&content.ID,
		&content.UserID,
		&content.Title,
		&content.Description,
		&content.ContentType,
		&content.FilePath,
		&content.Price,
		&content.CreatedAt,
		&content.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("content not found")
	}
	if err != nil {
		return nil, fmt.Errorf("failed to find content: %w", err)
	}

	return content, nil
}

// FindByUserID は指定されたユーザーIDのコンテンツ一覧を取得します
func (r *ContentRepository) FindByUserID(ctx context.Context, userID uuid.UUID) ([]*entity.Content, error) {
	query := `
		SELECT id, user_id, title, description, content_type, file_path, price, created_at, updated_at
		FROM contents
		WHERE user_id = $1
		ORDER BY created_at DESC
	`

	rows, err := r.db.QueryContext(ctx, query, userID)
	if err != nil {
		return nil, fmt.Errorf("failed to find contents: %w", err)
	}
	defer rows.Close()

	var contents []*entity.Content
	for rows.Next() {
		content := &entity.Content{}
		err := rows.Scan(
			&content.ID,
			&content.UserID,
			&content.Title,
			&content.Description,
			&content.ContentType,
			&content.FilePath,
			&content.Price,
			&content.CreatedAt,
			&content.UpdatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan content: %w", err)
		}
		contents = append(contents, content)
	}

	if err = rows.Err(); err != nil {
		return nil, fmt.Errorf("error iterating contents: %w", err)
	}

	return contents, nil
}

// Update は既存のコンテンツを更新します
func (r *ContentRepository) Update(ctx context.Context, content *entity.Content) error {
	query := `
		UPDATE contents
		SET title = $1, description = $2, price = $3, updated_at = $4
		WHERE id = $5
	`

	result, err := r.db.ExecContext(ctx, query,
		content.Title,
		content.Description,
		content.Price,
		content.UpdatedAt,
		content.ID,
	)
	if err != nil {
		return fmt.Errorf("failed to update content: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}
	if rowsAffected == 0 {
		return fmt.Errorf("content not found")
	}

	return nil
}

// Delete は指定されたIDのコンテンツを削除します
func (r *ContentRepository) Delete(ctx context.Context, id uuid.UUID) error {
	query := `DELETE FROM contents WHERE id = $1`

	result, err := r.db.ExecContext(ctx, query, id)
	if err != nil {
		return fmt.Errorf("failed to delete content: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}
	if rowsAffected == 0 {
		return fmt.Errorf("content not found")
	}

	return nil
}

// FindByDiagnosisID は指定された診断IDに紐付けられたコンテンツ一覧を取得します
func (r *ContentRepository) FindByDiagnosisID(ctx context.Context, diagnosisID uuid.UUID) ([]*entity.Content, error) {
	query := `
		SELECT c.id, c.user_id, c.title, c.description, c.content_type, c.file_path, c.price, c.created_at, c.updated_at
		FROM contents c
		INNER JOIN diagnosis_contents dc ON c.id = dc.content_id
		WHERE dc.diagnosis_id = $1
		ORDER BY c.created_at DESC
	`

	rows, err := r.db.QueryContext(ctx, query, diagnosisID)
	if err != nil {
		return nil, fmt.Errorf("failed to find contents: %w", err)
	}
	defer rows.Close()

	var contents []*entity.Content
	for rows.Next() {
		content := &entity.Content{}
		err := rows.Scan(
			&content.ID,
			&content.UserID,
			&content.Title,
			&content.Description,
			&content.ContentType,
			&content.FilePath,
			&content.Price,
			&content.CreatedAt,
			&content.UpdatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan content: %w", err)
		}
		contents = append(contents, content)
	}

	if err = rows.Err(); err != nil {
		return nil, fmt.Errorf("error iterating contents: %w", err)
	}

	return contents, nil
}

// AttachToDiagnosis はコンテンツを診断に紐付けます
func (r *ContentRepository) AttachToDiagnosis(ctx context.Context, contentID, diagnosisID uuid.UUID) error {
	query := `
		INSERT INTO diagnosis_contents (id, diagnosis_id, content_id, created_at)
		VALUES ($1, $2, $3, $4)
	`

	_, err := r.db.ExecContext(ctx, query,
		uuid.New(),
		diagnosisID,
		contentID,
		sql.NullTime{Time: entity.Now(), Valid: true},
	)
	if err != nil {
		return fmt.Errorf("failed to attach content to diagnosis: %w", err)
	}

	return nil
}

// DetachFromDiagnosis はコンテンツと診断の紐付けを解除します
func (r *ContentRepository) DetachFromDiagnosis(ctx context.Context, contentID, diagnosisID uuid.UUID) error {
	query := `
		DELETE FROM diagnosis_contents
		WHERE content_id = $1 AND diagnosis_id = $2
	`

	result, err := r.db.ExecContext(ctx, query, contentID, diagnosisID)
	if err != nil {
		return fmt.Errorf("failed to detach content from diagnosis: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}
	if rowsAffected == 0 {
		return fmt.Errorf("content not attached to diagnosis")
	}

	return nil
}
