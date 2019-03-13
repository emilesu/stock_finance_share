class HomelandPostsController < ApplicationController

  before_action :authenticate_user!, only:[:new, :create, :edit, :update, :destroy]
  before_action :current_homeland

  def new
    @homeland_post = HomelandPost.new
  end

  def create
    @homeland_post = HomelandPost.new(homeland_post_params)
    @homeland_post.user_id = current_user.id
    @homeland_post.homeland_id = @homeland.id

    if @homeland_post.save
      redirect_to homeland_path(@homeland)
    else
      redirect_to homeland_path(@homeland)
    end
  end

  def edit
    @homeland_post = HomelandPost.find(params[:id])
  end

  def update
    @homeland_post = HomelandPost.find(params[:id])

    if @homeland_post.update(homeland_post_params)
      redirect_to homeland_path(@homeland)
    else
      redirect_to homeland_path(@homeland)
    end
  end

  def destroy
    @homeland_post = HomelandPost.find(params[:id])

    @homeland_post.destroy
    redirect_to homeland_path(@homeland)
  end

  # 按赞功能
  def like
    @homeland_post = HomelandPost.find(params[:id])
    unless @homeland_post.find_homeland_post_like(current_user)    # 如果已经按讚过了，就略过不再新增
      HomelandPostLike.create( :user => current_user, :homeland_post => @homeland_post )
    end
  end

  def unlike
    @homeland_post = HomelandPost.find(params[:id])
    like = @homeland_post.find_homeland_post_like(current_user)
    like.destroy
    render "like"
  end

  private

  def current_homeland
    @homeland = Homeland.find(params[:homeland_id])
  end

  def homeland_post_params
    params.require(:homeland_post).permit(:user_id, :homeland_id, :description)
  end

end
