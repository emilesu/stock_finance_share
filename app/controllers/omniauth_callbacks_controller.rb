class OmniauthCallbacksController < ApplicationController


  def wechat
    auth = request.env['omniauth.auth']
    data = auth.info
    identify = Identify.find_by(provider: auth.provider, uid: auth.uid)

    if identify
      @user = identify.user
    else
      i = Devise.friendly_token[0,20]
      user = User.create!(
        username: data.nickname,
        openid: auth.extra.raw_info.openid,
        email:  "#{auth.extra.raw_info.openid}@holdle.com",
        avatar: data.headimgurl,
        password: i,
        password_confirmation: i
      )
      identify = Identify.create(
        provider: auth.provider,
        uid: auth.uid,
        user_id: user.id
      )
      @user = user
    end

    sign_in_and_redirect @user, :event => :authentication
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
