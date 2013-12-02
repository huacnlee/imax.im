class Source
  include Mongoid::Document
  embedded_in :movie
  
  field :site
  field :url
  
  validates_presence_of :url
  validates_uniqueness_of :url, :site
  validates_presence_of :site

  before_validation :fix_source_site
  def fix_source_site
    if !self.url.blank?
      url_domain = self.url.split("://").last.split("/").first
      self.site = case url_domain
      when "tv.sohu.com"
        "sohu"
      when "my.tv.sohu.com"
        "sohu"
      when "v.qq.com"
        "qq"
      when "www.tudou.com"
        "tudou"
      when "www.youku.com"
        "youku"
      when "v.youku.com"
        "youku"
      when "cps.youku.com"
        "youku"
      when "www.iqiyi.com"
        "iqiyi"
      when "www.letv.com"
        "letv"
      when "www.56.com"
        "56"
      when "video.sina.com.cn"
        "sina"
      when "www.funshion.com"
        "funshion"
      when "v.pps.tv"
        "pps"
      when "www.m1905.com"
        "m1905"
      when "vod.kankan.com"
        "kankan"
      when "v.ku6.com"
        "ku6"
      when "v.pptv.com"
        "pptv"
      end
    end
  end
  
  def self.sites
    %w(sohu sina qq youku iqiyi letv tudou 56 funshion m1905 kankan ku6 pptv pps)
  end
  
  def self.site_collection
    self.sites.collect { |s| [I18n.t("source.site.#{s}"),s] }
  end
  
  def to_atv_json
    {
      :site => self.site_s,
      :url => self.url
    }
  end
  
  def site_s
    I18n.t("source.site.#{self.site}")
  end
end