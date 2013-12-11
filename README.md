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
    
    
## 安装简单说明

### 环境

* Ubuntu Server 12.04
* Ruby 1.9.3
* MongoDB 2.4.0+
* Memcached 新版本
* Solr (用[特定脚本](https://raw.github.com/huacnlee/sunspot_chinese_example/master/install.sh)安装，以便有中文分词)

### Ruby 安装

建议新建一个 ruby 的 sudoer 用户，以后一切服务器在这个下面跑

#### 安装必要库

```
sudo apt-get update
sudo apt-get install -y wget vim build-essential openssl libreadline6 libreadline6-dev libsqlite3-dev libmysqlclient-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libxml2-dev libxslt-dev autoconf automake libtool imagemagick libmagickwand-dev libpcre3-dev language-pack-zh-hans nodejs
``` 

#### 安装 Ruby

```
cd ~/
mkdir downloads
cd downloads
wget http://cache.ruby-lang.org/pub/ruby/ruby-1.9.3-p484.tar.gz
tar zxf ruby-1.9.3-p484.tar.gz
cd ruby-1.9.3-p484
./configure 
make && sudo make install
```

试试 `ruby -v` 看看是否成功, `gem -v` 看看 RubyGems 是否安装成功。

```
gem install bundler rails
```

### 安装 MongoDb

```
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/10gen.list
sudo apt-get update
sudo apt-get install mongodb-10gen
ps aux | grep mongodb
```

### 安装 Memcached

```
sudo apt-get install memcached
ps aux | grep memcached
```

### 安装 Solr

```
cd ~/
mkdir tmp
cd tmp
wget https://github.com/sunspot/sunspot/archive/v2.0.0.zip
unzip v2.0.0.zip 
mv sunspot-2.0.0 sunspot
wget http://mmseg4j.googlecode.com/files/mmseg4j-1.8.3.zip
unzip mmseg4j-1.8.3.zip -d mmseg4j
cd ..
cp tmp/sunspot/sunspot_solr/solr sunspot_solr_mmseg4j -r
cp tmp/mmseg4j/data sunspot_solr_mmseg4j/solr/dict -r
mkdir -p tmp/WEB-INF/lib
cp tmp/mmseg4j/mmseg4j-all-1.8.3.jar tmp/WEB-INF/lib
sed 's,class="solr.StandardTokenizerFactory",class="com.chenlb.mmseg4j.solr.MMSegTokenizerFactory" mode="max-word" dicPath="dict",g' -i sunspot_solr_mmseg4j/solr/conf/schema.xml
jar uf sunspot_solr_mmseg4j/webapps/solr.war -C tmp WEB-INF/lib/mmseg4j-all-1.8.3.jar
rm -rf tmp
echo "******************"
echo "** install done **"
echo "******************"
echo "cd sunspot_solr_mmseg4j and run 'java -jar start.jar' to start jetty"
echo "visit http://localhost:8983/solr/ to verify result" 
```

以后就用 `java -jar start.jar` 来启动 Solr 服务，源代码里面已经配置好了连接本机的 Solr

### 安装网站源代码

```
cd ~/
cd www/movieso
bundle install
RAILS_ENV=production bundle exec rake assets:precompile
```

#### 修改 config/setting.yml 在里面加上 Douban API key

MongoDB, Memcached, Solr 什么的配置已经是在本地上面的，都是默认端口，没有密码的，如果数据，Solr, Memcached 什么的都有了，`rails s` 就应该能跑起来了。

#### 重建 Solr 索引

```
cd www/movieso
rake sunspot:solr:reindex
```
