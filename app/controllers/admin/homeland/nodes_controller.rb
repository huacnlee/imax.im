# coding: UTF-8
class Admin::Homeland::NodesController < Admin::ApplicationController

  def index
    @nodes = Homeland::Node.desc(:_id).paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html # index.html.erb
      format.json
    end
  end

  def show
    @node = Homeland::Node.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json
    end
  end

  def new
    @node = Homeland::Node.new

    respond_to do |format|
      format.html # new.html.erb
      format.json
    end
  end

  def edit
    @node = Homeland::Node.find(params[:id])
  end

  def create
    @node = Homeland::Node.new(params[:node])

    respond_to do |format|
      if @node.save
        format.html { redirect_to(admin_homeland_nodes_path, :notice => 'Node 创建成功。') }
        format.json
      else
        format.html { render :action => "new" }
        format.json
      end
    end
  end

  def update
    @node = Homeland::Node.find(params[:id])

    respond_to do |format|
      if @node.update_attributes(params[:node])
        format.html { redirect_to(admin_homeland_nodes_path, :notice => 'Node 更新成功。') }
        format.json
      else
        format.html { render :action => "edit" }
        format.json
      end
    end
  end

  def destroy
    @node = Homeland::Node.find(params[:id])
    @node.destroy

    respond_to do |format|
      format.html { redirect_to(admin_homeland_nodes_path,:notice => "删除成功。") }
      format.json
    end
  end
end
