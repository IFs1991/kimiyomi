-- コンテンツテーブルの作成
CREATE TABLE contents (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    content_type VARCHAR(50) NOT NULL,
    file_path VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 診断コンテンツ紐付けテーブルの作成
CREATE TABLE diagnosis_contents (
    id UUID PRIMARY KEY,
    diagnosis_id UUID NOT NULL,
    content_id UUID NOT NULL,
    created_at TIMESTAMP NOT NULL,
    FOREIGN KEY (diagnosis_id) REFERENCES diagnoses(id),
    FOREIGN KEY (content_id) REFERENCES contents(id)
);

-- サブスクリプションテーブルの作成
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    plan_type VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- インデックスの作成
CREATE INDEX idx_contents_user_id ON contents(user_id);
CREATE INDEX idx_diagnosis_contents_diagnosis_id ON diagnosis_contents(diagnosis_id);
CREATE INDEX idx_diagnosis_contents_content_id ON diagnosis_contents(content_id);
CREATE INDEX idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);

-- 制約の追加
ALTER TABLE contents ADD CONSTRAINT check_content_type CHECK (content_type IN ('image', 'video'));
ALTER TABLE contents ADD CONSTRAINT check_price CHECK (price >= 0);
ALTER TABLE subscriptions ADD CONSTRAINT check_plan_type CHECK (plan_type IN ('basic', 'premium'));
ALTER TABLE subscriptions ADD CONSTRAINT check_status CHECK (status IN ('active', 'inactive', 'expired'));