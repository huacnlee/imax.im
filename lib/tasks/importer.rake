# coding: utf-8
require 'sprite_factory'
namespace :importer do
  desc ''
  task :douban_ids => :environment do
    from_line = 15
    counter = 0
    File.open("#{Rails.root}/db/imdb_ids.cvs", "r") do |infile|
      while(line = infile.gets)
        id = line.strip
        counter += 1
        next if counter < from_line
        movie = Movie.find_by_imdb_id(id)
        if movie.blank?
          print "line: #{counter} | imdb: #{id} : movie_id: "
          movie = Movie.fetch_douban(:imdb, id)
          if movie.errors.count > 0
            puts "ERROR: #{movie.errors.inspect}"
          else
            puts movie.id
          end
          sleep(0.1)
        end
      end
    end
  end

  desc 'recreate sprite images and css'
  task :ixcks => :environment do
		ActiveRecord::Base.logger = Logger.new('/dev/null')
    total_added = 0
    from_line = 5583
    counter = 0
    File.open("#{Rails.root}/db/ixcks.cvs", "r") do |infile|
      while(line = infile.gets)
        counter += 1
        next if counter < from_line
        cols = line.split('Ω')
        movie = Movie.find_by_imdb_id(cols[0])
        if movie.blank?
          puts "-- ERROR: #{cols[0]} douban_id not found."
          next
        end
        print "line: #{counter} | movie:#{movie.id} | "
        if cols[1].blank? || cols[2].blank? || cols[3].blank?
          puts "[Skip] resource name is blank."
          next
        end
        attach = movie.attachs.new(:url => cols[2].strip, :name => cols[3].strip)

        if attach.url.match(/ed2k\:\/\//i)
          attach.format = "ed2k"
        else
          attach.format = "magnet"
        end
        # 跳过错误的 URL，由于 MySQL 字段设置没对，某些 URL 被 255 的宽度截断了
        if attach.url.size >= 255
          puts "Bad url #{attach.url.size} length"
          next
        end

        attach.file_size = (cols[1].to_i / 1024 / 1024 / 1024.00).round(2)
        if attach.name.include?("1080") or attach.file_size >= 7.5
          attach.quality = 1080
          if movie.has_1080p?
            puts "1080 exited."
            next
          end
        elsif attach.name.match(/720p/i) or attach.file_size >= 4
          attach.quality = 720
          if movie.has_720p?
            puts "720 exited."
            next
          end
        else
          attach.quality = 480
          if movie.attachs.count > 0
            puts "480 exited."
            next
          end
        end

        if movie.save
          total_added += 1
          puts "------------------------------- [Done] #{attach.id}"
        else
          puts "[WARN] #{attach.errors.full_messages}"
        end
        attach = nil
      end
      puts "============================================"
      puts "total added: #{total_added} attachs"
    end
  end
end
