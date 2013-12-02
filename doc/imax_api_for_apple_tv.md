本 API 是便于三方开发者快速接入到各种平台里面的，目前 Apple TV 也是用此接口实现。

## 电影信息

`GET` http://imax.im/api/movies/:id.json

### 属性说明

* id - 电影编号
* title - 名称
* year - 发行年代
* attachs - 下载资源（需要用迅雷云的）
* sources - 国内网站资源 (url 是页面地址，需要单独处理解析)
* actors - 演员列表 
* directors - 导演
* languages - 语言
* categories - 类型
* length - 时长
* summary - 介绍
* rank - 豆瓣评分 
* raters_count - 豆瓣参与点评的人数
* cover - 封面图(大图)

### 返回值

参见具体页面结果：[点击这里](http://imax.im/api/movies/1.json)

## 电影列表

`GET` http://imax.im/api/movies.json

### 返回值

参见具体页面结果：[点击这里](http://imax.im/api/movies.json)

### 参数

参数和网页版本基本一致，调试的时候可以在页面上找出过滤的参数在 /movies 前面加上 api 即可

* _page_ - 第几页（）
* _sort_ - 排序方式, 可选值 [recent,rank,upload]
    * recent - 按电影上映时间
    * rank - 按豆瓣评分
    * upload - 按 imax.im 发布时间(此处我会特意挑选，新上传的电影只有品质稍好的才会排到前面去)
* _country_ - 按国家过滤，可选值：[美国 中国大陆 香港 日本 韩国 法国 德国 泰国]
* _category_ - 按电影类型过滤，可选值：[科幻 动作 喜剧 爱情 剧情 魔幻 动画 悬疑 惊悚 战争 历史]
* _year_ - 按年份过滤，可选值：[2012 2011 2010 2009 2008 2007 2006 00 90 80 70]
    * 其中 00 表示 00年代 2000-2009 ,90 表示 1990 - 1999 …
* _language_ - 按语言过滤, 可选值：[汉语普通话 英语 法语 日语 韩语]
* _actor_ - 按演员过滤, 值为任意演员的名字
* _director_ - 按导演过滤，值为任意导演的名字

## 搜索电影

`GET` http://imax.im/api/movies/search.json

### 返回值

属性: `[{ id, cover, name, year }]`

参见具体页面结果：[点击这里](http://imax.im/api/movies/search.json?q=变形金刚)

### 参数

* _q_ - 搜索关键词

此 API 最多只会返回 8 条数据

------------------------

## 附注

豆瓣评分的算法

```
def small_rank
  i = self.rank
  if i > 9
    "5"
  elsif i > 8 and i < 9.1
    "4.5"
  elsif i > 7 and i < 8.1
    "4"
  elsif i > 6 and i < 7.1
    "3.5"
  elsif i > 5 and i < 6.1
    "3"
  elsif i > 4 and i < 5.1
    "2.5"
  elsif i > 3 and i < 4.1
    "2"
  elsif i > 2 and i < 3.1
    "1.5"
  elsif i > 1 and i < 2.1
    "1"
  elsif i > 0 and i < 1.1
    "0.5"
  elsif i < 0.1
    "0"
  end
end
```