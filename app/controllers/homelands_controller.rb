class HomelandsController < ApplicationController

  before_action :authenticate_user!, only:[:new, :create, :edit, :update, :destroy]
  impressionist actions: [:show, :index]

  def index
    @homelands = Homeland.where(:status => "公开")
  end

  def show
    @homeland = Homeland.find(params[:id])
    @homeland_post_new = HomelandPost.new
  end

  def new
    @homeland = Homeland.new
  end

  def create
    @homeland = Homeland.new(homeland_params)
    @homeland.user_id = current_user.id

    if @homeland.save
      redirect_to homelands_path
    else
      render :new
    end
  end

  def edit
    @homeland = Homeland.find(params[:id])
  end

  def update
    @homeland = Homeland.find(params[:id])

    if @homeland.update(homeland_params)
      redirect_to homeland_path(@homeland)
    else
      render :edit
    end
  end

  def destroy
    @homeland = Homeland.find(params[:id])

    @homeland.destroy
    redirect_to homelands_path
  end

  # 收藏功能
  def like
    @homeland = Homeland.find(params[:id])
    unless @homeland.find_homeland_like(current_user)    # 如果已经按讚过了，就略过不再新增
      HomelandLike.create( :user => current_user, :homeland => @homeland )
    end
  end

  def unlike
    @homeland = Homeland.find(params[:id])
    like = @homeland.find_homeland_like(current_user)
    like.destroy
    render "like"
  end

  private

  def homeland_params
    params.require(:homeland).permit(:user_id, :categories, :title, :description)
  end

end
