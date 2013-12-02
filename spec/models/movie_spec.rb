# coding: utf-8
require "spec_helper"
require "open-uri"

def stub_open!(id, dir = "covers")
  Movie.stub_chain(:open, :read).and_return(open("spec/fixtures/#{dir}/#{id}.html").read)
end

describe Movie do
  describe "#fetch_cover_url" do
    it "should work" do
      stub_open!(6855757)
      Movie.fetch_cover_url(6855757,"foobar").should == "http://img1.douban.com/view/photo/photo/public/p1223484994.jpg"
    end

    it "should gsub cover_url spic -> opic" do
      Movie.stub_chain(:open, :read).and_return("")
      Movie.fetch_cover_url(6855757,"http://img.com/spic/sss.jpg").should == "http://img.com/opic/sss.jpg"
    end

    it "should work when page is null" do
      Movie.stub_chain(:open, :read).and_return("")
      Movie.fetch_cover_url(6855757,"foobar").should == "foobar"
    end

    it "should work when page covers not found" do
      Movie.stub_chain(:open, :read).and_return("<div class='poster-col4'><li></li></div>")
      Movie.fetch_cover_url(6855757,"foobar").should == "foobar"
    end

    it "当第一个图没有尺寸的时候，跳过，用第二个" do
      stub_open!(1294639)
      Movie.fetch_cover_url(1294639, "foobar").should == "http://img1.douban.com/view/photo/photo/public/p1374546770.jpg"
    end

    it "跳过宽度小于 500px 的图片" do
      stub_open!(1828115)
      Movie.fetch_cover_url(1828115, "foobar").should == "http://img1.douban.com/view/photo/photo/public/p671301961.jpg"
    end

    it "当没有背景图的时候，返回原始的，用原始封面图" do
      stub_open!("none_pic")
      Movie.fetch_cover_url(5384532,"foobar").should == "foobar"
    end

    it "当第一张图比例是宽比高大的时候,用第二张，用原始封面图" do
      stub_open!(6799156)
      Movie.fetch_cover_url(6799156,"foobar").should == "http://img1.douban.com/view/photo/photo/public/p1348930804.jpg"
    end

    it "当所有图片的比例都不符合要求时，用原始封面图" do
      stub_open!(5384532)
      Movie.fetch_cover_url(5384532,"foobar").should == "foobar"
    end

    it "当图片宽度小于 300px 的时候，用原始封面图" do

    end

    it "跳过 日本和韩国 的封面" do
      stub_open!(1294638)
      Movie.fetch_cover_url(1294638,"foobar").should == "http://img1.douban.com/view/photo/photo/public/p1245601110.jpg"
    end

    it "其他一些随机测试" do
      stub_open!(1947549)
      Movie.fetch_cover_url(5384532,"foobar").should == "http://img3.douban.com/view/photo/photo/public/p758029966.jpg"
      stub_open!(1306737)
      Movie.fetch_cover_url(1306737,"foobar").should == "http://img1.douban.com/view/photo/photo/public/p1355087093.jpg"
      stub_open!(1297753)
      Movie.fetch_cover_url(1297753,"foobar").should == "http://img5.douban.com/view/photo/photo/public/p1150346439.jpg"
      stub_open!(2124586)
      Movie.fetch_cover_url(2124586,"foobar").should == "http://img3.douban.com/view/photo/photo/public/p642968068.jpg"
    end
  end

  describe "#fetch_bg_url" do
    it "should work" do
      stub_open!(1,"bgs")
      Movie.fetch_bg_url(1).should == "http://img1.douban.com/view/photo/raw/public/p1519667513.jpg"
    end

    it "跳过宽小于高的，跳过宽度小于 800 宽度" do
      stub_open!(2,"bgs")
      Movie.fetch_bg_url(2).should == "http://img3.douban.com/view/photo/raw/public/p1517034755.jpg"
    end

    it "没有内容的时候返回空字符串" do
      stub_open!(3,"bgs")
      Movie.fetch_bg_url(3).should == ""
    end
  end

  describe ".rank_class" do
    it "should right" do
      movie = Movie.new
      movie.rank = 5.6
      movie.rank_class_name.should == "30"
      movie.rank = 6.1
      movie.rank_class_name.should == "35"
      movie.rank = 6.4
      movie.rank_class_name.should == "35"
      movie.rank = 7.0
      movie.rank_class_name.should == "35"
      movie.rank = 7.8
      movie.rank_class_name.should == "40"
      movie.rank = 8.8
      movie.rank_class_name.should == "45"
      movie.rank = 9.5
      movie.rank_class_name.should == "50"
    end
  end
end