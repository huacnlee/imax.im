require "open-uri"
class HomeController < ApplicationController
  before_filter :check_site_enable_with_douban, :only => [:index]
  
  def index
    set_seo_meta(nil, SiteConfig.home_meta_keywords, SiteConfig.home_meta_description)
    etags = []
    etags << SiteConfig.home_suggest_movie_ids
    etags << SiteConfig.home_us_movie_ids
    etags << SiteConfig.home_cn_movie_ids
    etags << SiteConfig.home_kr_movie_ids
    etags << SiteConfig.home_series_ids
    etags << SiteConfig.home_cartoon_movie_ids
    fresh_when(:etag => etags)
  end
  
  def remote_fetch
    render :text => open(params[:url]).read
  end
  
  def info1
    @id = rand(50) + 1
    render :layout => false
  end
end
