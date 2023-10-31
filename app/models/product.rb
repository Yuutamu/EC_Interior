class Product < ApplicationRecord
  with_options presence: true do
    validates :name
    validates :description
    validates :price
    validates :stock
    validates :image # ActiveStrage
  end
  # ActiveStorageを紐付けることで、Productテーブルから image カラムを呼び出せるようにする
  has_one_attached :image
  # @sort price_high_to_low, price_low_to_high
  scope :price_high_to_low, -> { order(price: :desc) }
  scope :price_low_to_high, -> { order(price: :asc) }
  has_many :cart_items, dependent: :destroy
  has_many :order_details, dependent: :destroy
end
