# coding: utf-8
class AttachsController < ApplicationController
  before_filter :find_movie
  before_filter :require_verified_user, :except => [:show]
  
  def show
    @attach = @movie.attachs.find_by_id(params[:id])
    @attach = @movie.attachs.first if @attach.blank?
    render :layout => false
    fresh_when(:etag => [@movie])
  end

  def new
    drop_breadcrumb("电影", movies_path)
    drop_breadcrumb(@movie.title, movie_path(@movie))
    drop_breadcrumb("上传下载资源")
    set_seo_meta("上传下载资源")
    @attach = @movie.attachs.build
    @attach.allow_update_uploaded_at = false
    @attach.quality = 720
  end

  def create
    if params[:multi].blank?
      @attach = @movie.attachs.new(params[:attach])
      @attach.user_id = current_user.id
      if @attach.save
        # 同步微博
        # @attach.send_to_weibo
        redirect_to movie_path(params[:movie_id]), :notice => "资源提交成功，感谢分享。"
      else
        render :new
      end
    else
      added_count = 0
      qualities = params[:quality].values
      params[:urls].values.each_with_index do |url,i|
        @attach = @movie.attachs.new
        @attach.url = url
        quality = qualities[i]
        if !quality.in?(%w(720 1080 480))
          quality = 0
        end
        @attach.quality = quality.to_i
        if not @attach.save
          Rails.logger.error("(Batch Attachs) @attach.save error: #{@attach.errors.inspect}")
        else
          added_count += 1
        end
      end
      redirect_to @movie, :notice => "成功加入了 #{added_count} 个资源。"
    end
  end

  def destroy
    @attach = @movie.attachs.find(params[:id])
    @attach.destroy
  end

  def edit
    @attach = @movie.attachs.find(params[:id])
  end

  def update
    @attach = @movie.attachs.find(params[:id])
    @attach.update_attributes(params[:attach])
    redirect_to movie_path(params[:movie_id]), :notice => "资源修改成功。"
  end

  private
  def find_movie
    @movie = Movie.find(params[:movie_id])
  end
end