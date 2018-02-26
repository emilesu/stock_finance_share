class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:edit, :update]

  def show
    @user = User.find_by_username!(params[:id])
    @user_twitter_new = Twitter.new
    @user_twitter_review_new = Review.new
  end

  def edit
    @user = User.find_by_username!(params[:id])
  end

  def update
    @user = User.find_by_username!(params[:id])
    if @user.update(user_params)
      redirect_to user_path(@user)
    else
      redirect_back fallback_location: user_path(@user)
    end
  end

  # --- fan 和 attention 粉丝和关注 逻辑处理 start ---
  def fan
    @user = User.find_by_username!(params[:id])
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
    @user = User.find_by_username!(params[:id])
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
  def user_params
    params.require(:user).permit(:avatar, :username, :motto)
  end

end
