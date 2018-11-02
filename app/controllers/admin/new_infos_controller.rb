class Admin::NewInfosController < AdminController

  def index
    @new_infos = NewInfo.all.order("created_at desc").page(params[:page]).per(25)
  end

  def show
    @new_info = NewInfo.find(params[:id])
  end

  def new
    @new_info = NewInfo.new
  end

  def create
    @new_info = NewInfo.new(new_info_params)
    if @new_info.save
      redirect_to admin_new_infos_path
    else
      render :new
    end
  end

  def edit
    @new_info = NewInfo.find(params[:id])
  end

  def update
    @new_info = NewInfo.find(params[:id])
    if @new_info.update(new_info_params)
      redirect_to admin_new_infos_path
    else
      render :edit
    end
  end

  def destroy
    @new_info = NewInfo.find(params[:id])
    @new_info.destroy
    redirect_to admin_new_infos_path
  end

  private

  def new_info_params
    params.require(:new_info).permit(:title, :description, :image, :up_time, :link_1, :link_1_info, :link_2, :link_2_info)
  end

end
