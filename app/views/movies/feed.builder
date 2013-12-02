xml.instruct! :xml, :version=>"1.0" 
xml.rss(:version=>"2.0"){
  xml.channel{
    xml.title "#{Setting.app_name} 最新列表"
    xml.link root_url
    xml.description("来自#{Setting.app_name}的最新发布的电影列表")
    xml.language('zh-CN')
      for movie in @movies
        xml.item do
          if movie.attachs.count > 0
            xml.title "#{movie.title} - #{movie.attachs.last.name}"
          else
            xml.title "#{movie.title} 暂无下载"
          end
          attachs_text = []
          movie.attachs.each { |a| attachs_text << a.name }
          xml.description raw(simple_format("#{link_to image_tag(movie.cover.large.url), movie_url(movie)}<br />#{movie.desc}\n\n<a href='#{movie_url(movie)}'>#{attachs_text.join("\n")}</a>"))
          xml.author ""
          if !movie.last_uploaded_at.blank?
            xml.pubDate(movie.last_uploaded_at.strftime("%a, %d %b %Y %H:%M:%S %z"))
          else
            xml.pubDate(movie.created_at.strftime("%a, %d %b %Y %H:%M:%S %z"))
          end
          xml.link movie_url(movie)
          xml.guid movie_url(movie)
        end
      end
  }
}
