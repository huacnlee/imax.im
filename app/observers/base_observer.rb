class BaseObserver < ActiveRecord::Observer
  def expire_page(key)
    ActionController::Base.expire_page(key)
  end
      
  def url_helpers
    Rails.application.routes.url_helpers
  end
end