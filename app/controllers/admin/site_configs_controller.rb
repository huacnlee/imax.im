# coding: UTF-8
class Admin::SiteConfigsController < Admin::ApplicationController

  def index
    @site_configs = SiteConfig.recent.paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html # index.html.erb
      format.json
    end
  end

  def show
    @site_config = SiteConfig.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json
    end
  end

  def new
    @site_config = SiteConfig.new

    respond_to do |format|
      format.html # new.html.erb
      format.json
    end
  end

  def edit
    @site_config = SiteConfig.find(params[:id])
  end

  def create
    @site_config = SiteConfig.new(params[:site_config])

    respond_to do |format|
      if @site_config.save
        format.html { redirect_to(admin_site_configs_path, :notice => 'Site config 创建成功。') }
        format.json
      else
        format.html { render :action => "new" }
        format.json
      end
    end
  end

  def update
    @site_config = SiteConfig.find(params[:id])

    respond_to do |format|
      if @site_config.update_attributes(params[:site_config])
        format.html { redirect_to(admin_site_configs_path, :notice => 'Site config 更新成功。') }
        format.json
      else
        format.html { render :action => "edit" }
        format.json
      end
    end
  end

  def destroy
    @site_config = SiteConfig.find(params[:id])
    @site_config.destroy

    respond_to do |format|
      format.html { redirect_to(admin_site_configs_path,:notice => "删除成功。") }
      format.json
    end
  end
end
