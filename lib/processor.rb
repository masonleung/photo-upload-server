require_relative 'image_queue'
require_relative '../models/photo'
require_relative 'algorithm'
require 'RMagick'

include Magick

class Processor

  def initialize
    @q = ImageQueue.new
    @image_directory = './images'
  end

  def open_image image_name
    return nil if image_name.nil?

    file = "#{@image_directory}/#{image_name}"

    begin
      return ImageList.new(file)
    rescue
      File.delete(file)
      return nil
    end
  end

  def process
    loop do
      image_name = @q.dequeue
      im = open_image image_name
      if !im.nil?
        puts "process #{image_name}"
        quality = Algorithm.new(im.base_filename).calculate_photo_quality
        photo = Photo.new(name: image_name, x_size: im.rows, y_size: im.columns, quality: quality, x_resolution: im.x_resolution, y_resolution: im.y_resolution)
        photo.save
      end
      sleep 1
    end
  end
end