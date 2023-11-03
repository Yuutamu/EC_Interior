class Customer::WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = Rails.application.credentials.dig(:stripe, :endpoint_secret) # endpoint_secret を Credentials から取得
    event = nil

    # 例外処理（400エラーを返す
    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      # Invalid payload （jsonを parseできなかったとき）
      p e
      status 400
      return
    rescue Stripe::SignatureVerificationError => e
      # Invalid signature （Stripeの署名が無効のとき）
      p e
      status 400
      return
    end

    case event.type
    when 'checkout.session.completed'
      session = event.data.object # sessionの取得
      customer = Customer.find(session.client_reference_id)
      return unless customer # 顧客が存在するかどうか確認

      # トランザクション処理開始
      ApplicationRecord.transaction do
        order = create_order(session) # sessionを元にordersテーブルにデータを挿入
        # line_itemsオブジェクト取得
        session_with_expand = Stripe::Checkout::Session.retrieve({ id: session.id, expand: ['line_items'] })
        session_with_expand.line_items.data.each do |line_item|
          create_order_details(order, line_item) # 取り出したline_itemをorder_detailsテーブルに登録
        end
      end
      # トランザクション処理終了
      customer.cart_items.destroy_all # customer のカート内の商品をすべて削除
      # Action Mailer メールを 非同期 で送信
      OrderMailer.complete(email: session.customer_details.email).deliver_later
      redirect_to session.success_url
    end
  end

  private

  # create! としているのは、レコードの保存に失敗した場合に例外を発生させる必要があるから(トランザクション)
  # 引数として受け取った sessionを元に各カラムに格納(sessionオブジェクト：https://stripe.com/docs/api/checkout/sessions/create#:~:text=%3A%20null%0A%7D-,Create%20a%20Session,-Creates%20a%20Session)
  # 開発メモ：shipping→shipping_detailsに変更
  def create_order(session)
    Order.create!({
                    customer_id: session.client_reference_id,
                    name: session.shipping_details.name,
                    postal_code: session.shipping_details.address.postal_code,
                    prefecture: session.shipping_details.address.state,
                    address1: session.shipping_details.address.line1,
                    address2: session.shipping_details.address.line2,
                    postage: session.shipping_options[0].shipping_amount,
                    billing_amount: session.amount_total,
                    status: 'confirm_payment'
                  })
  end

  # order_details の作成
  def create_order_details(order, line_item)
    product = Stripe::Product.retrieve(line_item.price.product) # Stripe に登録された商品を取得
    purchased_product = Product.find(product.metadata.product_id)
    raise ActiveRecord::RecordNotFound if purchased_product.nil?

    # order に紐づいた order_details の作成(order_id カラムに order の id を格納)
    order_detail = order.order_details.create!({
                                                 product_id: purchased_product.id,
                                                 price: line_item.price.unit_amount,
                                                 quantity: line_item.quantity
                                               })
    # 購入された商品の在庫数の更新
    purchased_product.update!(stock: (purchased_product.stock - order_detail.quantity))
  end
end
