require 'RMagick'
require 'pry'
include Magick
require_relative '../lib/algorithm'

def analyze file
  score = Algorithm.new(file).calculate_photo_quality
  puts "#{file} = #{score}"
end

Dir['./samples/*'].each do |file|
  begin
    analyze file
  rescue
    puts "skip #{file}"
  end
end
