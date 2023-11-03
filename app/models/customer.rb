class Customer < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  with_options presence: true do
    validates :name
    validates :status
  end
  enum status: {
    normal: 0, # 通常
    withdrawn: 1, # 退会済み
    banned: 2 # 停止
  }
  has_many :cart_items, dependent: :destroy
  has_many :orders, dependent: :destroy

  # StripeのCheckoutセッションを作成する際にカート内商品の情報を配列で返すメソッドが必要 （参考：https://stripe.com/docs/payments/checkout/migrating-prices#server-side-code-for-inline-items）
  def line_items_checkout
    cart_items.map do |cart_item|
      {
        quantity: cart_item.quantity,
        price_data: {
          currency: 'jpy',
          unit_amount: cart_item.product.price,
          product_data: {
            name: cart_item.product.name,
            metadata: {
              product_id: cart_item.product_id
            }
          }
        }
      }
    end
  end

  # 退会済みアカウントのログインを拒否 (deviceで扱っているモデルのactive_for_authentication? を上書きする)
  # https://rubydoc.info/github/plataformatec/devise/Devise/Models/Authenticatable
  def active_for_authentication?
    super && (status == 'normal')
  end
end
