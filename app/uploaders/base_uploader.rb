# encoding: utf-8
require 'carrierwave/processing/mini_magick'
class BaseUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  # include Piet::CarrierWaveExtension
  # def optimize
  #   manipulate! do |img|
  #     Piet.optimize(img.path)
  #     ::MiniMagick::Image.open(img.path)
  #   end
  # end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    if model["#{mounted_as}"]
      fname = model["#{mounted_as}"]
    else
      fname = self.filename
    end
    p1,p2 = fname[0,1],fname[1,1]
    [model.class.to_s.underscore,p1,p2].join("/")
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    "photo/#{version_name}.jpg"
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  def ext
    file.extension.downcase
  end

  # Override the filename of the uploaded files:
  def filename
    if super.present?
      # current_path 是 Carrierwave 上传过程临时创建的一个文件，有时间标记，所以它将是唯一的
      @name ||= Digest::MD5.hexdigest(File.dirname(current_path))
      "#{@name}.#{ext}"
    end
  end

end
