#!/usr/bin/env rake
# coding: utf-8
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Movieso::Application.load_tasks


desc '导出 Email 成 CSV'
task :export_users => :environment do
  require "csv"
  export_root = "#{Rails.root}/db"
  i = 0
  User.asc(:_id).find_in_batches(:batch_size => 1500) do |users|
    fname = File.join(export_root,"user_mails_#{i}.csv")
    next if File.exists?(fname)
    CSV.open(fname, "wb") do |csv|
      users.each do |u|
        csv << [u.email,u.name]
      end
    end
    i += 1
  end
end

desc "Fix HDTV"
task :fix_hdtv => :environment do
  Movie.where(:_id.gte => 17556).asc(:_id).each do |movie|
    print "movie: #{movie.id} ."
    movie.attachs.each do |a|
      next if a.name.blank?
      if a.quality == 480 && a.name.match(/HDTV|人人影视|中文字幕/i)
        a.quality = 481
        print "."
        movie.has_hr_hdtv = true
      end
    end
    if movie.has_hr_hdtv
      movie.attachs.or(:quality => 480).or(:quality => 0).delete_all
      movie.save
    end
    puts "."
  end
end


desc '导出 Email 成 CSV'
task :export_images => :environment do
  require "fileutils"
  output_dir = "/home/sunfjun/uploads/movie"
  if !Dir.exist?(output_dir)
    FileUtils.mkdir_p(output_dir)
  end
  
  Movie.where(:_id.gte => 55332).asc(:_id).each do |movie|
      print "Movie: #{movie.id}"
      %W(small normal large).each do |ftype|
        url = movie.cover.url(ftype.to_sym)
        fname = url.split("/").last
        `wget #{url} -o wget.log -O #{output_dir}/#{fname}`
        print "."
      end
      url = movie.cover.url
      fname = url.split("/").last
      `wget #{url} -o wget.log -O #{output_dir}/#{fname}`
      print "."
      puts " [Done]"
  end
end
