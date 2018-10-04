class OmniauthCallbacksController < ApplicationController


  def wechat
    auth = request.env['omniauth.auth']       # 引入回调数据 HASH
    data = auth.info                          # https://github.com/skinnyworm/omniauth-wechat-oauth2
    identify = Identify.find_by(provider: auth.provider, uid: auth.uid)

    if identify                               # 判断是否是已经注册的用户
      @user = identify.user                   # true 则通过 identify直接调去
    else                                      # false 则注册新用户
      i = Devise.friendly_token[0,20]
      user = User.create!(
        username: data.nickname,
        openid: auth.extra.raw_info.openid,
        email:  "#{auth.extra.raw_info.openid}@holdle.com",       # 因为devise 的缘故,邮箱暂做成随机
        avatar: data.headimgurl,
        password: i,                                              # 密码随机
        password_confirmation: i
      )
      identify = Identify.create(
        provider: auth.provider,
        uid: auth.uid,
        user_id: user.id
      )
      @user = user
      if @user.save!
        # 注册后直接和站长建立关联
        @user.attentions.create!(
          :user_id => @user.id,
          :my_attention => User.find_by_role("admin").id
        )
      end
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


  def google_oauth2
    access_token = request.env['omniauth.auth']
    data = access_token.info
    identify = Identify.find_by(provider: access_token.provider, uid: access_token.uid)

    if identify
      @user = identify.user
    else
      i = Devise.friendly_token[0,20]
      user = User.create(
          username: data.name,
          # openid: data.email,
          email: data.email,
          avatar: data.image,
          password: i,
          password_confirmation: i
      )
      identify = Identify.create(
          provider: access_token.provider,
          uid: access_token.uid,
          user_id: user.id
      )
      @user = user
      if @user.save!
        # 注册后直接和站长建立关联
        @user.attentions.create!(
          :user_id => @user.id,
          :my_attention => User.find_by_role("admin").id
        )
      end
    end

    sign_in_and_redirect @user, :event => :authentication
  end

  # def google_oauth2
  #   @user = User.from_google(request.env["omniauth.auth"], current_user)
  #
  #   if @user.persisted?
  #       flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
  #       sign_in_and_redirect @user, :event => :authentication
  #   else
  #       session["devise.user_data"] = request.env["omniauth.auth"]
  #       redirect_to new_user_registration_path
  #   end
  # end


  def facebook
    @user = User.from_facebook(request.env["omniauth.auth"], current_user)

    if @user.persisted?
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"
        sign_in_and_redirect @user, :event => :authentication
    else
        session["devise.user_data"] = request.env["omniauth.auth"]
        redirect_to new_user_registration_path
    end
  end


  def github
    @user = User.from_github(request.env["omniauth.auth"], current_user)

    if @user.persisted?
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Github"
        sign_in_and_redirect @user, :event => :authentication
    else
        session["devise.user_data"] = request.env["omniauth.auth"]
        redirect_to new_user_registration_url
    end
  end


end
