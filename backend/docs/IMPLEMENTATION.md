# コンテンツ販売機能の実装計画

## 概要
相性診断サービスに写真・動画などのデジタルコンテンツを組み合わせて販売する機能を実装します。

## 販売プラン
1. 基本プラン
   - 相性診断のみの利用
   - 基本的な診断結果の表示

2. プレミアムプラン
   - 相性診断 + デジタルコンテンツ
   - 詳細な診断結果
   - 専用コンテンツの閲覧権限

## データベース設計

### Content テーブル
```sql
CREATE TABLE contents (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    content_type VARCHAR(50) NOT NULL, -- 'image', 'video' など
    file_path VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

### DiagnosisContent テーブル（診断とコンテンツの紐付け）
```sql
CREATE TABLE diagnosis_contents (
    id UUID PRIMARY KEY,
    diagnosis_id UUID NOT NULL,
    content_id UUID NOT NULL,
    created_at TIMESTAMP NOT NULL,
    FOREIGN KEY (diagnosis_id) REFERENCES diagnoses(id),
    FOREIGN KEY (content_id) REFERENCES contents(id)
);
```

### Subscription テーブル
```sql
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    plan_type VARCHAR(50) NOT NULL, -- 'basic', 'premium'
    status VARCHAR(50) NOT NULL,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

## ドメインモデル追加

### Content エンティティ
```go
type Content struct {
    ID          uuid.UUID
    UserID      uuid.UUID
    Title       string
    Description string
    ContentType string
    FilePath    string
    Price       decimal.Decimal
    CreatedAt   time.Time
    UpdatedAt   time.Time
}
```

### Subscription エンティティ
```go
type Subscription struct {
    ID        uuid.UUID
    UserID    uuid.UUID
    PlanType  string
    Status    string
    StartDate time.Time
    EndDate   *time.Time
    CreatedAt time.Time
    UpdatedAt time.Time
}
```

## API エンドポイント

### コンテンツ管理
- POST /api/v1/contents - コンテンツのアップロード
- GET /api/v1/contents - コンテンツ一覧取得
- GET /api/v1/contents/:id - コンテンツ詳細取得
- PUT /api/v1/contents/:id - コンテンツ更新
- DELETE /api/v1/contents/:id - コンテンツ削除

### 診断コンテンツ連携
- POST /api/v1/diagnoses/:id/contents - 診断へのコンテンツ紐付け
- GET /api/v1/diagnoses/:id/contents - 診断に紐付けられたコンテンツ取得
- DELETE /api/v1/diagnoses/:id/contents/:content_id - コンテンツの紐付け解除

### サブスクリプション
- POST /api/v1/subscriptions - サブスクリプション開始
- GET /api/v1/subscriptions/current - 現在のサブスクリプション情報取得
- PUT /api/v1/subscriptions/:id - サブスクリプション更新
- DELETE /api/v1/subscriptions/:id - サブスクリプション解約

## セキュリティ考慮事項
1. コンテンツアクセス制御
   - サブスクリプションステータスの確認
   - コンテンツ所有者の権限確認
   - 署名付きURLによるコンテンツ配信

2. 支払い処理
   - Stripeを使用した安全な決済処理
   - 支払い情報の暗号化
   - トランザクション管理

## 実装手順
1. データベーステーブルの作成
2. ドメインモデルの実装
3. リポジトリレイヤーの実装
4. ユースケースの実装
5. APIエンドポイントの実装
6. 認証・認可の実装
7. ファイルアップロード機能の実装
8. 決済連携の実装
9. テストの作成
10. デプロイメント設定の更新