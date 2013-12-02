# coding: UTF-8
class Admin::AttachEntriesController < Admin::ApplicationController

  def index
    @attach_entries = AttachEntry.recent.paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html # index.html.erb
      format.json
    end
  end

  def show
    @attach_entry = AttachEntry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json
    end
  end

  def new
    @attach_entry = AttachEntry.new

    respond_to do |format|
      format.html # new.html.erb
      format.json
    end
  end

  def edit
    @attach_entry = AttachEntry.find(params[:id])
  end

  def create
    @attach_entry = AttachEntry.new(params[:attach_entry])

    respond_to do |format|
      if @attach_entry.save
        format.html { redirect_to(admin_attach_entries_path, :notice => 'Attach entry 创建成功。') }
        format.json
      else
        format.html { render :action => "new" }
        format.json
      end
    end
  end

  def update
    @attach_entry = AttachEntry.find(params[:id])

    respond_to do |format|
      if @attach_entry.update_attributes(params[:attach_entry])
        format.html { redirect_to(admin_attach_entries_path, :notice => 'Attach entry 更新成功。') }
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
      format.html { redirect_to(admin_attach_entries_path,:notice => "删除成功。") }
      format.json
    end
  end
end
