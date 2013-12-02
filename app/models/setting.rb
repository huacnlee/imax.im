# coding: utf-8
class Setting < Settingslogic
  source "#{Rails.root}/config/setting.yml"
  namespace Rails.env
end
