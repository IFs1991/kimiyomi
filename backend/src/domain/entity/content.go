package entity

import (
	"time"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
)

// ContentType はコンテンツの種類を表す型です
type ContentType string

const (
	ContentTypeImage ContentType = "image"
	ContentTypeVideo ContentType = "video"
)

// Content はデジタルコンテンツを表すエンティティです
type Content struct {
	ID          uuid.UUID       `json:"id"`
	UserID      uuid.UUID       `json:"user_id"`
	Title       string          `json:"title"`
	Description string          `json:"description"`
	ContentType ContentType     `json:"content_type"`
	FilePath    string          `json:"file_path"`
	Price       decimal.Decimal `json:"price"`
	CreatedAt   time.Time       `json:"created_at"`
	UpdatedAt   time.Time       `json:"updated_at"`
}

// NewContent は新しいContentエンティティを作成します
func NewContent(
	userID uuid.UUID,
	title string,
	description string,
	contentType ContentType,
	filePath string,
	price decimal.Decimal,
) (*Content, error) {
	if userID == uuid.Nil {
		return nil, ErrInvalidUserID
	}
	if title == "" {
		return nil, ErrEmptyTitle
	}
	if !isValidContentType(contentType) {
		return nil, ErrInvalidContentType
	}
	if price.LessThan(decimal.Zero) {
		return nil, ErrInvalidPrice
	}

	now := time.Now()
	return &Content{
		ID:          uuid.New(),
		UserID:      userID,
		Title:       title,
		Description: description,
		ContentType: contentType,
		FilePath:    filePath,
		Price:       price,
		CreatedAt:   now,
		UpdatedAt:   now,
	}, nil
}

// isValidContentType はContentTypeが有効かどうかを確認します
func isValidContentType(ct ContentType) bool {
	switch ct {
	case ContentTypeImage, ContentTypeVideo:
		return true
	default:
		return false
	}
}

// UpdateContent はコンテンツの情報を更新します
func (c *Content) UpdateContent(
	title string,
	description string,
	price decimal.Decimal,
) error {
	if title == "" {
		return ErrEmptyTitle
	}
	if price.LessThan(decimal.Zero) {
		return ErrInvalidPrice
	}

	c.Title = title
	c.Description = description
	c.Price = price
	c.UpdatedAt = time.Now()
	return nil
}

// Validate はコンテンツの妥当性を検証します
func (c *Content) Validate() error {
	if c.ID == uuid.Nil {
		return ErrInvalidID
	}
	if c.UserID == uuid.Nil {
		return ErrInvalidUserID
	}
	if c.Title == "" {
		return ErrEmptyTitle
	}
	if !isValidContentType(c.ContentType) {
		return ErrInvalidContentType
	}
	if c.Price.LessThan(decimal.Zero) {
		return ErrInvalidPrice
	}
	return nil
}
