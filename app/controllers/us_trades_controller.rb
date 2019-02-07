class UsTradesController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_user

  def new
    @us_trade = UsTrade.new
  end

  def create
    @us_trade = UsTrade.new(us_trade_params)
    @us_trade.user_id = current_user.id
    if @us_trade.save
      redirect_back fallback_location: user_path(@user)
    else
      redirect_back fallback_location: user_path(@user)
   end
  end

  def edit
    @us_trade = UsTrade.find(params[:id])
  end

  def update
    @us_trade = UsTrade.find(params[:id])
    if @us_trade.update(us_trade_params)
      redirect_back fallback_location: user_path(@user)
    else
      redirect_back fallback_location: user_path(@user)
    end
  end

  def destroy
    @us_trade = UsTrade.find(params[:id])
    @us_trade.destroy
    redirect_back fallback_location: user_path(@user)
  end


  private

  def set_user
    @user = User.find_by_friendly_id!(params[:user_id])
  end

  def us_trade_params
    params.require(:us_trade).permit(:user_id, :stock, :buy_price, :sell_price, :buy_time, :sell_time, :description, :status)
  end
end
