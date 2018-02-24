class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:edit, :update]

  def show
    @user = User.find_by_username!(params[:id])
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

  private
  def user_params
    params.require(:user).permit(:avatar, :username, :motto)
  end

end
