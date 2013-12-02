# coding: utf-8
module MoviesHelper
  def movie_title_tag(movie, opts = {})
    allow_year = opts[:allow_year] || false
    return "" if movie.blank?
    title = movie.title
    class_name = ""
    link_title = movie.title
    if allow_year and not movie.year.blank?
      title = %{#{movie.title} <span class="year">(#{movie.year})}
    end
    unless movie.has_attach?
      class_name = "no_attach"
      link_title += " (暂无下载)"
    end
    return link_to raw(title), movie_path(movie), :title => link_title, :class => class_name
  end

  def movie_cover_tag(movie, opts = {})
    style = opts[:style] || :small
    opts[:rel] ||= ""
    opts[:allow_link] ||= true
    link_title = movie.title
    return image_tag(Movie.new.cover.url(style)) if movie.blank?
    unless movie.has_attach?
      class_name = "no_attach"
      link_title += " (暂无下载)"
    end
    
    if retina?
      style = case style
              when :small then :normal
              when :normal then :large
              else
                style
              end        
    end
    
    img = image_tag(movie.cover.url(style.to_sym), :alt => "《#{link_title}》电影海报", :rel => opts[:rel])
    if opts[:allow_link]
      link_to raw(img), movie_path(movie), :title => link_title, :class => class_name
    else
      img
    end
  end

  def movie_rank_tag(movie, opts = {})
    style = opts[:style] == :big ? "big" : "all"
    return "" if movie.blank?

    rank_s = movie.rank_class_name
    raw "<span class='movie_rank'><i class='icon #{style}star#{rank_s}'></i> <span itemprop='ratingValue'>#{movie.rank}</span></span>"
  end

  def movie_tags_tag(movie, field_name, opts = {})
    return "" if movie.blank? or field_name.blank?
    spliter = opts[:spliter] || " / "
    limit = opts[:limit] || 0
    field_name = field_name.to_s.downcase.tableize
    items = movie.send("#{field_name}")
    items = [] if items.blank?
    items = items[0,limit] if limit > 0

    raw items.collect { |tag|
      link_to(tag, "/movies?#{field_name.singularize}=#{tag}", :class => field_name.singularize)
    }.join(spliter)
  end

  def movie_sidebar_item_tag(movie)
    raw %{
      <div class="item mitem">
        <div class="cover">#{movie_cover_tag(movie, :style => :small)}</div>
        <div class="title">#{movie_title_tag(movie)}</div>
      </div>
    }
  end

  def movie_list_filter_url(key = nil,value = nil)
    base_movies_path_url = action_name == "series" ? series_movies_path : movies_path
    return base_movies_path_url if key.blank? && value.blank?
    filters = params.clone
    filters.delete("action")
    filters.delete("controller")
    filters.delete(key)
    filter_strs = filters.collect { |param| "#{param[0]}=#{param[1]}" }
    if not value.blank?
      filter_strs << "#{key}=#{value}"
    end
    param_str = filter_strs.join("&")
    if !param_str.blank?
      "#{base_movies_path_url}?#{param_str}"
    else
      base_movies_path_url
    end
  end
end
