# coding: utf-8
class Home
  def self.per_size
    6
  end

  def self.cartoon_movies
    self.query_movie_by_key(SiteConfig.home_cartoon_movie_ids)
  end

  def self.cn_movies
    self.query_movie_by_key(SiteConfig.home_cn_movie_ids)
  end

  def self.us_movies
    self.query_movie_by_key(SiteConfig.home_us_movie_ids)
  end

  def self.kr_movies
    self.query_movie_by_key(SiteConfig.home_kr_movie_ids)
  end

  def self.series
    self.query_movie_by_key(SiteConfig.home_series_ids)
  end

  def self.suggest_movies
    self.query_movie_by_key(SiteConfig.home_suggest_movie_ids)
  end

  def self.push_suggest(movie)
    self.push_id_to_site_config(:home_suggest_movie_ids, movie)
  end

  def self.push_movie(movie)
    key = ""
    if movie.series == true
      key = "home_series_ids"
    elsif movie.category_list.match(/动画|动漫/) or movie.tag_list.match(/动画|动漫/)
      key = "home_cartoon_movie_ids"
    elsif movie.countries.include?("美国") or movie.tags.include?("美国")
      key = "home_us_movie_ids"
    elsif movie.country_list.match(/中国|香港|台湾/)
      key = "home_cn_movie_ids"
    elsif movie.countries.include?("韩国")
      key = "home_kr_movie_ids"
    else
      return false
    end
    self.push_id_to_site_config(key, movie)
  end

  private
  def self.push_id_to_site_config(key, movie)
    return false if movie.blank?
    return false if !movie.has_attach?
    old_ids = self.get_array_ids(SiteConfig.send(key))
    old_ids << movie.id
    old_ids.uniq!
    old_ids.shift if old_ids.length > Home.per_size
    SiteConfig.send("#{key}=",old_ids.join(","))
  end

  def self.get_array_ids(val)
    ids = val.split(/,|，/).uniq.collect { |id| id.to_i }
  end

  def self.query_movie_by_key(ids)
    old_ids = self.get_array_ids(ids)
    items = Movie.for_cover.where(:_id.in => old_ids).limit(self.per_size)
    items.sort do |a,b|
      old_ids.index(b.id) <=> old_ids.index(a.id)
    end
  end

end
