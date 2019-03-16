class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:edit, :update]
  before_action :set_user, only: [:show, :edit, :update, :fan, :un_fan]
  impressionist actions: [:show]

  def show
    @user_twitter_new = Twitter.new
    @user_twitter_review_new = Review.new
    @attentions = @user.attentions.order("created_at DESC")
    @fans = @user.fans.order("created_at DESC")

    # twitters 记录
    @twitters = @user.twitters.order("created_at DESC").page(params[:twitters]).per(5)

    # notes 记录
    @notes = @user.notes.order("updated_at DESC").page(params[:notes]).per(10)

    # us_notes 记录
    @us_notes = @user.us_notes.order("updated_at DESC").page(params[:us_notes]).per(10)

    # A股交易记录
    @trades = @user.trades.order("created_at DESC")
    @user_trade_new = Trade.new

    # 美股交易记录
    @us_trades = @user.us_trades.order("created_at DESC")
    @user_us_trade_new = UsTrade.new

    #浏览量极速器
    impressionist(@user)

    # 笔记目录 等等入场 A
    @unl_1 = @user.level_uniq("等待入场")[0..9]

    # 笔记目录 等等入场 U
    @unl_2 = @user.us_level_uniq("等待入场")[0..9]

    @size_12 = @user.level_uniq("等待入场").size + @user.us_level_uniq("等待入场").size

    # 笔记目录 近期关注 A
    @unl_3 = @user.level_uniq("近期关注")[0..9]

    # 笔记目录 近期关注 U
    @unl_4 = @user.us_level_uniq("近期关注")[0..9]

    @size_34 = @user.level_uniq("近期关注").size + @user.us_level_uniq("近期关注").size

    # 笔记目录 长期关注 A
    @unl_5 = @user.level_uniq("长期关注")[0..9]

    # 笔记目录 长期关注 U
    @unl_6 = @user.us_level_uniq("长期关注")[0..9]

    @size_56 = @user.level_uniq("长期关注").size + @user.us_level_uniq("长期关注").size

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
    @user = User.find_by_friendly_id!(params[:id])
  end

  def user_params
    params.require(:user).permit(:avatar, :username, :motto)
  end

end
