class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception


  # facebook & google omniauth
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  # 登录后重新定向
  def after_sign_in_path_for(resource)
    request.env['omniauth.origin'] || stored_location_for(resource) || root_path
  end

  def configure_permitted_parameters
      added_attrs = [:username, :email, :password, :password_confirmation, :remember_me]
      devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
      devise_parameter_sanitizer.permit :account_update, keys: added_attrs<<:current_password
  end

end
