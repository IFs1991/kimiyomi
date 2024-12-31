package payment

import (
	"context"
	"encoding/json"
	"fmt"

	"kimiyomi/backend/src/domain/entity"

	"github.com/google/uuid"
	"github.com/stripe/stripe-go/v76"
	"github.com/stripe/stripe-go/v76/customer"
	"github.com/stripe/stripe-go/v76/subscription"
)

// StripeService はStripeを使用した決済サービスの実装です
type StripeService struct {
	apiKey string
}

// NewStripeService は新しいStripeServiceを作成します
func NewStripeService(apiKey string) *StripeService {
	stripe.Key = apiKey
	return &StripeService{
		apiKey: apiKey,
	}
}

// planIDMap はプランタイプとStripeのプランIDのマッピング
var planIDMap = map[entity.PlanType]string{
	entity.PlanTypeBasic:   "price_basic_monthly",
	entity.PlanTypePremium: "price_premium_monthly",
}

// CreateSubscription は新しいサブスクリプションの決済を作成します
func (s *StripeService) CreateSubscription(ctx context.Context, userID uuid.UUID, planType entity.PlanType) error {
	// プランIDを取得
	planID, ok := planIDMap[planType]
	if !ok {
		return fmt.Errorf("invalid plan type")
	}

	// 顧客を作成または取得
	customerID, err := s.getOrCreateCustomer(ctx, userID)
	if err != nil {
		return fmt.Errorf("failed to get or create customer: %w", err)
	}

	// サブスクリプションを作成
	params := &stripe.SubscriptionParams{
		Customer: stripe.String(customerID),
		Items: []*stripe.SubscriptionItemsParams{
			{
				Price: stripe.String(planID),
			},
		},
	}

	_, err = subscription.New(params)
	if err != nil {
		return fmt.Errorf("failed to create subscription: %w", err)
	}

	return nil
}

// CancelSubscription はサブスクリプションの決済をキャンセルします
func (s *StripeService) CancelSubscription(ctx context.Context, subscriptionID uuid.UUID) error {
	// Stripeのサブスクリプションを取得
	stripeSubID, err := s.getStripeSubscriptionID(subscriptionID)
	if err != nil {
		return fmt.Errorf("failed to get stripe subscription ID: %w", err)
	}

	// サブスクリプションをキャンセル
	params := &stripe.SubscriptionParams{
		CancelAtPeriodEnd: stripe.Bool(true),
	}
	_, err = subscription.Update(stripeSubID, params)
	if err != nil {
		return fmt.Errorf("failed to cancel subscription: %w", err)
	}

	return nil
}

// getOrCreateCustomer は顧客を取得または作成します
func (s *StripeService) getOrCreateCustomer(ctx context.Context, userID uuid.UUID) (string, error) {
	// 既存の顧客を検索
	params := &stripe.CustomerListParams{
		Filters: stripe.Filters{
			stripe.Filter{
				Key:   "metadata['user_id']",
				Value: userID.String(),
			},
		},
	}

	customers := customer.List(params)
	for customers.Next() {
		return customers.Customer().ID, nil
	}

	// 新しい顧客を作成
	customerParams := &stripe.CustomerParams{
		Metadata: map[string]string{
			"user_id": userID.String(),
		},
	}

	newCustomer, err := customer.New(customerParams)
	if err != nil {
		return "", fmt.Errorf("failed to create customer: %w", err)
	}

	return newCustomer.ID, nil
}

// getStripeSubscriptionID はStripeのサブスクリプションIDを取得します
func (s *StripeService) getStripeSubscriptionID(subscriptionID uuid.UUID) (string, error) {
	// Note: この実装は簡略化されています
	// 実際の実装では、データベースなどでサブスクリプションIDとStripeのサブスクリプションIDの
	// マッピングを管理する必要があります
	return fmt.Sprintf("sub_%s", subscriptionID.String()), nil
}

// HandleWebhook はStripeのWebhookを処理します
func (s *StripeService) HandleWebhook(payload []byte, signature string) error {
	// Webhookイベントを検証
	event, err := stripe.ConstructEvent(payload, signature, s.apiKey)
	if err != nil {
		return fmt.Errorf("failed to verify webhook signature: %w", err)
	}

	// イベントタイプに応じて処理
	switch event.Type {
	case "customer.subscription.deleted":
		// サブスクリプションが削除された場合の処理
		var sub stripe.Subscription
		err := json.Unmarshal(event.Data.Raw, &sub)
		if err != nil {
			return fmt.Errorf("failed to unmarshal subscription: %w", err)
		}
		// サブスクリプションの状態を更新する処理を実装

	case "customer.subscription.updated":
		// サブスクリプションが更新された場合の処理
		var sub stripe.Subscription
		err := json.Unmarshal(event.Data.Raw, &sub)
		if err != nil {
			return fmt.Errorf("failed to unmarshal subscription: %w", err)
		}
		// サブスクリプションの状態を更新する処理を実装

		// 他のイベントタイプに応じた処理を追加
	}

	return nil
}
