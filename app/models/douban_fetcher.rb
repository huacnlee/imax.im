# coding: utf-8
class DoubanFetcher
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform(pname, id)
    Movie.queue_fetch_douban(pname, id)
  end
end