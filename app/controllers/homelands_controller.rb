class HomelandsController < ApplicationController

  before_action :authenticate_user!, only:[:new, :create, :edit, :update, :destroy]

  def show
    @homelands = Homeland.all
  end

  def new
    @homeland = Homeland.new
  end

  def create
    @homeland = Homeland.new(homeland_params)
    @homeland.user_id = current_user.id

    if @homeland.save
      redirect_back fallback_location: homelands_path
    else
      redirect_back fallback_location: homelands_path
    end
  end

  def edit
    @homeland = Homeland.find(params[:id])
  end

  def update
    @homeland = Homeland.find(params[:id])

    if @homeland.update(homeland_params)
      redirect_back fallback_location: homeland_path(@homeland)
    else
      redirect_back fallback_location: homeland_path(@homeland)
    end
  end

  def destroy
    @homeland = Homeland.find(params[:id])

    @homeland.destroy
    redirect_back fallback_location: homelands_path
  end

  private

  def homeland_params
    params.require(:homeland).permit(:user_id, :categories, :title, :description)
  end

end
