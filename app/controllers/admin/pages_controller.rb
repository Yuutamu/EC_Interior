class Admin::PagesController < ApplicationController
  before_action :authenticate_admin!

  def home
    @orders, @selected = get_orders(params)
    today_orders = Order.created_today
    @today_total_orders = total_orders(today_orders)
    @today_total_sales = total_sales(today_orders)
  end

  private

  def get_orders(params)
    if !params[:status].present? || !Order.statuses.keys.to_a.include?(params[:status])
      return [Order.eager_load(:customer).latest, 'all'] # Orders.status の値がnull or 所定のstatus 以外の場合は、 latest 順に取得
    end

    get_by_enum_value(params[:status])
  end

  def get_by_enum_value(status)
    # 1+N problem(eager_load method)
    case status
    when 'waiting_payment'
      [Order.waiting_payment.eager_load(:customer).latest, 'waiting_payment'] # 入金待ち
    when 'confirm_payment'
      [Order.confirm_payment.eager_load(:customer).latest, 'confirm_payment'] # 入金確認
    when 'shipped'
      [Order.shipped.eager_load(:customer).latest, 'shipped'] # 出荷済み
    when 'out_for_delivery'
      [Order.out_for_delivery.eager_load(:customer).latest, 'out_for_delivery'] # 配送中
    when 'delivered'
      [Order.delivered.eager_load(:customer).latest, 'delivered'] # 配送済み
    end
  end

  def total_orders(orders)
    orders.count
  end

  def total_sales(orders)
    # Stripeオブジェクト
    orders.sum(:billing_amount)
  end
end
