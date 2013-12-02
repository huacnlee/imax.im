# coding: utf-8
class BackgroundUploader < BaseUploader
  process :resize_to_limit => [1280, nil]

  def ext
    "jpg"
  end
  
 	def default_url
    "#{Setting.upload_url}/assets/default_background.png"
  end
end
