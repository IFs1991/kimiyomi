-- 制約の削除
ALTER TABLE contents DROP CONSTRAINT IF EXISTS check_content_type;
ALTER TABLE contents DROP CONSTRAINT IF EXISTS check_price;
ALTER TABLE subscriptions DROP CONSTRAINT IF EXISTS check_plan_type;
ALTER TABLE subscriptions DROP CONSTRAINT IF EXISTS check_status;

-- インデックスの削除
DROP INDEX IF EXISTS idx_contents_user_id;
DROP INDEX IF EXISTS idx_diagnosis_contents_diagnosis_id;
DROP INDEX IF EXISTS idx_diagnosis_contents_content_id;
DROP INDEX IF EXISTS idx_subscriptions_user_id;
DROP INDEX IF EXISTS idx_subscriptions_status;

-- テーブルの削除
DROP TABLE IF EXISTS diagnosis_contents;
DROP TABLE IF EXISTS subscriptions;
DROP TABLE IF EXISTS contents;