# coding: utf-8
class Admin::ApplicationController < ApplicationController
  layout "admin"
  before_filter :require_admin
end
