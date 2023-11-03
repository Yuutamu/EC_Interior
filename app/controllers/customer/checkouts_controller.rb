# Stripe Checkout特有の記述があるのでドキュメント参考（https://stripe.com/docs/payments/checkout/how-checkout-works?locale=ja-JP&payment-ui=stripe-hosted-page）
class Customer::CheckoutsController < ApplicationController
  before_action :authenticate_customer!

  def create
    line_items = current_customer.line_items_checkout
    # CheckoutSessionの作成
    session = create_session(line_items)
    # 顧客を Stripe がオンラインで提供する決済ページにリダイレクトさせる
    redirect_to session.url, allow_other_host: true # 現在のホストと異なるホストへのリダイレクトを許可
  end

  private

  # Stripe 各オブジェクト（参考：https://stripe.com/docs/api/checkout/sessions/object）
  def create_session(line_items)
    Stripe::Checkout::Session.create(
      client_reference_id: current_customer.id, # チェックアウトセッションを参照するための一意の文字列
      customer_email: current_customer.email,
      mode: 'payment', # チェックアウトセッションのモード
      payment_method_types: ['card'], # 支払い方法
      line_items:, # line_items_checkout で作成したもの
      shipping_address_collection: {
        allowed_countries: ['JP']
      },
      shipping_options: [
        {
          shipping_rate_data: {
            type: 'fixed_amount',
            fixed_amount: {
              amount: 3000,
              currency: 'jpy'
            }, # 配送オプションの配送料作成に渡されるパラメータ
            display_name: '全国一律'
          }
        }
      ],
      success_url: root_url,
      cancel_url: "#{root_url}cart_items"
    )
  end
end
