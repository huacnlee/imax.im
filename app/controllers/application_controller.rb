# coding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from  ::AbstractController::ActionNotFound, :with => :render_404
  rescue_from  ActionController::MethodNotAllowed, :with => :render_404
  rescue_from  ActionController::MethodNotAllowed, :with => :render_404
  before_filter :init_page
  helper_method :cookie_for_cell

  def init_page
    if !current_user.blank?
    end
  end


  def render_404
    render_optional_error_file(404)
  end

  def render_403
    render_optional_error_file(403)
  end

  def self_page_request?
    ref = request.referrer || ""
    (ref.match("http://imax.im") || ref.match("http://127.0.0.1")) == nil ? false : true
  end

  def render_optional_error_file(status_code)
    status = status_code.to_s
    if ["404","403", "422", "500"].include?(status)
      render :template => "/errors/#{status}", :format => [:html], :handler => [:erb], :status => status, :layout => "application"
    else
      render :template => "/errors/unknown", :format => [:html], :handler => [:erb], :status => status, :layout => "application"
    end
  end

  def set_seo_meta(title = '',meta_keywords = '', meta_description = '')
    if !title.blank?
      @page_title = "#{title}"
      if !params[:page].blank?
        @page_title += " [第#{params[:page]}页]"
        drop_breadcrumb("第#{params[:page]}页")
      end
    end
    @meta_keywords = meta_keywords
    @meta_description = meta_description
  end

  def drop_breadcrumb(name, path = request.path)
    @breadcrumbs ||= []
    @breadcrumbs << [name, path]
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def redirect_referrer_or_default(default)
    redirect_to(request.referrer || default)
  end

  def require_user
    if current_user.blank?
      respond_to do |format|
        format.html  {
          authenticate_user!
        }
        format.all {
          head(:unauthorized)
        }
      end
    end
  end

  # 要求可信用户
  def require_verified_user
    if current_user.blank?
      authenticate_user!
      return
    end

    if not current_user.verified?
      redirect_to root_path, :alert => "没有权限。"
      return
    end
  end

  def require_admin
    require_user
    return false if current_user.blank?
    if not Setting.admin_emails.include?(current_user.email)
      render_404
    end
  end
  
  def cookie_for_cell
    cookies
  end
  
  def drop_filter_breadcrumb(key)
    return if params[key].blank?
    drop_breadcrumb(params[key], movies_path(key => params[key]))
  end
  
  def list_filter_scope
    @movies = Movie.for_list
    @titles = []

    unless params[:year].blank?
      @filter_year = params[:year].to_i
      if @filter_year > 2005
        @movies = @movies.where(:year => @filter_year)
      else
        begin_year = 2000
        end_year = 2009
        case @filter_year
        when 90
          begin_year = 1990
          end_year = 1999
        when 80
          begin_year = 1980
          end_year = 1989
        when 70
          begin_year = 1970
          end_year = 1979
        end
        @movies = @movies.where(:year.gte => begin_year, :year.lte => end_year)
      end
      @titles << params[:year]
      drop_filter_breadcrumb(:year)
    end

    if params[:series] == "1"
      @movies = @movies.series
      @titles << "电视剧"
      drop_breadcrumb("电视剧", movies_path(:series => "1"))
    end

    unless params[:country].blank?
      @movies = @movies.tagged_with_on(:countries, params[:country])
      @titles << params[:country]
      drop_filter_breadcrumb(:country)
    end

    unless params[:language].blank?
      @movies = @movies.tagged_with_on(:languages, params[:language])
      @titles << params[:language]
      drop_filter_breadcrumb(:language)
    end

    unless params[:actor].blank?
      @movies = @movies.tagged_with_on(:actors, params[:actor])
      @titles << params[:actor]
      drop_filter_breadcrumb(:actor)
    end

    unless params[:director].blank?
      @movies = @movies.tagged_with_on(:directors, params[:director])
      @titles << params[:director]
      drop_filter_breadcrumb(:director)
    end

    unless params[:category].blank?
      @movies = @movies.tagged_with_on(:categories, params[:category])
      @titles << params[:category]
      drop_filter_breadcrumb(:category)
    end

    unless params[:tag].blank?
      @movies = @movies.tagged_with_on(:tags, params[:tag])
      @titles << params[:tag]
      drop_filter_breadcrumb(:tag)
    end

    @movies = @movies.has_attachs

    case params[:sort]
    when "recent"
      @movies = @movies.newest
    when "rank"
      @movies = @movies.high_rank
    else
      @movies = @movies.recent_upload
    end

    @movies
  rescue => e
    logger.error "list_filter_scope error: #{e}"
    render_404
  end
  
  MOBILE_USER_AGENTS =  'palm|blackberry|nokia|phone|midp|mobi|symbian|chtml|ericsson|minimo|' +
                        'audiovox|motorola|samsung|telit|upg1|windows ce|ucweb|astel|plucker|' +
                        'x320|x240|j2me|sgh|portable|sprint|docomo|kddi|softbank|android|mmp|' +
                        'pdxgw|netfront|xiino|vodafone|portalmmm|sagem|mot-|sie-|ipod|up\\.b|' +
                        'webos|amoi|novarra|cdm|alcatel|pocket|iphone|mobileexplorer|mobile'
  def mobile?
    agent_str = request.user_agent.to_s.downcase
    agent_str =~ Regexp.new(MOBILE_USER_AGENTS)
  end
  
  def check_site_enable
    if SiteConfig.site_enable == "0"
      render :template => "/errors/site_disable", :format => [:html], :handler => [:erb], :status => status, :layout => false
      return
    end
    
    if SiteConfig.site_enable == "2" && !mobile?
      render :template => "/errors/site_disable", :format => [:html], :handler => [:erb], :status => status, :layout => false
      return
    end
  end
  
  def check_site_enable_with_douban
    refer = request.referer || ""
    prel = params[:rel] || ""
    srel = cookies[:rel] || ""
    if srel.match("douban") || prel.match("douban") || refer.match("douban|x2yun|xunlei\.com|ipad\.ly|ruby-china|weibo\.com|zhihu\.com|t\.cn|t\.co|twitter\.com")
      cookies[:rel] = { value: "douban", expires: 1.month.from_now }
    else
      check_site_enable
    end
  end
  
  def fresh_when(opts = {})
    opts[:etag] ||= []
    # 保证 etag 参数是 Array 类型
    opts[:etag] = [opts[:etag]] if !opts[:etag].is_a?(Array)
    # 加入页面上直接调用的信息用于组合 etag
    opts[:etag] << current_user
    opts[:etag] << @page_title
    opts[:etag] << @meta_keywords
    opts[:etag] << @meta_description
    # etag 最长时效为一个星期
    opts[:etag] << Time.now.strftime("%Y%m-%w")
    opts[:etag] << flash
    opts[:etag] << "v2"
    super(opts)
  end
end
