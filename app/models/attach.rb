# coding: utf-8
require "file_size_validator"
require "torrent_file"
class Attach < AttachBase
  include Mongoid::Document

  attr_accessor :allow_update_uploaded_at

  embedded_in :movie
  belongs_to :user

  scope :usefull, desc(:quality).asc(:name)
  scope :sort_by_name, asc(:name)

  def to_s
    "#{self.name} [#{self.file_size}GB]"
  end
  
  def to_atv_json
    {
      :name => self.name,
      :url => self.url,
      :quality => self.quality_s
    }
  end

  after_create do
    self.check_to_update_last_uploaded_at
  end

  def send_to_weibo
    msg = "《#{self.movie.title}》 #{self.name.force_encoding("utf-8")} 【#{self.file_size}G】 http://#{Setting.domain}/movies/#{self.movie.id}"
    if Rails.env == "production"
      f = File.open("/tmp/open-uri-temp-attach-#{self.id}", "wb")
      open(self.movie.cover.url(:large)) do |read_file|
        f.write(read_file.read)
      end
      $weibo.upload_image(msg, f.path)
      File.delete(f.path)
    else
      puts "--- #{msg}"
    end
    true
  end

  # 检查是否能上榜
  def check_to_update_last_uploaded_at
    # 只有 720p 以上的才改变首页更新
    puts "---- allow_update_uploaded_at: #{self.allow_update_uploaded_at}"
    if self.allow_update_uploaded_at.to_i == 1
      self.movie.update_attribute(:last_uploaded_at, Time.now)
    end
  end

  def real_hd?
    self.quality >= 720
  end

  # 是否是高清
  def hd?
    self.quality >= 480
  end
end
