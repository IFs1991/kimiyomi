package postgres

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"kimiyomi/backend/src/domain/entity"
	"kimiyomi/backend/src/domain/repository"

	"github.com/google/uuid"
)

// SubscriptionRepository はPostgreSQLを使用したSubscriptionRepositoryの実装です
type SubscriptionRepository struct {
	db *sql.DB
}

// NewSubscriptionRepository は新しいSubscriptionRepositoryを作成します
func NewSubscriptionRepository(db *sql.DB) repository.SubscriptionRepository {
	return &SubscriptionRepository{db: db}
}

// Create は新しいサブスクリプションを作成します
func (r *SubscriptionRepository) Create(ctx context.Context, subscription *entity.Subscription) error {
	query := `
		INSERT INTO subscriptions (
			id, user_id, plan_type, status, start_date, end_date, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
	`

	_, err := r.db.ExecContext(ctx, query,
		subscription.ID,
		subscription.UserID,
		subscription.PlanType,
		subscription.Status,
		subscription.StartDate,
		subscription.EndDate,
		subscription.CreatedAt,
		subscription.UpdatedAt,
	)
	if err != nil {
		return fmt.Errorf("failed to create subscription: %w", err)
	}

	return nil
}

// FindByID は指定されたIDのサブスクリプションを取得します
func (r *SubscriptionRepository) FindByID(ctx context.Context, id uuid.UUID) (*entity.Subscription, error) {
	query := `
		SELECT id, user_id, plan_type, status, start_date, end_date, created_at, updated_at
		FROM subscriptions
		WHERE id = $1
	`

	subscription := &entity.Subscription{}
	var endDate sql.NullTime
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&subscription.ID,
		&subscription.UserID,
		&subscription.PlanType,
		&subscription.Status,
		&subscription.StartDate,
		&endDate,
		&subscription.CreatedAt,
		&subscription.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("subscription not found")
	}
	if err != nil {
		return nil, fmt.Errorf("failed to find subscription: %w", err)
	}

	if endDate.Valid {
		subscription.EndDate = &endDate.Time
	}

	return subscription, nil
}

// FindByUserID は指定されたユーザーIDのサブスクリプションを取得します
func (r *SubscriptionRepository) FindByUserID(ctx context.Context, userID uuid.UUID) (*entity.Subscription, error) {
	query := `
		SELECT id, user_id, plan_type, status, start_date, end_date, created_at, updated_at
		FROM subscriptions
		WHERE user_id = $1
		ORDER BY created_at DESC
		LIMIT 1
	`

	subscription := &entity.Subscription{}
	var endDate sql.NullTime
	err := r.db.QueryRowContext(ctx, query, userID).Scan(
		&subscription.ID,
		&subscription.UserID,
		&subscription.PlanType,
		&subscription.Status,
		&subscription.StartDate,
		&endDate,
		&subscription.CreatedAt,
		&subscription.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("subscription not found")
	}
	if err != nil {
		return nil, fmt.Errorf("failed to find subscription: %w", err)
	}

	if endDate.Valid {
		subscription.EndDate = &endDate.Time
	}

	return subscription, nil
}

// Update は既存のサブスクリプションを更新します
func (r *SubscriptionRepository) Update(ctx context.Context, subscription *entity.Subscription) error {
	query := `
		UPDATE subscriptions
		SET plan_type = $1, status = $2, start_date = $3, end_date = $4, updated_at = $5
		WHERE id = $6
	`

	result, err := r.db.ExecContext(ctx, query,
		subscription.PlanType,
		subscription.Status,
		subscription.StartDate,
		subscription.EndDate,
		subscription.UpdatedAt,
		subscription.ID,
	)
	if err != nil {
		return fmt.Errorf("failed to update subscription: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}
	if rowsAffected == 0 {
		return fmt.Errorf("subscription not found")
	}

	return nil
}

// Delete は指定されたIDのサブスクリプションを削除します
func (r *SubscriptionRepository) Delete(ctx context.Context, id uuid.UUID) error {
	query := `DELETE FROM subscriptions WHERE id = $1`

	result, err := r.db.ExecContext(ctx, query, id)
	if err != nil {
		return fmt.Errorf("failed to delete subscription: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}
	if rowsAffected == 0 {
		return fmt.Errorf("subscription not found")
	}

	return nil
}

// FindActiveByUserID は指定されたユーザーIDのアクティブなサブスクリプションを取得します
func (r *SubscriptionRepository) FindActiveByUserID(ctx context.Context, userID uuid.UUID) (*entity.Subscription, error) {
	query := `
		SELECT id, user_id, plan_type, status, start_date, end_date, created_at, updated_at
		FROM subscriptions
		WHERE user_id = $1
		AND status = $2
		AND (end_date IS NULL OR end_date > $3)
		ORDER BY created_at DESC
		LIMIT 1
	`

	subscription := &entity.Subscription{}
	var endDate sql.NullTime
	err := r.db.QueryRowContext(ctx, query, userID, entity.SubscriptionStatusActive, time.Now()).Scan(
		&subscription.ID,
		&subscription.UserID,
		&subscription.PlanType,
		&subscription.Status,
		&subscription.StartDate,
		&endDate,
		&subscription.CreatedAt,
		&subscription.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("active subscription not found")
	}
	if err != nil {
		return nil, fmt.Errorf("failed to find active subscription: %w", err)
	}

	if endDate.Valid {
		subscription.EndDate = &endDate.Time
	}

	return subscription, nil
}

// UpdateStatus はサブスクリプションのステータスを更新します
func (r *SubscriptionRepository) UpdateStatus(ctx context.Context, id uuid.UUID, status entity.SubscriptionStatus) error {
	query := `
		UPDATE subscriptions
		SET status = $1, updated_at = $2
		WHERE id = $3
	`

	result, err := r.db.ExecContext(ctx, query, status, time.Now(), id)
	if err != nil {
		return fmt.Errorf("failed to update subscription status: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}
	if rowsAffected == 0 {
		return fmt.Errorf("subscription not found")
	}

	return nil
}

// ListExpired は期限切れのサブスクリプション一覧を取得します
func (r *SubscriptionRepository) ListExpired(ctx context.Context) ([]*entity.Subscription, error) {
	query := `
		SELECT id, user_id, plan_type, status, start_date, end_date, created_at, updated_at
		FROM subscriptions
		WHERE status = $1
		AND end_date IS NOT NULL
		AND end_date <= $2
	`

	rows, err := r.db.QueryContext(ctx, query, entity.SubscriptionStatusActive, time.Now())
	if err != nil {
		return nil, fmt.Errorf("failed to list expired subscriptions: %w", err)
	}
	defer rows.Close()

	var subscriptions []*entity.Subscription
	for rows.Next() {
		subscription := &entity.Subscription{}
		var endDate sql.NullTime
		err := rows.Scan(
			&subscription.ID,
			&subscription.UserID,
			&subscription.PlanType,
			&subscription.Status,
			&subscription.StartDate,
			&endDate,
			&subscription.CreatedAt,
			&subscription.UpdatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan subscription: %w", err)
		}

		if endDate.Valid {
			subscription.EndDate = &endDate.Time
		}

		subscriptions = append(subscriptions, subscription)
	}

	if err = rows.Err(); err != nil {
		return nil, fmt.Errorf("error iterating subscriptions: %w", err)
	}

	return subscriptions, nil
}
