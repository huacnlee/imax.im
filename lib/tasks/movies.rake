# coding: utf-8
namespace :movies do
  desc '重新统计每部电影的 score 值，用于调整算法的时候'
  task :retotal_score => :environment do
    Movie.find_in_batches(:batch_size => 1000) do |movies|
      movies.each do |movie|
        movie.retotal_score
        movie.set(:score,movie.score)
        print "."
      end
    end
    puts "Done"
  end
end