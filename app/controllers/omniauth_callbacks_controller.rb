class OmniauthCallbacksController < ApplicationController


  def wechat
    @user = User.from_wechat(request.env["omniauth.auth"], current_user)
    if @user.persisted?
        sign_in_and_redirect @user, :event => :authentication
    else
        session["devise.user_data"] = request.env["omniauth.auth"]
        redirect_to new_user_registration_path
    end
  end

end
