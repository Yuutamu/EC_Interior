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
      return [Order.latest,
              'all']
    end

    get_by_enum_value(params[:status])
  end

  # case when　の使い方が特殊？？　第２引数を日本語にしてもウドいている。。？
  def get_by_enum_value(status)
    case status
    when 'waiting_payment'
      [Order.latest.waiting_payment, 'waiting_payment'] # 入金待ち
    when 'confirm_payment'
      [Order.latest.confirm_payment, 'confirm_payment'] # 入金確認
    when 'shipped'
      [Order.latest.shipped, 'shipped'] # 出荷済み
    when 'out_for_delivery'
      [Order.latest.out_for_delivery, 'out_for_delivery'] # 配送中
    when 'delivered'
      [Order.latest.delivered, 'delivered'] # 配送済み
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
