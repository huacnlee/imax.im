# coding: utf-8
require "digest/md5"
module UsersHelper
  # 生成用户 login 的链接，user 参数可接受 user 对象或者 字符串的 login
  def user_name_tag(user,options = {})
    return "" if user.blank?
    link_to(user.name, user_path(user.id), :class => "uname")
  end

  def user_name_str_tag(name, id)
    return "" if name.blank? or id.blank?
    link_to(name, user_path(id), :class => "uname")
  end

  def user_avatar_width_for_size(style)
    case style
      when :normal then 48
      when :small then 16
      when :large then 64
      when :big then 120
      else ""
    end
  end

  def user_avatar_tag(user,  opts = {})
    link = opts[:link] || true
    style = opts[:style] || :small

    width = user_avatar_width_for_size(style)

    if user.blank?
      hash = Digest::MD5.hexdigest("")
      return image_tag( User.new.avatar.url(style), :style => "width:#{width}px;height:#{width}px;")
    end

    img = image_tag(user.avatar.url(style), :style => "width:#{width}px;height:#{width}px;")

    if link
      raw %(<a href="#{user_path(user.id)}"class="uavatar">#{img}</a>)
    else
      raw img
    end
  end

  def verified_user?
    return false if current_user.blank?
    current_user.verified?
  end

  def notify_new_icon_tag(notify)
    return "" if current_user.blank?
    if notify.cache_key.split("_").last.to_i > (current_user.last_read_mention_at.to_i || 0)
      raw content_tag("span", "New", :class => "badge badge-important")
    end
  end
end