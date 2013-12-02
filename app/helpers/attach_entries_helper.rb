# coding: utf-8
module AttachEntriesHelper
  def attach_entry_name_tag(attach)
    return "" if attach.blank?
    link_to attach.name, attach_entry_path(attach.id)
  end

  def attach_entry_play_button_tag(attach)
    return "" if attach.blank?
    title = "点击即可在线观看《#{attach.name}》"
    class_name = "btn btn-primary"
    link_to raw("<i class='icon-play-circle icon-white'></i> 立刻在线观看"), "#",
            :onclick => "return Movies.playAttachByUrl('#{attach.download_url}');",
            :class => class_name, :rel => "twipsy", :title => title
  end
end