# coding: utf-8
# 正对 AttachBase
class AttachEntriesController < ApplicationController
  before_filter :init_channel
  before_filter :require_verified_user, :only => [:new, :create, :edit, :update]

  def index
    @attachs = AttachEntry.all
    @attachs = @attachs.recent_times.paginate(:page => params[:page], :per_page => 50, :total_entries => 30000)
    if @attachs.count > 0
      set_seo_meta("资源频道 - #{@attachs.first.name}")
    end
  end

  def show
    @attach = AttachEntry.find(params[:id])
    # search = Redis::Search.complete("Movie", @attach.movie_name, :limit => 1)
    # if !search.blank?
    #   @movie = Movie.find_by_id(search[0]['id'])
    # end

    @like_search = []
    begin
      @like_search = AttachEntry.tire.search(@attach.name, :page => 1, :per_page => 5)
    rescue => e
      logger.error("AttachEntriesController.show search failed : #{e}")
    end

    drop_breadcrumb(@attach.movie_name, search_attach_entries_path(:q => @attach.movie_name))
    drop_breadcrumb("查看下载与在线观看")
    set_seo_meta("#{@attach.name} - [#{@attach.movie_name}]", '', @attach.name)
  end

  def search
    redirect_to attach_entries_path and return if params[:q].blank?
    @search = AttachEntry.tire.search(params[:q], :page => params[:page], :per_page => 20)
    drop_breadcrumb("搜索")
    set_seo_meta("搜索 #{params[:q]} - 资源频道")
  end

 def new
    @attach_entry = AttachEntry.new
    drop_breadcrumb("发布")

    respond_to do |format|
      format.html # new.html.erb
      format.json
    end
  end

  def edit
    @attach_entry = AttachEntry.find(params[:id])
    drop_breadcrumb("查看资源", attach_entry_path(@attach_entry.id))
    drop_breadcrumb("修改")
  end

  def create
    @attach_entry = AttachEntry.new(params[:attach_entry])

    respond_to do |format|
      if @attach_entry.save
        format.html { redirect_to(attach_entry_path(@attach_entry), :notice => '创建成功。') }
        format.json
      else
        format.html { render :action => "new" }
        format.json
      end
    end
  end

  def update
    @attach_entry = AttachEntry.find(params[:id])
    drop_breadcrumb("查看资源", attach_entry_path(@attach_entry.id))
    drop_breadcrumb("修改")

    respond_to do |format|
      if @attach_entry.update_attributes(params[:attach_entry])
        format.html { redirect_to(attach_entry_path(@attach_entry), :notice => '更新成功。') }
        format.json
      else
        format.html { render :action => "edit" }
        format.json
      end
    end
  end

  def destroy
    @attach_entry = AttachEntry.find(params[:id])
    @attach_entry.destroy

    respond_to do |format|
      format.html { redirect_to(attach_entries_path,:notice => "删除成功。") }
      format.json
    end
  end

  def init_channel
    drop_breadcrumb("资源频道", attach_entries_path)
  end
end
