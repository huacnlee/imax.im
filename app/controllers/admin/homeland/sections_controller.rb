# coding: UTF-8
class Admin::Homeland::SectionsController < Admin::ApplicationController

  def index
    @sections = Homeland::Section.desc(:_id).paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html # index.html.erb
      format.json
    end
  end

  def show
    @section = Homeland::Section.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json
    end
  end

  def new
    @section = Homeland::Section.new

    respond_to do |format|
      format.html # new.html.erb
      format.json
    end
  end

  def edit
    @section = Homeland::Section.find(params[:id])
  end

  def create
    @section = Homeland::Section.new(params[:section])

    respond_to do |format|
      if @section.save
        format.html { redirect_to(admin_homeland_sections_path, :notice => 'Section 创建成功。') }
        format.json
      else
        format.html { render :action => "new" }
        format.json
      end
    end
  end

  def update
    @section = Homeland::Section.find(params[:id])

    respond_to do |format|
      if @section.update_attributes(params[:section])
        format.html { redirect_to(admin_homeland_sections_path, :notice => 'Section 更新成功。') }
        format.json
      else
        format.html { render :action => "edit" }
        format.json
      end
    end
  end

  def destroy
    @section = Homeland::Section.find(params[:id])
    @section.destroy

    respond_to do |format|
      format.html { redirect_to(admin_homeland_sections_path,:notice => "删除成功。") }
      format.json
    end
  end
end
