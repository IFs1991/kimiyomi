package usecase

import (
	"context"
	"errors"

	"kimiyomi/backend/src/domain/entity"
	"kimiyomi/backend/src/domain/repository"

	"golang.org/x/crypto/bcrypt"
)

var (
	ErrInvalidCredentials = errors.New("invalid credentials")
	ErrUserAlreadyExists  = errors.New("user already exists")
)

// AuthUseCase は認証関連のユースケースを提供するインターフェースです
type AuthUseCase interface {
	// Authenticate はユーザーの認証を行います
	Authenticate(ctx context.Context, email, password string) (*entity.User, error)

	// Register は新規ユーザーを登録します
	Register(ctx context.Context, email, password, name string) (*entity.User, error)
}

// authUseCase は認証関連のユースケースの実装です
type authUseCase struct {
	userRepo repository.UserRepository
}

// NewAuthUseCase は新しいAuthUseCaseを作成します
func NewAuthUseCase(userRepo repository.UserRepository) AuthUseCase {
	return &authUseCase{
		userRepo: userRepo,
	}
}

// Authenticate はユーザーの認証を行います
func (uc *authUseCase) Authenticate(ctx context.Context, email, password string) (*entity.User, error) {
	user, err := uc.userRepo.FindByEmail(ctx, email)
	if err != nil {
		return nil, ErrInvalidCredentials
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(password)); err != nil {
		return nil, ErrInvalidCredentials
	}

	return user, nil
}

// Register は新規ユーザーを登録します
func (uc *authUseCase) Register(ctx context.Context, email, password, name string) (*entity.User, error) {
	// メールアドレスの重複チェック
	existingUser, err := uc.userRepo.FindByEmail(ctx, email)
	if err == nil && existingUser != nil {
		return nil, ErrUserAlreadyExists
	}

	// パスワードのハッシュ化
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	// 新規ユーザーの作成
	user := &entity.User{
		Email:    email,
		Password: string(hashedPassword),
		Name:     name,
		Role:     "user", // デフォルトロール
	}

	// ユーザーの保存
	if err := uc.userRepo.Create(ctx, user); err != nil {
		return nil, err
	}

	return user, nil
}
