# coding: utf-8
class BaseCell < Cell::Rails
  helper :application, :users
  
  def cookies
    parent_controller.cookie_for_cell
  end
end
