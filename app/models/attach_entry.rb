# coding: utf-8
# 散落的资源
class AttachEntry < AttachBase
  include Mongoid::Timestamps

  # 0 电影, 1 电视剧, 2 其他
  field :ftype, :type => Integer, :default => 0
  field :movie_name

  validates_presence_of :url
  validates_presence_of :name

  index :ftype

  index [[:created_at, Mongo::DESCENDING],[:_id, Mongo::DESCENDING]]
  scope :recent_times, desc(:created_at).desc(:_id)

  def ftype_s
    %w(电影 电视剧 其他)[self.ftype]
  end

  def movie_name
    return "" if self.name.blank?
    self[:movie_name] || self.name.match(/[\p{han}：\w]+/).to_s
  end
end
