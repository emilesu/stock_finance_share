class AdminController < ApplicationController
  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :require_admin!

  layout "admin"

  private

  # 管理员权限判断
  def require_admin!
    if current_user.role != "admin"
      flash[:alert] = "你的权限不足"
      redirect_to root_path
    end
  end

end
