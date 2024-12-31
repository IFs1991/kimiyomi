package entity

import "errors"

var (
	// ErrInvalidID は無効なIDが指定された場合のエラーです
	ErrInvalidID = errors.New("invalid id")

	// ErrInvalidUserID は無効なユーザーIDが指定された場合のエラーです
	ErrInvalidUserID = errors.New("invalid user id")

	// ErrEmptyTitle はタイトルが空の場合のエラーです
	ErrEmptyTitle = errors.New("title cannot be empty")

	// ErrInvalidContentType は無効なコンテンツタイプが指定された場合のエラーです
	ErrInvalidContentType = errors.New("invalid content type")

	// ErrInvalidPrice は無効な価格が指定された場合のエラーです
	ErrInvalidPrice = errors.New("invalid price")

	// ErrInvalidPlanType は無効なプランタイプが指定された場合のエラーです
	ErrInvalidPlanType = errors.New("invalid plan type")

	// ErrInvalidStatus は無効なステータスが指定された場合のエラーです
	ErrInvalidStatus = errors.New("invalid status")

	// ErrInvalidStartDate は無効な開始日が指定された場合のエラーです
	ErrInvalidStartDate = errors.New("invalid start date")

	// ErrInvalidEndDate は無効な終了日が指定された場合のエラーです
	ErrInvalidEndDate = errors.New("invalid end date")
)
