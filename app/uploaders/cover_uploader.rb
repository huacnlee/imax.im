# coding: utf-8
class CoverUploader < BaseUploader
  version :small do
    process :resize_to_fit => [67, nil]
  end

  version :normal do
    process :resize_to_fit => [130, nil]
  end

  version :large do
    process :resize_to_fit => [297, nil]
  end

 	def default_url
    "#{Setting.upload_url}/assets/cover/#{version_name}.jpg"
  end

  def ext
    "jpg"
  end
end
