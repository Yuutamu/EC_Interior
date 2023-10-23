class Customer::SessionsController < Devise::SessionsController
  before_action :reject_invalid_customer, only: [:create]

  protected

  def reject_invalid_customer
    customer = Customer.find_by(email: params[:customer][:email])
    # 早期リターン(emial照合)
    return unless customer
    # リターン（パスワード、status照合）
    return if customer.valid_password?(params[:customer][:password]) && customer.active_for_authentication?

    alert_message = if customer.status == 'withdrawn'
                      'You have already resigned'
                    else
                      'Your account is suspended'
                    end
    redirect_to request.referer, alert: alert_message
  end
end
