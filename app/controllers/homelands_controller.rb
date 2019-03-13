class HomelandsController < ApplicationController

  before_action :authenticate_user!, only:[:new, :create, :edit, :update, :destroy]
  before_action :validate_search_key
  impressionist actions: [:show, :index]

  def index
    if params[:categorie].blank?
      @homelands = case params[:order]
      when "last_reply"
        Homeland.where(:status => "公开").sort{ |x,y| y.homland_last_reply <=> x.homland_last_reply }
      when "most_view"
        Homeland.where(:status => "公开").sort{ |x,y| y.homland_most_view <=> x.homland_most_view }
      when "most_post"
        Homeland.where(:status => "公开").sort{ |x,y| y.homland_most_post <=> x.homland_most_post }
      else
        Homeland.where(:status => "公开").order("created_at DESC")
      end
    elsif params[:categorie]
      @homelands = Homeland.where(:status => "公开").where( :categories => params[:categorie] ).order("created_at DESC")
    end

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

  def search
    if @query_string.present?
      @homelands = search_params.where(:status => "公开").order("created_at DESC")
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
    params.require(:homeland).permit(:user_id, :categories, :title, :description)
  end

end
