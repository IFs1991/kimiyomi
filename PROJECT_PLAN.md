# キミヨミ - 推し活エンゲージメントプラットフォーム

## プロジェクト概要

推し活のエンゲージメントを可視化・販売するプラットフォーム。
エンゲージメントを購入することで、推しとユーザーの詳細な相性診断が行えます。

### コアバリュー
- 推し×ユーザーの相性診断
- エンゲージメントの数値化・可視化
- ファンコミュニティの形成

## 開発状況

### 現状（開発2日目）
- プロジェクト構造の設計
- 基本的なアーキテクチャの構築
- 通知システムの基盤
- 診断モデルの設計
- Firebase認証の準備

### 残りのタスクと想定期間

#### 1. 認証・プロフィール系 (2週間)
- [ ] Firebase認証の実装
- [ ] プロフィール管理
- [ ] ユーザー設定
- [ ] アカウント管理

#### 2. 診断システム (3-4週間)
- [ ] 性格診断ロジック
- [ ] 相性診断アルゴリズム
- [ ] 診断UI/UX
- [ ] 結果表示・共有機能

#### 3. 決済システム (3週間)
- [ ] Stripe連携
- [ ] サブスクリプション管理
- [ ] ポイント/チケットシステム
- [ ] 購入フロー

#### 4. コンテンツ管理 (2-3週間)
- [ ] コンテンツ表示
- [ ] メディア管理
- [ ] キャッシュ戦略
- [ ] オフライン対応

#### 5. コミュニティ機能 (2-3週間)
- [ ] 活動記録
- [ ] 共有機能
- [ ] インタラクション

#### 6. UI/UXの完成 (2-3週間)
- [ ] デザインシステムの実装
- [ ] アニメーション
- [ ] レスポンシブ対応
- [ ] アクセシビリティ

#### 7. テスト・デバッグ (2週間)
- [ ] ユニットテスト
- [ ] 統合テスト
- [ ] パフォーマンス最適化
- [ ] バグ修正

#### 8. リリース準備 (1週間)
- [ ] ストア申請準備
- [ ] ドキュメント作成
- [ ] 最終調整

## 想定される合計期間
- 最短: 3-4ヶ月
- 標準: 4-5ヶ月
- 余裕をもって: 6ヶ月

## 開発フェーズ

### Phase 1 (MVP)
- 基本的な認証
- シンプルな診断機能
- 最小限の決済機能

### Phase 2
- 詳細な診断機能
- コミュニティ機能
- 高度なコンテンツ管理

### Phase 3
- 追加機能
- UI/UX改善
- パフォーマンス最適化

## 主要機能

### 診断システム
- 性格診断：ユーザーと推しの性格タイプを分析
- 相性診断：エンゲージメントスコアに基づく詳細な相性分析
- 診断結果の共有機能：SNSでの拡散促進

### エンゲージメント管理
- エンゲージメントポイントの購入
- 相性診断チケットへの交換
- 特別なコンテンツのアンロック
- 推し活レベルの可視化

### コンテンツ配信
- 推しの情報や最新ニュース
- 限定フォト・ムービー
- バーチャルミート＆グリート
- 特別なメッセージや音声コンテンツ

### 決済システム
#### サブスクリプション
- ベーシックプラン（基本的な相性診断）
- プレミアムプラン（詳細な診断＋特典）
- VIPプラン（完全カスタマイズ診断＋限定コンテンツ）

#### 個別課金
- エンゲージメントポイント
- 特別診断チケット
- 限定コンテンツ

### その他の機能
- 多言語対応（グローバルファン対応）
- プッシュ通知システム
- オフラインモード
- データ分析・統計

## 技術スタック
- フロントエンド: Flutter/Dart
- バックエンド: Firebase
- データベース: Cloud Firestore
- 認証: Firebase Auth
- 決済: Stripe
- 通知: FCM + ローカル通知
- CI/CD: GitHub Actions

## 開発効率化策
1. コード生成ツールの活用
2. UIコンポーネントの再利用
3. 自動テストの導入
4. 並行開発の検討

## 注意点
- 段階的なリリース戦略の採用
- コアとなる診断・決済機能を優先
- UIの完成度は段階的に向上
- 付加機能は後回し

## 更新履歴
- 2024-01-XX: プロジェクト開始
- 2024-01-XX: プロジェクト構造の設計完了
- 2024-01-XX: 通知システムの基盤実装