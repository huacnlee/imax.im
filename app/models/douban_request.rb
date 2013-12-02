# require 'open-uri/cached'
class DoubanRequest
  def self.read(url)
    # 限制每分钟 38 次
    return false if !self.allow?
    self.hint
    begin
      api_url = "#{url}?apikey=#{Setting.douban_token}"
      result = open(api_url).read
    rescue => e
      Rails.logger.warn { "Movie.fetch_douban : #{e} url: #{url}" }
      result = ""
    end
    result
  end
  
  def self.cache_key
    "models/douban/request_count_#{Time.now.strftime("%Y%m%d%H%M")}"
  end
  
  def self.hint
    Rails.cache.increment(self.cache_key, 1)
  end
  
  def self.count
    Rails.cache.read(self.cache_key).to_i || 0
  end
  
  def self.allow?
    self.count < 40
  end
end