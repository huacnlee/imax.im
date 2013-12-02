# IMAX.im

## 功能

* 依附于 Douban API 创建电影信息库；
* 上传资源的时候自动解析 Ed2k, Torrent 的信息；
* 国内在线视频网站播放地址解析；
* Retina Display 支持;
* Apple TV API for @盒子大师

## 系统需求

* Linux
* Ruby 1.9.3 (2.0.0 CSS 有个 Bug 一直没查出来)
* Solr
* MongoDb
* Redis
* Memcached
* Douban API

## 搜索引擎

使用 Solr 实现搜索功能。

## Scanffold 命令创建后台

    rails g scaffold_controller admin/movies title:string year:integer alias_list:string director_list:string actor_list:string category_list:string country_list:string language_list:string tag_list:string pub_date:date time_length:integer imdb:string rank:integer raters_count:integer cover:string website:string desc:string summary:string
    