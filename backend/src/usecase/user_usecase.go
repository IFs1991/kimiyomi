package usecase

import (
	"context"
	"errors"

	"kimiyomi/backend/src/domain/entity"
	"kimiyomi/backend/src/domain/repository"
)

var (
	ErrUserNotFound     = errors.New("ユーザーが見つかりません")
	ErrInvalidEmail     = errors.New("無効なメールアドレスです")
	ErrDuplicateEmail   = errors.New("このメールアドレスは既に使用されています")
	ErrInvalidUserInput = errors.New("無効なユーザー入力です")
)

// UserUseCase はユーザー関連のビジネスロジックを扱います
type UserUseCase struct {
	userRepo repository.UserRepository
}

// NewUserUseCase は新しいUserUseCaseインスタンスを作成します
func NewUserUseCase(userRepo repository.UserRepository) *UserUseCase {
	return &UserUseCase{
		userRepo: userRepo,
	}
}

// CreateUser は新しいユーザーを作成します
func (uc *UserUseCase) CreateUser(ctx context.Context, email, password, name string) (*entity.User, error) {
	// 入力値の検証
	if email == "" || password == "" || name == "" {
		return nil, ErrInvalidUserInput
	}

	// メールアドレスの重複チェック
	existing, err := uc.userRepo.FindByEmail(ctx, email)
	if err == nil && existing != nil {
		return nil, ErrDuplicateEmail
	}

	// ユーザーの作成
	user := entity.NewUser(email, password, name)

	if err := uc.userRepo.Create(ctx, user); err != nil {
		return nil, err
	}

	return user, nil
}

// GetUserByID はIDによってユーザーを取得します
func (uc *UserUseCase) GetUserByID(ctx context.Context, id string) (*entity.User, error) {
	if id == "" {
		return nil, ErrInvalidUserInput
	}

	user, err := uc.userRepo.FindByID(ctx, id)
	if err != nil {
		return nil, ErrUserNotFound
	}

	return user, nil
}

// GetUserByEmail はメールアドレスによってユーザーを取得します
func (uc *UserUseCase) GetUserByEmail(ctx context.Context, email string) (*entity.User, error) {
	if email == "" {
		return nil, ErrInvalidUserInput
	}

	user, err := uc.userRepo.FindByEmail(ctx, email)
	if err != nil {
		return nil, ErrUserNotFound
	}

	return user, nil
}

// UpdateUser はユーザー情報を更新します
func (uc *UserUseCase) UpdateUser(ctx context.Context, id string, name string) error {
	if id == "" || name == "" {
		return ErrInvalidUserInput
	}

	user, err := uc.GetUserByID(ctx, id)
	if err != nil {
		return err
	}

	user.UpdateName(name)

	return uc.userRepo.Update(ctx, user)
}

// UpdatePassword はユーザーのパスワードを更新します
func (uc *UserUseCase) UpdatePassword(ctx context.Context, id string, password string) error {
	if id == "" || password == "" {
		return ErrInvalidUserInput
	}

	user, err := uc.GetUserByID(ctx, id)
	if err != nil {
		return err
	}

	user.UpdatePassword(password)

	return uc.userRepo.Update(ctx, user)
}

// DeleteUser はユーザーを削除します
func (uc *UserUseCase) DeleteUser(ctx context.Context, id string) error {
	if id == "" {
		return ErrInvalidUserInput
	}

	// ユーザーの存在確認
	_, err := uc.GetUserByID(ctx, id)
	if err != nil {
		return err
	}

	return uc.userRepo.Delete(ctx, id)
}
