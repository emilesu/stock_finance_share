class TradesController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_user

  def new
    @trade = Trader.new
  end

  def create
    @trade = Trade.new(trade_params)
    @trade.user_id = current_user.id
    if @trader.save
      redirect_back fallback_location: user_path(@user)
    else
      redirect_back fallback_location: user_path(@user)
   end
  end

  def edit
    @trade = Trade.find(params[:id])
  end

  def update
    @trade = Trade.find(params[:id])
    if @trade.update(trade_params)
      redirect_back fallback_location: user_path(@user)
    else
      redirect_back fallback_location: user_path(@user)
    end
  end

  def destroy
    @trade = Trade.find(params[:id])
    @trade.destroy
    redirect_back fallback_location: user_path(@user)
  end


  private

  def set_user
    @user = User.find_by_username!(params[:user_id])
  end

  def trade_params
    params.require(:trade).permit(:user_id, :stock, :buy_price, :sell_price, :buy_time, :sell_time, :description, :status)
  end
end
