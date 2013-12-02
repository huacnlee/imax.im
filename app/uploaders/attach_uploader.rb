# coding: utf-8
require 'carrierwave/processing/mime_types'
class AttachUploader < CarrierWave::Uploader::Base
  include CarrierWave::MimeTypes
  storage :file

  def store_dir
    "/tmp/movieso/attachs"
  end

  def extension_white_list
    %w(torrent)
  end

  def ext
    "torrent"
  end
end