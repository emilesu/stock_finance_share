class HomelandsController < ApplicationController

  before_action :authenticate_user!, only:[:new, :create, :edit, :update, :destroy]
  before_action :validate_search_key
  impressionist actions: [:show, :index]

  def index
    if  params[:categorie]
      @homelands = Homeland.where(:status => "公开").where( :categories => params[:categorie] ).order("created_at DESC").page(params[:page]).per(25)
    elsif params[:my]
      @homelands = case params[:my]
      when "my_homelands"
        Homeland.where( :user => current_user ).order("created_at DESC").page(params[:page]).per(25)
      when "my_homeland_likes"
        current_user.user_liked_homelands.order("created_at DESC").page(params[:page]).per(25)
      end
    else
      @homelands = Homeland.where(:status => "公开").order("created_at DESC").page(params[:page]).per(25)
    end
  end

  def show
    @homeland = Homeland.find(params[:id])
    @homeland_post_new = HomelandPost.new

    if params[:order]
      @homeland_posts = case params[:order]
      when "last_reply"
        @homeland.homeland_posts.order("created_at DESC").page(params[:page]).per(15)
      end
    else
      @homeland_posts = @homeland.homeland_posts.page(params[:page]).per(15)
    end
  end

  def new
    @homeland = Homeland.new
  end

  def create
    @homeland = Homeland.new(homeland_params)
    @homeland.user_id = current_user.id

    if @homeland.save
      redirect_to homeland_path(@homeland)
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

  # 搜索功能
  def search
    if @query_string.present?
      @homelands = search_params.where(:status => "公开").order("created_at DESC").page(params[:page]).per(25)
    end
  end


  protected

  def validate_search_key
    @query_string = params[:search].gsub(/\\|\'|\/|\?/, "") if params[:search].present?
  end

  private

  def search_params
    Homeland.ransack({:title_or_description_cont => @query_string}).result(distinct: true)
  end

  def homeland_params
    params.require(:homeland).permit(:user_id, :categories, :title, :description, :status)
  end

end
