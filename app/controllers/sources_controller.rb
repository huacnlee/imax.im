# coding: utf-8
class SourcesController < ApplicationController
  before_filter :find_movie
  before_filter :require_verified_user, :except => [:show]
  
  def show
    @source = @movie.sources.find_by_id(params[:id])
    @source = @movie.sources.first if @source.blank?
    render "/attachs/show", :layout => false
    fresh_when(:etag => [@movie])
  end

  def new
    drop_breadcrumb("电影", movies_path)
    drop_breadcrumb(@movie.title, movie_path(@movie))
    drop_breadcrumb("上传在线资源")
    set_seo_meta("上传在线资源")
    @source = @movie.sources.build
  end

  def create
    @source = @movie.sources.new(params[:source])
    if @source.save
      redirect_to movie_path(params[:movie_id]), :notice => "在线播放信息提交成功。"
    else
      render :new
    end
  end

  def destroy
    @source = @movie.sources.find(params[:id])
    @source.destroy
    redirect_to @movie
  end

  private
  def find_movie
    @movie = Movie.find(params[:movie_id])
  end
end