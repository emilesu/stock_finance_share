class VideosController < ApplicationController

  impressionist actions: [:index, :show]

  def index
    @videos = Video.all.order("created_at desc").page(params[:page]).per(9)
  end

  def show
    @video = Video.find(params[:id])
  end

end
