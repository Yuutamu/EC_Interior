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
end
