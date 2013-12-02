# coding: utf-8
require File.expand_path('../boot', __FILE__)

require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"
require "rails/test_unit/railtie"
require "sprockets/railtie"

if defined?(Bundler)
  Bundler.require *Rails.groups(:assets => %w(production development test))
end

module Movieso
  class Application < Rails::Application
    config.autoload_paths += %W(#{config.root}/cells)
    config.autoload_paths += %W(#{config.root}/uploaders)
    config.autoload_paths += %W(#{config.root}/lib)

    config.time_zone = 'Beijing'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = "zh-CN"

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password,:password_confirm]

    config.mongoid.include_root_in_json = false

    # config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.middleware.use "CustomHeaders"
  end
end

require "string_extensions"

MOVIE_FILTER_DATAS = {
  :country => ["地区", [["全部",""],["美国","美国"],["中国大陆","中国大陆"],["香港","香港"],["日本","日本"],["韩国","韩国"],["法国","法国"],["德国","德国"],["泰国","泰国"]]],
  :category => ["类型", [["全部",""], ["科幻","科幻"],["动作","动作"],["喜剧","喜剧"],["爱情","爱情"], ["剧情","剧情"],["魔幻","魔幻"],["动画","动画"],["悬疑","悬疑"],["惊悚","惊悚"],["战争","战争"],["历史","历史"]]],
  :year => ["年份",[["全部",""],["2013","2012","2012"],["2011","2011"],["2010","2010"],["2009","2009"],["2008","2008"],["2007","2007"],["2006","2006"],["00年代","00"],["90年代","90"],["80年代","80"],["70年代","70"]]]
}

MOVIE_SORT_DATAS = [["上映时间",:recent],["资源上传",:upload],["豆瓣评分",:rank]]
