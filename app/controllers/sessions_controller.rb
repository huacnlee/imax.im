# coding: utf-8
class SessionsController < Devise::SessionsController
  skip_before_filter :require_no_authentication, :only => [ :new, :create ]
  def new
    session[:return_url] = params[:return] if !params[:return].blank?
    super
  end

  def create
    if captcha_valid?(params[:user][:captcha]) 
      resource = warden.authenticate!(auth_options)
      set_flash_message(:notice, :signed_in) if is_navigational_format?
      sign_in(resource_name, resource)
      return_url = session[:return_url] || after_sign_in_path_for(resource)
      respond_with resource, :location => return_url
    else
      build_resource
      # clean_up_passwords(resource)
      flash[:error] = "验证码错误，请重新输入."
      respond_with_navigational(resource) { 
        render :new 
      }
    end    
  end
end