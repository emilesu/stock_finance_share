class NewInfosController < ApplicationController

  def index
    @new_infos = NewInfo.all.order("created_at desc").page(params[:page]).per(15)
  end

end
