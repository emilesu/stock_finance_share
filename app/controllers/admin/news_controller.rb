class Admin::NewsController < AdminController

  def index
    @news = New.all.page(params[:page]).per(25)
  end

  def show
    @new = New.find(params[:id])
  end

  def new
    @new = New.new
  end

  def create
    @new = New.new(new_params)
    if @new.save
      redirect_to admin_news_path
    else
      render :new
    end
  end

  def edit
    @new = New.find(params[:id])
  end

  def update
    @new = New.find(params[:id])
    if @new.update(new_params)
      redirect_to admin_news_path
    else
      render :edit
    end
  end

  def destroy
    @new = New.find(params[:id])
    @new.destroy
    redirect_to admin_news_path
  end

  private

  def new_params
    params.require(:new).permit(:title, :description, :image, :up_time, :link_1, :link_1_info, :link_2, :link_2_info)
  end

end
