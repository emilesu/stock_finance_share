class VideosController < ApplicationController

  impressionist actions: [:index, :show]

  def index
    @videos = Video.all
  end

  def show
    @video = Video.find(params[:id])
  end

end
