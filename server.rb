require 'sinatra'
require 'pry'
require './lib/image_queue'
require './models/photo'
require 'json'

set :bind, '0.0.0.0'
set :database, 'sqlite3:images.db'

q = ImageQueue.new
host = Socket.gethostname
# host = '10.0.1.18'

get '/' do
  "image upload"
end

get "/upload" do
  erb :upload, :locals => { :host => host}
end

post "/upload" do
  image_directory = './images'
  suffix = Time.now.to_i

  file_name = "#{suffix}_#{params[:file][:filename]}"
  file = params[:file][:tempfile]
  begin
    File.open("#{image_directory}/#{file_name}", 'wb') do |f|
        f.write(file.read)
      end
      q.enqueue file_name
  rescue
    halt 500, 'upload failed'
  end
  erb :show, :locals => {file_name: file_name, host: host}
end

get "/quality/jpeg/:image_name" do
  image = params[:image_name]
  photo = Photo.find_by_name("#{image}")
  content_type :json
  if photo
    status 200
    {:name => image, :quality => photo.quality, :x_size => photo.x_size, :y_size => photo.y_size, :x_resolution => photo.x_resolution, :y_resolution => photo.y_resolution}.to_json
  else
    status 204
  end
end