class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:edit, :update]
  before_action :set_user, only: [:show, :edit, :update, :fan, :un_fan]

  def show
    @user_twitter_new = Twitter.new
    @user_twitter_review_new = Review.new
    @attentions = @user.attentions.order("created_at DESC")
    @fans = @user.fans.order("created_at DESC")
    @notes = @user.notes.order("updated_at DESC")
    @twitters = @user.twitters.order("created_at DESC").page(params[:page]).per(5)

    # 交易记录
    @trades = @user.trades.order("created_at DESC")
    @user_trade_new = Trade.new
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to user_path(@user)
    else
      redirect_back fallback_location: user_path(@user)
    end
  end

  # --- fan 和 attention 粉丝和关注 逻辑处理 start ---
  def fan
    # 我关注了这会员
    Attention.create!(
      :user_id => current_user.id,
      :my_attention => @user.id
    )
    # 我成了这个会员的粉丝
    Fan.create!(
      :user_id => @user.id,
      :my_fans => current_user.id
    )
    redirect_back fallback_location: user_path(@user)
  end

  def un_fan
    # 我取消关注了这会员
    Attention.where(
      :user_id => current_user.id,
      :my_attention => @user.id
    ).first.destroy
    # 我不再这个会员的粉丝
    Fan.where(
      :user_id => @user.id,
      :my_fans => current_user.id
    ).first.destroy
    redirect_back fallback_location: user_path(@user)
  end
  # --- fan 和 attention 粉丝和关注 逻辑处理 end ---


  private

  def set_user
    @user = User.find_by_username!(params[:id])
  end

  def user_params
    params.require(:user).permit(:avatar, :username, :motto)
  end

end
