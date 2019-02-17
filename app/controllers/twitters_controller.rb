class TwittersController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_user

  def new
    @twitter = Twitter.new
  end

  def create
    @twitter = Twitter.new(twitter_params)
    @twitter.user_id = current_user.id
    if @twitter.save
      redirect_back fallback_location: user_path(@user)
    else
      redirect_back fallback_location: user_path(@user)
    end
  end

  def edit
    @twitter = Twitter.find(params[:id])
  end

  def update
    @twitter = Twitter.find(params[:id])
    if @twitter.update(twitter_params)
      redirect_back fallback_location: user_path(@user)
    else
      redirect_back fallback_location: user_path(@user)
    end
  end

  def destroy
    @twitter = Twitter.find(params[:id])
    @twitter.destroy
    redirect_back fallback_location: user_path(@user)
  end


  private

  def set_user
    @user = User.find_by_friendly_id!(params[:user_id])
  end

  def twitter_params
    params.require(:twitter).permit(:content, :status)
  end

end
