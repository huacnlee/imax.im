# coding: utf-8
require "digest/md5"
class MoviesController < ApplicationController
  before_filter :require_admin, :only => [:fetch_douban, :fetch_cover, :fetch_bg, :fetch_fenopy]
  caches_action :feed, :expires_in => 20.minutes
  caches_action :feed_all, :expires_in => 10.minutes
  before_filter :check_site_enable_with_douban, :only => [:index,:show,:search,:series,:top]

  def index
    drop_breadcrumb("电影", movies_path)
    list_filter_scope
    paginate_opts = {:page => params[:page], :per_page => 12}
    if @titles.blank?
      paginate_opts.merge!(:total_entries => 2500)
    end
    @movies = @movies.without_series.paginate(paginate_opts)
    if !@titles.blank?
      page_title = @titles.join(" - ")
    else
      page_title = "最新上映"
    end
    set_seo_meta(page_title, @titles.join(","))
    fresh_when(:etag => [@titles,@movies])
  end

  def search
    @q = params[:q]
    @search = Movie.tire_search(params[:q], :load => true,:page => params[:page], :per_page => 12)
    drop_breadcrumb("搜索", search_movies_path)
    set_seo_meta("#{params[:q]} 的搜索结果")
  end

  def series
    drop_breadcrumb("电视剧")
    params[:sort] = "upload" if params[:sort].blank?
    list_filter_scope
    paginate_opts = {:page => params[:page], :per_page => 12}
    if @titles.blank?
      paginate_opts.merge!(:total_entries => 1000)
    end
    @movies = @movies.series.paginate(paginate_opts)
    if !@titles.blank?
      page_title = @titles.join(" - ")
    else
      page_title = "电视剧"
    end

    set_seo_meta(page_title)
    # fresh_when(:etag => [@titles,@movies])
    render :action => "index"
  end

  def feed
    @movies = Movie.recent_upload.limit(20)
  end

  def feed_all
    @movies = Movie.recent.limit(20)
    render "feed"
  end

  def top
    @movies = Movie.without_series.high_rank.for_list.paginate(:page => params[:page], :per_page => 12, :total_entries => 250)
    drop_breadcrumb("高分排行")
    set_seo_meta("高分电影 TOP 250")
    render "index"
  end


  def show    
    @movie = Movie.find(params[:id])
    if @movie.series
      @attachs = @movie.attachs.sort_by_name
      @is_series = true
    else
      @attachs = @movie.attachs.usefull
    end

    if @movie.series
      drop_breadcrumb("电视剧", series_movies_path)
    else
      drop_breadcrumb("电影", movies_path)
    end

    if !@movie.countries.blank?
      drop_breadcrumb(@movie.countries.first, movies_path(:country => @movie.countries.first))
    end
    if !@movie.categories.blank?
      drop_breadcrumb(@movie.categories.first, movies_path(:category => @movie.categories.first))
    end
    if !@movie.year.blank?
      drop_breadcrumb(@movie.year, movies_path(:year => @movie.year))
    end
    if !@movie.languages.blank?
      drop_breadcrumb(@movie.languages.first, movies_path(:language => @movie.languages.first))
    end
    if !@movie.actors.blank?
      drop_breadcrumb(@movie.actors.first, movies_path(:actor => @movie.actors.first))
    end
    drop_breadcrumb(@movie.title)
    set_seo_meta(@movie.meta_title, @movie.meta_keywords, @movie.meta_description)
    fresh_when(:etag => [@movie])
  end

  # GET /movies/new
  # GET /movies/new.json
  def new
    drop_breadcrumb("发布电影")
    @movie = Movie.new(:douban_url => params[:douban_url])

    if !@movie.douban_id.blank?
      existed_movie = Movie.find_by_douban(:id, @movie.douban_id)
      if !existed_movie.blank?
        if existed_movie.has_attach? or !current_user
          redirect_to existed_movie
        else
          redirect_to new_movie_attach_path(:movie_id => existed_movie.id), :notice => "暂无下载资源，如果你有，欢迎与大家分享。"
        end
      end
    end
  end

  # POST /movies
  # POST /movies.json
  def create
    @movie = Movie.new(params[:movie])

    if !@movie.douban_url.blank? and !@movie.douban_url.match(/movie\.douban\.com/)
      @movie.errors.add(:douban_url,"不是一个正确的地址。")
      render :new
      return
    end

    if not @movie.douban_url.blank?
      @movie = Movie.find_or_create_by_douban(:id, @movie.douban_id)
    else
      @movie = Movie.find_or_create_by_douban(:imdb, @movie.imdb)
    end

    if @movie.blank? or @movie.id.blank?
      @movie = Movie.new(params[:movie])
      @movie.errors.add("电影","未能在豆瓣上面找到，请检查 URL 或 IMDB 是否正确。")
      render :new
      return
    else
      if current_user and !@movie.has_attach?
        redirect_to new_movie_attach_path(:movie_id => @movie.id), :notice => "电影信息提交成功，请上传资源。"
      else
        redirect_to @movie, :notice => "电影信息提交成功。"
      end
    end
  end

  def douban_page
    if !self_page_request?
      render :text => "豆瓣信息请勿用新窗口打开"
      return
    end
    @movie = Movie.find(params[:id])
    redirect_to @movie.douban_url
  end

  def douban_review
    if !self_page_request?
      render :text => "豆瓣信息请勿用新窗口打开"
      return
    end
    @movie = Movie.find(params[:id])
    redirect_to @movie.reviews_url
  end

  def suggest
    @movie = Movie.find(params[:id])
    case params[:type]
    when "1"
      Home.push_suggest(@movie)
    when "0"
      Home.push_movie(@movie)
    end
    render :text => "1"
  end

  def fetch_douban
    @movie = Movie.find(params[:id])
    Movie.fetch_douban("douban", @movie.douban_id, :force => true)
    redirect_to movie_path(@movie.id), :notice => "电影在豆瓣上面的信息更新成功。"
  end

  def fetch_cover
    @movie = Movie.find(params[:id])
    @movie.refresh_cover
    redirect_to movie_path(@movie.id), :notice => "封面图片更新成功。"
  end

  def fetch_bg
    @movie = Movie.find(params[:id])
    @movie.refresh_bg
    redirect_to movie_path(@movie.id), :notice => "背景图片更新成功。"
  end

  def fetch_fenopy
    @movie = Movie.find(params[:id])
    count = @movie.fetch_torrent_from_fenopy
    notice_hash = { :alert => "未找到 #{@movie.en_title} 的任何资源." }
    if count > 0
      notice_hash = { :notice => "成功找到了 #{count} 个资源。" }
    end
    redirect_to movie_path(@movie.id), notice_hash
  end
  
  def fetch_sources
    @movie = Movie.find(params[:id])
    count = @movie.fetch_soku
    notice_hash = { :alert => "未找到 #{@movie.title} 的任何国内在线播放." }
    if count > 0
      notice_hash = { :notice => "成功找到了 #{count} 个国内在线播放。" }
    end
    redirect_to movie_path(@movie.id), notice_hash
  end
  
  def weekly
    @movies = Movie.where(:last_uploaded_at.gte => Date.today.at_beginning_of_week, 
                :last_uploaded_at.lte => Date.today.at_end_of_week).asc(:last_uploaded_at)
    render "weekly", :layout => false
  end

    
end
