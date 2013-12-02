Sidekiq.configure_server do |config|
  config.redis = { :namespace => 'movie_sidekiq' }
end

Sidekiq.configure_client do |config|
  config.redis = { :namespace => 'movie_sidekiq' }
end