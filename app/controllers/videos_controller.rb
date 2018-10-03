class VideosController < ApplicationController

  impressionist actions: [:show]

  def index
    @videos = Video.all
  end

  def show
    @video = Video.find(params[:id])
  end

end
