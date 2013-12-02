# coding: UTF-8
class Admin::Homeland::RepliesController < Admin::ApplicationController

  def index
    @replies = Homeland::Reply.recent.paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html # index.html.erb
      format.json
    end
  end

  def show
    @reply = Homeland::Reply.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json
    end
  end

  def new
    @reply = Homeland::Reply.new

    respond_to do |format|
      format.html # new.html.erb
      format.json
    end
  end

  def edit
    @reply = Homeland::Reply.find(params[:id])
  end

  def create
    @reply = Homeland::Reply.new(params[:reply])

    respond_to do |format|
      if @reply.save
        format.html { redirect_to(admin_homeland_replies_path, :notice => 'Reply 创建成功。') }
        format.json
      else
        format.html { render :action => "new" }
        format.json
      end
    end
  end

  def update
    @reply = Homeland::Reply.find(params[:id])

    respond_to do |format|
      if @reply.update_attributes(params[:reply])
        format.html { redirect_to(admin_homeland_replies_path, :notice => 'Reply 更新成功。') }
        format.json
      else
        format.html { render :action => "edit" }
        format.json
      end
    end
  end

  def destroy
    @reply = Homeland::Reply.find(params[:id])
    @reply.destroy

    respond_to do |format|
      format.html { redirect_to(admin_homeland_replies_path,:notice => "删除成功。") }
      format.json
    end
  end
end
