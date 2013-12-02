# coding: utf-8
require "spec_helper"

describe Attach do
  describe ".format_ed2k" do
    before(:each) do
      @a = Attach.new
      @a.format = "ed2k"
    end

    it "should get filename,file_size from url" do
      @a.url = "ed2k://|file|海洋天堂.Ocean.Heaven.2010.HDTV.MiniSD-TLF.mkv|673607370|5D51D27463281ADAA898C606C951122A|h=AH56L3NHWY2KYZUV3234IY5DT4OQT7KM|/"
      @a.format_ed2k
      @a.name.should == "海洋天堂.Ocean.Heaven.2010.HDTV.MiniSD-TLF.mkv"
      @a.file_size.should == 0.63

      @a.url = "ed2k://|file|the.expendables.2010.extended.dc.720p.bluray.x264-nodlabs.mkv|4691655037|EF1AD077280EEC6A9FC81FD21493E296|h=HKYOKQWDU72PKBVAAEWV5OLMZ4TGSO2A|/"
      @a.format_ed2k
      @a.name.should == "the.expendables.2010.extended.dc.720p.bluray.x264-nodlabs.mkv"
      @a.file_size.should == 4.37
    end

    it "should decode encode urls" do
      @a.url = "ed2k://|file|%E6%A0%BC%E6%9E%97.Grimm.S01E18.Chi_Eng.HDTVrip.1024X576-YYeTs%E4%BA%BA%E4%BA%BA%E5%BD%B1%E8%A7%86.mkv|507718433|d2a6e96237ca0f6c0456a447c17eba16|h=apuerxx7vsliuaf63be5bhidsmp2slpj|/"
      @a.format_ed2k
      @a.name.should == "格林.Grimm.S01E18.Chi_Eng.HDTVrip.1024X576-YYeTs人人影视.mkv"
      @a.url.should == "ed2k://|file|#{@a.name}|507718433|d2a6e96237ca0f6c0456a447c17eba16|h=apuerxx7vsliuaf63be5bhidsmp2slpj|/"
    end
  end

  describe ".fix_format" do
    it "should fix with torrent" do
      @a = Attach.new
      @a.format = "torrent"
      @a.file = "asdgasdg"
      @a.fix_format
      @a.format.should == "torrent"
    end

    it "should fix with ed2k" do
      @a = Attach.new
      @a.url = "ed2k://|file|格林.Grimm.S01E18.Chi_Eng.HDTVrip.1024X576-[imax.im].mkv"
      @a.fix_format
      @a.format.should == "ed2k"
    end

    it "should fix with magnet" do
      @a = Attach.new
      @a.url = "magnet:?xt=urn:btih:879c9ef921813a7136198c7292ec189cb1301335&xl=8712449355&tr=http://bt2.54new.com:8080/announce&dn=《舌尖上的中国》七集全.高清版"
      @a.fix_format
      @a.format.should == "magnet"
    end

    it "should fix with thunder/http" do
      @a = Attach.new
      @a.url = "http://foobvat.com/aaa"
      @a.fix_format
      @a.format.should == "thunder"
      @a.url = "thunder://qufodhrwoi8vbw92awuuyw44ns5jb20vzmlsbs/l97bgwuoxmjdm7c5ybvpa"
      @a.fix_format
      @a.format.should == "thunder"
    end
  end

  describe "#read_torrent" do
    it "should work" do
      info = AttachBase.read_torrent("spec/fixtures/simple.torrent")
      info.count.should == 3
      info[0].should == "Exit.Humanity.2011.720p.BluRay.x264-LiViDiTY"
      info[1].should == 5.53
      info[2].should == "magnet:?xt=urn:btih:be01a118277f904ea8c124159f838fd248de36cb&dn=Exit.Humanity.2011.720p.BluRay.x264-LiViDiTY"
    end

    it "should work with multi file" do
      info = AttachBase.read_torrent("spec/fixtures/en.torrent")
      info[0].should == "[dydao.com]CCTV.She.Jian.Shang.De.Zhong.Guo.E01-E07.720p.HDTV.x264-HDCTV"
      info[1].should == 9.3
      info[2].should == "magnet:?xt=urn:btih:128705df68d183e7fac63c9ae19c4d85f5f3063f&dn=[dydao.com]CCTV.She.Jian.Shang.De.Zhong.Guo.E01-E07.720p.HDTV.x264-HDCTV"
    end

    it "should work with multi file Chinese" do
      info = AttachBase.read_torrent("spec/fixtures/zh-CN.torrent")
      info[0].unpack('U*').pack('U*').should == "飞鸟娱乐(bbs.wofei.net).兄弟连十集全1280x720版"
      info[1].should == 15.86
      info[2].unpack('U*').pack('U*').should == "magnet:?xt=urn:btih:648b5fe1ad33dc75998f6a4037728f6074f730fa&dn=飞鸟娱乐(bbs.wofei.net).兄弟连十集全1280x720版"
    end

  end
end