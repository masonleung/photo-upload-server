require 'sinatra/activerecord'

class Photo < ActiveRecord::Base
  validates :name, :x_size, :y_size, :quality, presence: true
end
