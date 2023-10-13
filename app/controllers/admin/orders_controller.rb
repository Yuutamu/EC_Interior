class Admin::OrdersController < ApplicationController
  def show; end

  def update
    @order.update(order_params)
    redirect_to admin_order_path(@order), notice: 'Successfully updated order status'
  end

  private

  def set_order
    @prder = Order.fond(params[:id])
  end

  def order_params
    params.require(:order).permit(:status)
  end
end
