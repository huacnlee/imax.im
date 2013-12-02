CarrierWave.configure do |config|
  config.storage = :file
  config.cache_dir = "/tmp/movieso"
	if Rails.env.production?
		config.root = "/home/sunfjun/uploads"
  else
    config.root = [Rails.root,"public","uploads"].join("/")
	end
  config.asset_host = "http://127.0.0.1:3000/uploads"
end
