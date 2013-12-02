# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
window.Movies =
  initNewAttachForm : () ->
    # 根据格式显示不同的框
    $('select#attach_format').change () ->
      format = $(this).val()
      if format == "torrent"
        $("#attach_file").parent().parent().show()
        $("#attach_url, #attach_name, #attach_file_size").parent().parent().hide()
      else if format == "ed2k"
        $("#attach_url").parent().parent().show()
        $("#attach_file, #attach_name, #attach_file_size").parent().parent().hide()
      else
        $("#attach_file").parent().parent().hide()
        $("#attach_url, #attach_name, #attach_file_size").parent().parent().show()
    $('select#attach_format').trigger("change")

  toggleHideHDLess : (el) ->
    $(".attachs table tr.collected").toggle "fast", ->
      if $(".attachs table tr.collected").css("display") != "none"
        $(".attachs .nav-pills li a").last().click()
        $(el).html("<i class='icon-chevron-up'></i> 隐藏非高清的资源")
      else
        $(el).html("<i class='icon-chevron-down'></i> 显示非高清的资源")
    return false

  loadSubs : (title) ->
    subsPanel = $("#subs .content")
    subsPanel.html("<div class='loading'>正在载入字幕信息...</div>")
    window.shteAPI = new ShteAPI()
    $.getScript "http://shooter.cn/api/qhandler.php?t=sub&e=utf-8&q=#{encodeURIComponent(title)}", () ->
      subsPanel.html("");
      if shteAPI.results.length == 0
        subsPanel.html("<div class='no_result'>在 <a href='http://shooter.cn' target='_blank'>射手网</a> 上面没有找到相关的字幕，你可以自己过去再试试。</div>")
      else
        for item in shteAPI.results
          subsPanel.append("<li><a href='http://shooter.cn#{item.link}' target='_blank'>#{item.title}</a>")
    true

  playAttach : (el) ->
    playLink = $(el)
    downLink = playLink.parent().parent().find("a.attach").attr("href")
    Movies.playAttachByUrl(downLink)
    return false

  playAttachByUrl : (url) ->
    $("#playForm").find("input[name=url]").val(url)
    $("#playForm").submit()
    return false

  suggest : (el,id,type) ->
    data =
      type : type
    $.post "/movies/#{id}/suggest", data, (res) ->
      $(el).parent().remove()
    return false

  # Cross domain fetch url content
  xssRequest : (url, callback) ->
    today = new Date()
    elid = today.getTime().toString()
    iFrameObj = document.createElement('IFRAME')
    iFrameObj.id = elid 
    iFrameObj.src = url
    document.body.appendChild(iFrameObj)      
    $(iFrameObj).load () ->
      callback($("body",this.contentWindow.document).html())
    return false
    
  ed2k_pattern : /ed2k:\/\/\|file\|[^\|]+\|\d+\|[0-9a-z]{32}\|(h=[a-z0-9]{32}\|)?\//gi
  
  ajaxFetchAttachs : () ->
    html = $('#fetch-attachs-html').val()
    $("#fetch-attachs-window .fetch_box").hide()
    $("#fetch-attachs-window .choice_box").show()
    urls = html.match(Movies.ed2k_pattern)
    Movies.renderFetchAttachResults(urls) 
    return false

  renderFetchAttachResults : (urls) ->
    tbody = $("#fetch-attachs-window .choice_box tbody")
    added_urls = []
    for url,i in urls
      if added_urls.indexOf(url) == -1
        names = UrlDecoder.decode(url)
        tbody.append("<tr><td>#{names[1]}Gb</td><td>#{names[0]}</td>
        <td><select name='quality[#{i}]'><option value='480'>480p</option><option value='720' selected='true'>720p</option><option value='1080'>1080p</option></select></td>
        <td><input name='urls[#{i}]' value='#{url}' type='checkbox' checked='checked' /></td></tr>")
        added_urls.push(url)
    $("#fetch-attachs-window").modal("hide")
    $("#mainbox .container").css("height","auto")
    $("#movie").html($("#fetch-attachs-window .choice_box").html())
    return false
    
class ShteAPI
  results : new Array()
  showResults : () ->
     return false
     