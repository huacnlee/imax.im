# coding: utf-8
require "file_size_validator"
require "torrent_file"
require "bencode"
require "cgi"
class AttachBase
  include Mongoid::Document

  field :name
  field :format, :default => "torrent"
  # 屏幕高度，480, 481 ,720,1080,3000
  field :quality, :type => Integer, :default => 0
  field :url
  # 文件大小, (单位 Gb)
  field :file_size, :type => Float

  mount_uploader :file, AttachUploader

  validates_presence_of :format
  validates_presence_of :file, :if => Proc.new { |a| a.torrent? }
  validates_presence_of :url, :if => Proc.new { |a| !a.torrent? }
  validates_presence_of :name,:file_size, :if => Proc.new { |a| ["magnet","thunder"].include?(a) }
  validates :file, :file_size => { :maximum => 1.5.megabytes.to_i }
  validates :url, :uniqueness => true, :format => { :with => /(thunder|ed2k|magnet):/i, :on => :create }, :if => Proc.new { |a| not a.url.blank? }
  validates :quality, :inclusion => { :in => [0,480,481,720,1080,3000] }

  before_validation :fix_format
  def fix_format
    if !self.url.blank?
      protocol = self.url.split(":").first.downcase.strip
      case protocol
      when "thunder"
      when "http"
        self.format = "thunder"
      else
        self.format = protocol
      end
    else
    end
  end
  
  before_create :set_torrent_info
  def set_torrent_info
    if self.torrent?
      fname,flength,magnet_url = Attach.read_torrent(self.file.current_path)
      self.url = magnet_url
      self.format = "magnet"
      self.name = fname
      self.file_size = flength
      self[:file] = nil
    end
  end

  # 格式化 ed2k，加入 imax.im 信息，并修正中文
  before_create :format_ed2k
  def format_ed2k
    if self.format == "ed2k" and !self.url.blank?
      names = self.url.split("|")
      if names.length > 5
        filename = CGI.unescape(names[2].clone)
        self.url.gsub!(names[2],filename)
        self.name = filename
        self.file_size = AttachBase.byte_to_gb(names[3])
      end
    end
  end

  def self.byte_to_gb(number)
    (number.to_f / 1024 / 1024 / 1024).round(2)
  end

  def self.formats
    %w(torrent ed2k magnet thunder)
  end

  def format_s
    I18n.t("attach.format.#{self.format}")
  end

  def quality_s
    return "" if self.quality < 480
    return "HR-HDTV" if self.quality == 481
    return "3D" if self.quality == 3000
    return "#{self.quality}P"
  end

  def ext
    exts = self.name.split(".")
    return "" if exts.length == 1
    exts.last
  end

  def file_size_s
    "#{(self.file_size || 0)} G"
  end

  # 是否是 BT
  def torrent?
    self.format == "torrent"
  end

  def self.format_collection
    self.formats.collect { |f| [I18n.t("attach.format.#{f}"),f] }
  end

  def self.quality_collection
    %w(HR-HDTV 480P 720P 1080P 3D)
  end

  def download_url
    if self.url.blank?
      self.file.url
    else
      self.url
    end
  end
  
  def play_url
    @play_url ||= SiteConfig.play_url.gsub("\#{url}",self.download_url)
    @play_url
  end

  def lixian_add_url
    "http://lixian.vip.xunlei.com/lixian_login.html?referfrom=union&ucid=#{Setting.xunlei_pid}&furl=#{CGI.escape(self.download_url)}"
  end

  def self.read_torrent(file_name)
    info = TorrentFile.open(file_name).to_h["info"]
    if not info["files"].blank?
      total_length = info["files"].collect { |f| f["length"] }.sum
      file_name = info["name.utf-8"].blank? ? info["name"] : info["name.utf-8"]
    else
      total_length = info["length"].to_f
      file_name = info["name"]
    end

    hex_diegst = Digest::SHA1.hexdigest(info.bencode)
    file_name = file_name.force_encoding("utf-8")
    url = "magnet:?xt=urn:btih:#{hex_diegst}&dn=#{file_name}"
    [file_name, (total_length / 1024 / 1024 / 1024.00).round(2), url]
  end
end
