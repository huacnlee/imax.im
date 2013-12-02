# coding: utf-8
module ApplicationHelper
  def retina?
    return false if cookies.blank?
    %w(2 1.5).include?(cookies[:devicePixelRatio])
  end
  
  def cache(name = {}, options = nil, &block)
    retina_key = retina? ? 'retina' : ''
    if name.is_a?(String)
      name += retina_key
    elsif name.is_a?(Array)
      name << retina_key
    end
    super(name, options, &block)
  end
  
  def notice_message
    flash_messages = []

    flash.each do |type, message|
      type = :success if type == :notice
      text = content_tag(:div, link_to("x", "#", :class => "close") + message, :class => "alert alert-#{type}")
      flash_messages << text if message
    end

    flash_messages.join("\n").html_safe
  end

  def auth_token_tag
    raw "<input name=\"authenticity_token\" type=\"hidden\" value=\"#{form_authenticity_token}\" />"
  end
  
  def captcha_tag(*args)
      options = { :alt => 'captcha', :width => EasyCaptcha.image_width, :height => EasyCaptcha.image_height }
      options.merge! args.extract_options!
      image_tag(captcha_url(:i => Time.now.to_i), options)
    end

  def render_page_title
    title = @page_title ? "#{@page_title} | #{Setting.app_name}" : Setting.app_name
    content_tag("title", title, nil, false)
  end

  def admin?(user = nil)
    user ||= current_user
    user.try(:admin?)
  end

  def verified?(user = nil)
    user ||= current_user
    user.try(:verified?)
  end

  def owner?(item)
    return false if item.blank? or current_user.blank?
    item.user_id == current_user.id
  end

  def timeago(time, options = {})
    options[:class] ||= "timeago"
    return time.to_date.to_s if time >= 2.months.ago
    content_tag(:abbr, "", options.merge(:title => time.iso8601)) if time
  end

  def small_icon_tag(name, opts = {})
    opts[:label] ||= ""
    name = "icon icon-#{name}" if not name.match(/icon\-/i)
    raw [content_tag("i","",:class => name),opts[:label]].join("")
  end
  
  MOBILE_USER_AGENTS =  'palm|blackberry|nokia|phone|midp|mobi|symbian|chtml|ericsson|minimo|' +
                        'audiovox|motorola|samsung|telit|upg1|windows ce|ucweb|astel|plucker|' +
                        'x320|x240|j2me|sgh|portable|sprint|docomo|kddi|softbank|android|mmp|' +
                        'pdxgw|netfront|xiino|vodafone|portalmmm|sagem|mot-|sie-|ipod|up\\.b|' +
                        'webos|amoi|novarra|cdm|alcatel|pocket|iphone|mobileexplorer|mobile'
  def mobile?
    agent_str = request.user_agent.to_s.downcase
    return false if agent_str =~ /ipad/
    agent_str =~ Regexp.new(MOBILE_USER_AGENTS)
  end
  
  def user_mobile_player?
    agent_str = request.user_agent.to_s.downcase
    agent_str =~ Regexp.new(MOBILE_USER_AGENTS)
  end
  
end
