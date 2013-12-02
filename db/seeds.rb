# coding: utf-8

SiteConfig.save_default(:custom_head_html,'')
SiteConfig.save_default(:footer_html, "&copy; imax.im")
SiteConfig.save_default(:notice, "")
SiteConfig.save_default(:before_attach_list, "")
SiteConfig.save_default(:after_attach_list, "")
SiteConfig.save_default(:bbs_sidebar, "")
SiteConfig.save_default(:after_attach_form,%(<div class="box">
  <div class="alert alert-block">
    <h4 class="alert-heading">特别注意!</h4>
    请尽量上传高清（720p，1080p），MKV 格式的资源，而 RMVB、AVI 格式，或 偷拍的，DVD 的，RC 版本的请尽量不要不要上传。
  </div>
</div>))
SiteConfig.save_default(:before_entries_list, "")
SiteConfig.save_default(:after_entries_list, "")
SiteConfig.save_default(:after_header, "")


# 首页推荐电影
SiteConfig.save_default(:home_suggest_movie_ids,"")
SiteConfig.save_default(:home_us_movie_ids,"")
SiteConfig.save_default(:home_cn_movie_ids,"")
SiteConfig.save_default(:home_kr_movie_ids,"")
SiteConfig.save_default(:home_cartoon_movie_ids,"")
SiteConfig.save_default(:home_series_ids,"")

SiteConfig.save_default(:home_meta_keywords, "720p 电影,1080p 电影,高清电影下载,电影在线观看,电影迅雷下载")
SiteConfig.save_default(:home_meta_description, "上万部 720p, 1080p 高清电影下载 (电驴/磁力连接/BT/迅雷) 网站，80% 以上的电影可以免费在线观看，这是追求高品质的社区, VeryCD 的替代者。这里没有杂乱的广告，电影都经过审核，确保质量。")
SiteConfig.save_default(:play_url, "http://btmee.com/vod/index.php?url=\#{url}")
SiteConfig.save_default(:site_enable,'1')
SiteConfig.save_default(:site_disable_html, "站点维护中。")

SiteConfig.save_default(:weekly_tip,%())
