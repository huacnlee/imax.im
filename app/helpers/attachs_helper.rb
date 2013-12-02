# coding: utf-8
module AttachsHelper
  def attach_name_tag(attach)
    link_to attach.name, attach.download_url, :class => "attach"
  end

  def attach_format_tag(attach)
    attach.format_s
  end
  
  def attach_xunlei_play_tag(attach)
    link_to "", "javascript:void(0);", :from => "un_#{Setting.xunlei_pid}", 
                                :sclass => "small", 
                                :class => "", 
                                :tclass => "",
                                :url => attach.download_url, 
                                :name => "TD_CLOUD_VOD_BUTTON"
  end
end