class Order < ApplicationRecord
  belongs_to :customer
  enum status: {
    waiting_payment: 0,   # （入金待ち）
    confirm_payment: 1,   # （入金確認）
    shipped: 2,           # （出荷済み）
    out_for_delivery: 3,  # （配送中）
    delivered: 4         # （配達済み）
  }
  has_many :order_details, dependent: :destroy

  scope :waiting_payment, -> { where(status: 'waiting_payment') }
  scope :confirm_payment, -> { where(status: 'confirm_payment') }
  scope :shipped, -> { where(status: 'shipped') }
  scope :out_for_delivery, -> { where(status: 'out_for_delivery') }
  scope :delivered, -> { where(status: 'delivered') }
  scope :created_today, -> { where('orders.created_at >= ?', Time.zone.now.biginning_of_day) }
end
