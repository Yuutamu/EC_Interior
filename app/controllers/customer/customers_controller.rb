class Customer::CustomersController < ApplicationController
  before_action :authenticate_customer!

  def confirm_withdraw; end

  def withdraw
    current_customer.update(status: 'withdrawn')
    # セッション情報を削除した後に、ログアウトさせる
    reset_session
    redirect_to root_path, notice: 'Successfully withdraw from InteriorEC'
  end
end
