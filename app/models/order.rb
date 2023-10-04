class Order < ApplicationRecord
  belongs_to :customer
  enum status: {
    waiting_payment: 0,   # （入金待ち）
    confirm_payment: 1,   # （入金確認）
    shipped: 2,           # （出荷済み）
    out_for_delivery: 3,  # （配送中）
    delivered: 4,         # （配達済み）
  }
  has_many: order_details, dependent: :destroy
end
