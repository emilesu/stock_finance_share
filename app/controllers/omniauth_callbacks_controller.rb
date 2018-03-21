class OmniauthCallbacksController < ApplicationController


  def wechat
    auth = request.env['omniauth.auth']
    data = auth.info
    identify = Identify.find_by(provider: auth.provider, uid: auth.uid)

    if identify
      @user = identify.user
    else
      user = User.create(
        username: data.nickname,
        openid: auth.extra.raw_info.openid,
        email:  "#{auth.extra.raw_info.openid}@holdle.com",
        avatar: data.headimgurl,
        password: Devise.friendly_token[0,20]
      )
      identify = Identify.create(
        provider: auth.provider,
        uid: auth.uid,
        user: user
      )
      @user = user
    end

    sign_in_and_redirect @user, :event => :authentication
    redirect_to root_path
  end

  # def wechat
  #   @user = User.from_wechat(request.env["omniauth.auth"], current_user)
  #   if @user.persisted?
  #       sign_in_and_redirect @user, :event => :authentication
  #   else
  #       session["devise.user_data"] = request.env["omniauth.auth"]
  #       redirect_to new_user_registration_path
  #   end
  # end

end
