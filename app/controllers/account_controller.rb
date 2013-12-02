# coding: utf-8
class AccountController < Devise::RegistrationsController
  def edit
    @user = current_user
  end

  def new
    session[:return_url] = params[:return] if !params[:return].blank?
    super
  end

  # POST /resource
  def create
    build_resource
    if !captcha_valid?(resource.captcha)
      resource.errors.add(:captcha, :invalid)
    end

    return_url = session[:return_url] || after_sign_in_path_for(resource)
    if resource.errors.blank? and resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)
        respond_with resource, :location => return_url
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  def destroy
    resource.soft_delete
    sign_out_and_redirect("/login")
    set_flash_message :notice, :destroyed
  end
end
