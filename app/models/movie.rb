# coding: utf-8
require "open-uri"
class Movie
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::BaseModel
  include Mongoid::TaggableOn
  include Mongoid::Sunspot
  include ActionView::Helpers::AssetTagHelper

  # 标题
  field :title
  field :year, :type => Integer
  # 别名
  taggable_on :alias
  # 导演
  taggable_on :directors
  # 主演
  taggable_on :actors
  # 类型
  taggable_on :categories
  # 国家
  taggable_on :countries
  # 语言
  taggable_on :languages
  # 标签
  taggable_on :tags

  field :pub_date, :type => Date
  field :time_length, :type => Integer
  field :imdb
  field :douban_id, :type => Integer
  field :rank, :type => Float, :default => 0.0
  field :raters_count, :type => Integer
  field :score, :type => Float, :default => 0.0
  field :cover
  field :website
  field :summary
  # 列表页的简介
  field :desc
  field :tagline
  field :last_uploaded_at, :type => DateTime
  field :hide, :type => Boolean, :default => false
  # 是否是电视剧
  field :series, :type => Boolean, :default => false
  # 电视剧集数
  field :episodes, :type => Integer
  # 背景偏移
  field :bg_offset, :type => Integer
  field :has_book, :type => Boolean
  # 是否有 HR-HDTV 的资源
  field :has_hr_hdtv, :type => Boolean, :default => false

  belongs_to :user
  embeds_many :attachs
  embeds_many :sources

  mount_uploader :cover, CoverUploader
  mount_uploader :bg, BackgroundUploader

  validates_presence_of :title
  validates_uniqueness_of :imdb, :if => Proc.new { |item| !item.imdb.blank? }
  validates_uniqueness_of :douban_id

  index :imdb, :uniq => true
  index :douban_id, :uniq => true
  index :pub_date
  index :year
  index :last_uploaded_at
  index :series
  index :score
  index :has_hr_hdtv
  
  attr_accessor :bg_url, :cover_url

  scope :recent_upload, desc(:last_uploaded_at)
  # TODO: slow with last_uploaded_at : ne query
  scope :has_attachs, where(:last_uploaded_at.ne => nil)
  scope :high_rank, where(:score.gt => 7).desc(:score, :raters_count)
  scope :newest, desc(:year,:last_uploaded_at)
  scope :series, where(:series => 1)
  scope :without_series, where(:series => 0)
  scope :for_list, only(:title, :_id, :year,:score, :rank,:raters_count, :"attachs._id", :"sources._id", :cover,:bg,:categories, :actors, :directors, :countries, :last_uploaded_at)
  scope :for_cover, only(:title, :_id, :year, :rank, :"attachs._id", :"sources._id", :cover)

  
  searchable do
    text :title, boost: 200
    text :alias_list, boost: 150 do
      alias_list
    end
    double :rank,:score
    integer :raters_count,:year
    string :small_cover
    boolean :has_attach do
      has_attach?
    end
  end
  
  def to_list_json
    {
      :id => self.id,
      :title => self.title,
      :year => self.year,
      :cover => self.cover.url(:normal),
      :rank => self.rank_s,
      :raters_count => self.raters_count
    }
  end
  
  def to_atv_json
    {
      :id => self.id,
      :title => self.title,
      :year => self.year,
      :actors => self.actors.slice(0,3),
      :directors => self.directors.slice(0,1),
      :languages => self.languages.slice(0,1),
      :countries => self.countries.slice(0,1),
      :categories => self.categories,
      :length => "#{self.time_length} min",
      :summary => self.summary,
      :rank => self.rank_s,
      :raters_count => self.raters_count,
      :cover => self.cover.url(:large),
      :attachs => self.attachs.collect { |a| a.to_atv_json },
      :sources => self.sources.collect { |a| a.to_atv_json }
    }
  end
  
  before_save do
    self.retotal_score if self.raters_count_changed? or self.rank_changed?
    true
  end
  def retotal_score
    # http://www.douban.com/group/topic/2426734/
    lv = self.raters_count || 0.00
    lr = self.rank || 0.00
    lc = 6.7
    lm = 20000.00
    self.score = (lv / (lv + lm)) * lr + (lm / (lv + lm)) * lc
  end
  before_validation do
    self.bg = Movie.download_file(self.bg_url) if !self.bg_url.blank?
    self.cover = Movie.download_file(self.cover_url) if !self.cover_url.blank?
  end
  
  def self.tire_search(q,params)
    q.gsub!("."," ")
    q.gsub!(":"," ")
    params[:load] ||= false
    params[:page] ||= 1
    params[:per_page] ||= 10
    solr_search do
      fulltext q do
        boost(400) do
          with(:has_attach, true)
        end
      end
      
      paginate :page => params[:page], :per_page => params[:per_page]
    end
  end

  def to_s
    self.title
  end

  def chinese?
    self.countries.include?("中国大陆") or self.countries.include?("中国")
  end

  # 最高质量那个下载地址
  def default_download_url
    if attach = self.attachs.first
      @default_download_url ||= attach.play_url
    end
    @default_download_url
  end

  def small_cover
    self.cover.url(:small)
  end
  
  def large_cover
    self.cover.url(:large)
  end
  
  def meta_title
    "#{self.title} | 高清 BT下载,电驴下载,迅雷下载,在线观看"
  end
  
  def meta_keywords
    %w(在线观看 BT下载 720p 1080p 电驴下载 迅雷下载).collect { |key| "#{self.title}#{key}" }.join(",")
  end
  
  def meta_description
    return self.desc if self.attachs.blank?
    urls = []
    self.attachs.usefull.each do |a|
      urls << "[#{a.quality_s}] #{a.download_url} | "
    end
    "《#{self.title}》#{self.year} #{self.rank_s} 高清下载地址: #{urls.join('')}"
  end
  
  def rank_s
    case self.rank_class_name
    when "50"
      "★★★★★"
    when "45"
      "★★★★☆"
    when "40"
      "★★★★"
    when "35"
      "★★★☆"
    when "30"
      "★★★"
    when "25"
      "★★☆"
    when "20"
      "★★"
    when "15"
      "★☆"
    when "10"
      "★"
    when "05"
      "☆"
    else
      ""
    end
  end

  before_save :downcase_fields
  def downcase_fields
    self.imdb = self.imdb.downcase if !self.imdb.blank?
  end

  # 自动生成简介
  before_create :set_desc_from_other_fields
  def set_desc_from_other_fields
    if self.desc.blank?
      list_summary = [self.pub_date,self.country_list, self.language_list, self.actor_list, self.director_list, self.summary].join(" / ").gsub("©豆瓣","")
      if list_summary.length < 155
        self.desc = list_summary
      else
        self.desc = list_summary[0,155]
      end
    end
  end

  def alias_list_was
    self.aliases_was.join(",")
  end

  # 有资源
  def has_attach?
    return false if self.attachs.blank? and self.sources.blank?
    self.attachs.count > 0 || self.sources.count > 0
  end

  # 英文标题
  def en_title
    self.aliases.each do |s|
      if !s.match(/\p{han}/)
        return s
      end
    end
    self.title
  end

  def rank_class_name
    i = self.rank
    if i > 9
      "50"
    elsif i > 8 and i < 9.1
      "45"
    elsif i > 7 and i < 8.1
      "40"
    elsif i > 6 and i < 7.1
      "35"
    elsif i > 5 and i < 6.1
      "30"
    elsif i > 4 and i < 5.1
      "25"
    elsif i > 3 and i < 4.1
      "20"
    elsif i > 2 and i < 3.1
      "15"
    elsif i > 1 and i < 2.1
      "10"
    elsif i > 0 and i < 1.1
      "05"
    elsif i < 0.1
      "00"
    end
  end

  def douban_url=(url)
    self.douban_id = url.split("?").first.split("/").last.to_i unless url.blank?
  end

  def douban_url
    return "" if self.douban_id.blank?
    "http://movie.douban.com/subject/#{self.douban_id}"
  end

  def imdb_url=(url)
    self.imdb = url.split("?").first.split("/").last unless url.blank?
  end

  def imdb_url
    return "" if self.imdb.blank?
    "http://www.imdb.com/title/#{self.imdb}"
  end

  def rates_url
    self.douban_url + "/collections"
  end

  def reviews_url
    self.douban_url + "/reviews"
  end

  def new_review_url
    self.douban_url + "/new_review"
  end

  def website
    url = read_attribute(:website)
    return "" if url.blank?
    url = "http://#{url}" unless url.match(/http[s]{0,1}\:\/\//)
    url
  end
  
  def movie_type
    self.series == true ? "剧集" : "电影"
  end
  
  def actor_list_for_share
    return "" if self.actors.blank?
    "主演: #{self.actors[0,2].join(", ")}"
  end

  def self.has_attachs_count_cached
    Rails.cache.fetch("movie-has_attachs_count_cached",:expires_in => 1.days) do
      self.has_attachs.count
    end
  end

  def self.count_cached
    Rails.cache.fetch("movie-count_cached",:expires_in => 1.days) do
      self.count
    end
  end

  def self.find_by_imdb_id(id)
    id = ["tt",id.to_s.downcase.strip.gsub('tt','')].join("")
    Movie.where(:imdb => id).first
  end

  def self.find_by_douban_id(id)
    id = id.to_s.strip
    Movie.where(:douban_id => id.to_i).first
  end

  def self.find_by_douban(pname, id)
    if pname.to_s == "imdb"
      return self.find_by_imdb_id(id)
    else
      return self.find_by_douban_id(id)
    end
  end

  # 更具豆瓣信息查找，如果没有将会抓取
  def self.find_or_create_by_douban(pname, id)
    movie = self.find_by_douban(pname, id)
    return movie if not movie.blank?
    Movie.fetch_douban(pname, id)
  end

  # 用于 异步方式 fetch 豆瓣信息，期间将会判断是否已有，以防止重复抓取
  def self.queue_fetch_douban(pname, id)
    movie = self.find_by_douban(pname, id)
    return movie if !movie.blank?
    self.fetch_douban(pname, id)
  end

  # TODO: 豆瓣 fetch 有每分钟 10 次的限制，有 API key 的是 40 次，需要做队列
  def self.fetch_douban(pname, id, opts = {})
    id = id.to_s.downcase
    movie = Movie.new()
    if pname.to_s == "imdb"
      url = "http://api.douban.com/v2/movie/subject/imdb/#{id}"
      if opts[:force] == true
        movie = Movie.find_or_initialize_by(:imdb => id)
      end
    else
      url = "http://api.douban.com/v2/movie/subject/#{id}"
      if opts[:force] == true
        movie = Movie.find_or_initialize_by(:douban_id => id)
      end
    end
    # 不处理编号为 0 的情况
    return movie if id.blank?
    return movie if id.to_s == "0"
    json = DoubanRequest.read(url)
    return movie if json.blank?
    m = JSON.parse(json)
    
    movie.douban_url = m["alt"]
    # movie.imdb = m.imdb
    
    # 是否是电视剧
    if !m["episodes_count"].blank?
      movie.episodes = m["episodes_count"].to_i
      movie.series = true
      
      # 电视剧单独取实际页面的信息
      douban_page_url = m["alt"]
      begin
        douban_page_doc = Nokogiri::HTML(open(douban_page_url).read)
      rescue => e
        logger.error "fetch_douban 视剧单独取实际页面的信息 错误: #{e}"
      end
      
      if !douban_page_doc.blank?
        movie.title = douban_page_doc.css("title").text().gsub('(豆瓣)','').strip
        douban_page_doc = nil
      end
    end
    
    # 标题别名
    movie.aliases = []
    
    movie.title = m["title"]
    movie.aliases << movie.title
    movie.aliases << m["original_title"]
    
    movie.alias_list += "," + m["aka"].join(",") unless m["aka"].blank?
    movie.aliases.uniq!
    movie.aliases.delete(movie.title)
    
    
    
    movie.year          = m["year"].to_i unless m["year"].blank?
    # movie.language_list = m.attribute["language"].join(",") unless m.attribute["language"].blank?
    movie.country_list  = m["countries"].join(",") unless m["countries"].blank?
    movie.actor_list    = m["casts"].collect { |c| c["name"] }.join(",") unless m["casts"].blank?
    movie.category_list = m["genres"].join(",") unless m["genres"].blank?
    movie.director_list = m["directors"].collect { |d| d["name"] }.join(",") unless m["directors"].blank?
    unless m["rating"].blank?
      movie.rank          = m["rating"]["average"].to_f unless m["rating"]["average"].blank?
    end
    movie.raters_count  = m["ratings_count"].to_i unless m["ratings_count"].blank?

    # movie.time_length = m.attribute["movie_duration"].first.to_s.to_i unless m.attribute["movie_duration"].blank?
    movie.summary     = m["summary"]
    # movie.website     = m.attribute["website"].first unless m.attribute["website"].blank?

    if !m["images"].blank?
      # 封面为空，或信息更新日期在 2012-06-05 之前（也就是实现新封面功能之前）时，获取封面信息
      if movie.cover.blank?
        movie.cover = Movie.download_file(m["images"]["large"])
      end
    end
    new_record = movie.new_record?
    movie.save
    # 新创建的刷新优酷信息
    movie.fetch_soku if new_record
    movie
  end

  # 获取高清的电影封面
  def self.fetch_cover_url(douban_id, cover_url)
    url = "http://movie.douban.com/subject/#{douban_id}/photos?type=R&start=0&sortby=vote&size=a&subtype=o"
    image_url = cover_url.gsub("spic","opic")
    begin
      doc = Nokogiri::HTML(open(url, 'UserAgent' => 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)').read)
    rescue => e
      puts "[ERROR] fetch douban cover page failed : #{e}"
      return image_url
    end

    lis = doc.css(".poster-col4 li")
    lis.each do |li|
      prop_doc   = li.css(".prop")
      label_doc  = li.css(".name")
      label_text = label_doc.blank? ? "" : label_doc.text().strip

      next if prop_doc.blank?
      prop = prop_doc.text().strip
      # 跳过没有 尺寸的
      next if prop.blank?

      # 判断比例, 跳过宽比高大的
      xy = prop.split("x")
      next if xy[0].to_i >= xy[1].to_i
      next if xy[0].to_i < 500
      next if label_text.match(/日本|韩国/)

      # 取得图片
      image_doc = li.css(".cover a img")
      if !image_doc.blank?
        image_url = image_doc.attr('src').to_s.gsub("/thumb","/photo")
        return image_url
      end
    end
    image_url
  end

  # 获取高清的电影封面
  def self.fetch_bg_url(douban_id)
    image_url = ""
    url = "http://movie.douban.com/subject/#{douban_id}/photos?type=S"
    begin
      doc = Nokogiri::HTML(open(url, 'UserAgent' => 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)').read)
    rescue => e
      puts "[ERROR] fetch douban cover page failed : #{e}"
      return image_url
    end

    lis = doc.css(".poster-col4 li")
    lis.each do |li|
      prop_doc = li.css(".prop")
      next if prop_doc.blank?
      prop = prop_doc.text().strip
      # 跳过没有 尺寸的
      next if prop.blank?

      # 判断比例, 跳过宽比高大的
      xy = prop.split("x")
      next if xy[0].to_i <= xy[1].to_i
      next if xy[0].to_i < 800

      # 取得图片
      image_doc = li.css(".cover a img")
      if !image_doc.blank?
        image_url = image_doc.attr('src').to_s.gsub("/thumb","/raw")
        return image_url
      end
    end
    image_url
  end


  def refresh_cover
    return false if self.douban_id.blank?
    begin
      image_url = Movie.fetch_cover_url(self.douban_id,"")
      if !image_url.blank?
        self.cover = Movie.download_file(image_url)
        self.save
      end
    rescue => e
      puts "[ERROR] <movie:#{self.id}>.refesh_cover failed: #{e}"
    end
  end

  def refresh_bg
    return false if self.douban_id.blank?
    begin
      self.bg_url = Movie.fetch_bg_url(self.douban_id)
      if !self.bg_url.blank?
        self.save
      end
    rescue => e
      puts "[ERROR] <movie:#{self.id}>.refresh_bg failed: #{e}"
    end
  end

  # 批量删除 attach
  def delete_attach_by_ids(ids)
    self.attachs.delete_all(:conditions => { :_id.in => ids.collect { |id| id.to_i }})
  end

  def has_720p?
    @has_720p ||= self.attachs.where(:quality => 720).size > 0
  end

  def has_1080p?
    @has_1080p ||= self.attachs.where(:quality => 1080).size > 0
  end

  def fetch_torrent_from_fenopy
    items_count = 0
    # 如果已经有高清了，那就跳过
    return 0 if self.has_1080p? and self.has_720p?

    # 如果没有英文标题就跳过
    return items_count if self.en_title.blank?

    url = "http://fenopy.eu/module/search/api.php?keyword=#{CGI.escape(self.en_title)}&category=3&limit=80&format=json"
    begin
      results = JSON.parse(open(url).read)
    rescue => e
      puts "[ERROR] Movie:#{self.id} fetch_torrent_from_fenopy :#{e}"
      return items_count
    end

    results.each do |result|
      puts result['name']
      # 跳过没有 magnet 的
      next if result['magnet'].blank?
      # 跳过为验证的
      next if result['verified'] != 1
      # 跳过标题里面没有 720，1080 关键词的电影
      next if result['name'].match('MULTi')
      qu = result['name'].match(/720p|1080p/i)
      next if qu.blank?
      qu = qu.to_s.downcase

      # New Attach 信息
      attach = self.attachs.new(:name => result["name"])
      attach.file_size = AttachBase.byte_to_gb(result["size"])

      case qu
      when "720p"
        next if self.has_720p?
        # 电视剧跳过小于 700m 的，电影跳过小于 3G 的 1080
        next if attach.file_size < (self.series == true ? 0.7 : 3)
        next if attach.file_size > 8
        attach.quality = 720
      when "1080p"
        next if self.has_1080p?
        # 电视剧跳过小于 2G 的，电影跳过小于 6G 的 1080
        next if attach.file_size < (self.series == true ? 2 : 6)
        next if attach.file_size > 12
        attach.quality = 1080
      else
        next
      end

      puts attach.name

      attach.url = result['magnet'].strip
      attach.format = "magnet"
      begin
        attach.save
      rescue => e
        puts "[ERROR] #{e}"
      end
      attach = nil
      items_count += 1
    end

    # 更新 last_uploaded_at
    if items_count > 0
      self.set(:last_uploaded_at, Time.now) if (self.try(:year) || 0) >= (Time.now.year - 2)
    end

    items_count
  end
  
  def fetch_soku
    url = "http://www.soku.com/v?keyword=#{CGI.escape(self.title)}"
    begin
      doc = Nokogiri::HTML(open(url))
    rescue => e
      puts "fetch_soku : #{url} error: \n\t#{e}"
      return 0
    end
    
    play_buttons = []
    items = doc.css(".foryouku .item")
    items.each do |item|
      # 确保名字能匹配上
      movie_type_name = (self.series == true ? "电视剧" : "电影")
      if item.css(".base_name").text.strip == self.title && item.css(".base_type").text.strip.match(movie_type_name) 
        # 匹配年份
        source_year = item.css(".base_pub").text.strip.match(/\d+/).to_s.to_i
        diff_year = self.year.blank? ? 0 : (self.year.to_i - source_year)
        if diff_year > 1 or diff_year < -1
          # 年份无法对应，跳过
          next
        end
        # 找出资源链接
        play_buttons = item.css(".playarea .source a")
        break
      end
    end
    
    if play_buttons.blank?
      return 0
    end
    
    play_buttons.each do |a|
      play_url = a.attr("href").strip
      self.sources.create(:url => play_url)
    end
    return play_buttons.size    
  end
  
  # def fetch_baidu_video
  #   url = "http://video.baidu.com/v?word=#{CGI.escape(self.title)}"
  #   begin
  #     doc = Nokogiri::HTML(open(url))
  #   rescue => e
  #     puts "fetch_baidu_video : #{url} error: \n\t#{e}"
  #     return 0
  #   end
  #   
  #   
  # end

  private
  def self.download_file(url)
    img = nil
    begin
      img = MiniMagick::Image.read(open(url).read)
    rescue => e
      Rails.logger.error { "Movie.download_file ERROR: #{url} #{e}" }
    end
    return img
  end
end
