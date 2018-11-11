class NewInfosController < ApplicationController

  def index
    @new_infos = NewInfo.all.order("up_time desc").page(params[:page]).per(15)
  end

end
