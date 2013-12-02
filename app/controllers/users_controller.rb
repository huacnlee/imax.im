# coding: utf-8
class UsersController < ApplicationController
  before_filter :find_user, :only => [:show,:uploaded]
  def index
    @recent_users = User.recent.limit(30)
    drop_breadcrumb("会员")
  end

  def show
  end

  private
  def find_user
    @user = User.find(params[:id])
    drop_breadcrumb("会员", users_path)
    drop_breadcrumb(@user.name, user_path(@user))
  end
end
