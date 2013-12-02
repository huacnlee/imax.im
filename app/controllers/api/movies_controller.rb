# coding: utf-8
class Api::MoviesController < ApplicationController
  
  def index
    per_page = params[:per_page] || 24
    per_page = 100 if per_page.to_i >= 100
    list_filter_scope
    paginate_opts = {:page => params[:page], :per_page => per_page}
    if @titles.blank?
      paginate_opts.merge!(:total_entries => 2500)
    end
    @movies = @movies.without_series.paginate(paginate_opts)
    fresh_when(:etag => [@movies])
  end
  
  def search
    if params[:q].blank?
      render :text => ""
      return
    end
    respond_to do |format|
      format.html {
        @search = Movie.tire_search(params[:q], :page => params[:page], :per_page => 8)
        lines = @search.results.collect do |item|
          "#{item.title.escape_javascript}#!##{item.id}#!##{item.small_cover.escape_javascript}#!##{item.year}#!##{item.alias_list.escape_javascript}"
        end
        render :text => lines.join("\n")
      }
      format.json {
        @search = Movie.tire_search(params[:q],:load => true, :page => params[:page], :per_page => 8)
        lines = @search.results.sort { |a,b| b.score <=> a.score }.collect do |item|
          { :name => item.title, :id => item.id, :cover => item.cover.url(:small), :year => item.year }
        end
        render :json => lines
      }
    end
  end

  def show
    if params[:douban_url] or params[:imdb]
      if params[:douban_url]
        movie = Movie.new(:douban_url => params[:douban_url])
        @movie = Movie.find_by_douban(:id, movie.douban_id)
      else
        @movie = Movie.find_by_douban(:imdb, params[:imdb])
      end
      
      if @movie.blank?
        DoubanFetcher.perform_async(:id, movie.douban_id)
        render :json => { :success => false }, :callback => params[:callback]
      else
        render :json => { :success => true, :has_attach => @movie.has_attach?, :id => @movie.id, :play_url => @movie.default_download_url, :attachs_count => @movie.attachs.count }, :callback => params[:callback]
      end
      fresh_when(:etag => [@movie])
    else
      @movie = Movie.find(params[:id])
      render :json => @movie.to_atv_json
      fresh_when(:etag => [@movie])
    end
  end
  
  def multi
    ids = params[:ids].split(",")
    movies = Movie.where(:douban_id.in => ids)
    jsons = []
    for m in movies do
      jsons << { :has_attach => m.has_attach?, :id => m.id, :douban_id => m.douban_id }
      ids.delete(m.douban_id.to_s)
    end
    ids.each do |id|
      jsons << { :has_attach => false, :douban_id => id }
    end
    render :json => jsons.to_json, :callback => params[:callback]
  end
end
