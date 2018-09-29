class Admin::VideosController < AdminController

  def index
    @videos = Video.all
  end

  def show
    @video = Video.find(params[:id])
  end

  def new
    @video = Video.new
  end

  def create
    @video = Video.new(video_params)
    if @video.save
      redirect_to admin_videos_path
    else
      render :new
    end
  end

  def edit
    @video = Video.find(params[:id])
  end

  def update
    @video = Video.find(params[:id])
    if @video.update(video_params)
      redirect_to admin_videos_path
    else
      render :edit
    end
  end

  def destroy
    @video = Video.find(params[:id])
    @video.destroy
    redirect_to admin_videos_path
  end

  private

  def video_params
    params.require(:video).permit(:title, :description, :cover, :video_link_1, :video_link_2, :video_link_3, :video_link_4)
  end

end
