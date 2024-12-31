package entity

import (
	"time"
)

// User はユーザー情報を表すエンティティです
type User struct {
	ID        string    `json:"id"`
	Email     string    `json:"email"`
	Password  string    `json:"-"` // パスワードはJSONにシリアライズしない
	Name      string    `json:"name"`
	Role      string    `json:"role"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// NewUser は新しいUserエンティティを作成します
func NewUser(email, password, name string) *User {
	now := time.Now()
	return &User{
		Email:     email,
		Password:  password,
		Name:      name,
		Role:      "user",
		CreatedAt: now,
		UpdatedAt: now,
	}
}

// UpdatePassword はユーザーのパスワードを更新します
func (u *User) UpdatePassword(password string) {
	u.Password = password
	u.UpdatedAt = time.Now()
}

// UpdateName はユーザーの名前を更新します
func (u *User) UpdateName(name string) {
	u.Name = name
	u.UpdatedAt = time.Now()
}

// UpdateRole はユーザーのロールを更新します
func (u *User) UpdateRole(role string) {
	u.Role = role
	u.UpdatedAt = time.Now()
}
